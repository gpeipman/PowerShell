# ---------------------------------------------
# CONFIG
# ---------------------------------------------
$siteUrl      = "https://<tenant>.sharepoint.com/"
$keepVersions = 3

# ---------------------------------------------
# LOGIN
# ---------------------------------------------
Connect-MgGraph -Scopes "Sites.ReadWrite.All","Files.ReadWrite.All"

# ---------------------------------------------
# RESOLVE SITE
# ---------------------------------------------
$uri  = [Uri]$siteUrl
$path = $uri.AbsolutePath.TrimStart("/")
$site = Get-MgSite -SiteId "$($uri.Host):/$path"

Write-Host "Using site: $($site.Id)" | Out-Host

# ---------------------------------------------
# GET ALL DRIVES (DOCUMENT LIBRARIES) ON SITE
# ---------------------------------------------
$drives = Get-MgSiteDrive -SiteId $site.Id

Write-Host "Found $($drives.Count) drives (document libraries)." | Out-Host

# ---------------------------------------------
# RECURSIVE FUNCTION TO WALK FOLDERS
# ---------------------------------------------
function Process-DriveFolder {
    param(
        [string]$DriveId,
        [string]$ItemId  # null/empty = root
    )

    # Load children safely
    if ([string]::IsNullOrWhiteSpace($ItemId)) {
        $children = Get-MgDriveRootChild -DriveId $DriveId -PageSize 200
    }
    else {
        $children = Get-MgDriveItemChild -DriveId $DriveId -DriveItemId $ItemId -PageSize 200
    }

    foreach ($child in $children) {

        # Skip items with missing ID (Graph bug)
        if ([string]::IsNullOrWhiteSpace($child.Id)) {
            Write-Host "  Skipping item with empty ID (Graph returned invalid object)" | Out-Host
            continue
        }

        # Folder
        if ($child.Folder -and $child.Folder.ChildCount -ne $null) {
            Write-Host "  Folder: $($child.Name)" | Out-Host
            Process-DriveFolder -DriveId $DriveId -ItemId $child.Id
            continue
        }

        # File
        if ($child.File -ne $null) {
            Write-Host "    File: $($child.Name)" | Out-Host

            $versions = Get-MgDriveItemVersion -DriveId $DriveId -DriveItemId $child.Id

            if ($versions.Count -le $keepVersions) {
                Write-Host "      Nothing to delete. Versions: $($versions.Count)" | Out-Host
                continue
            }

            $sorted   = $versions | Sort-Object { [version]$_.Id }
            $toDelete = $sorted[0..($sorted.Count - $keepVersions - 1)]

            Write-Host "      Total versions: $($versions.Count). Deleting $($toDelete.Count)..." | Out-Host

            foreach ($v in $toDelete) {
                Write-Host "        Deleting version $($v.Id)..." | Out-Host
                Remove-MgDriveItemVersion `
                    -DriveId $DriveId `
                    -DriveItemId $child.Id `
                    -DriveItemVersionId $v.Id
            }

            Write-Host "      Done." | Out-Host
        }
    }
}

# ---------------------------------------------
# PROCESS EACH DRIVE (DOCUMENT LIBRARY)
# ---------------------------------------------
foreach ($drive in $drives) {

    Write-Host "`nProcessing drive (library): $($drive.Name)" | Out-Host
    Write-Host "  Drive ID: $($drive.Id)" | Out-Host
    Write-Host "  Walking folder tree..." | Out-Host

    Process-DriveFolder -DriveId $drive.Id -ItemId $null
}

Write-Host "`nAll drives processed." | Out-Host