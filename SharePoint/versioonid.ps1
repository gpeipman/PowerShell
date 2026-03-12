# ---------------------------------------------
# CONFIG
# ---------------------------------------------
$siteUrl      = "https://gpeipman.sharepoint.com/peakasutaja"
$listName     = "Shared Documents"   # sama mis Drive.Name
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

# ---------------------------------------------
# RESOLVE LIST (DOCUMENT LIBRARY)
# ---------------------------------------------
$list = Get-MgSiteList -SiteId $site.Id | Where-Object { $_.Name -eq $listName }

if (-not $list) {
    Write-Host "List '$listName' not found." -ForegroundColor Red
    exit
}

Write-Host "Using list: $($list.Name)"

# ---------------------------------------------
# GET ALL LIST ITEMS (FILES ONLY)
# ---------------------------------------------
Write-Host "Loading all list items..."
$listItems = Get-MgSiteListItem -SiteId $site.Id -ListId $list.Id -ExpandProperty DriveItem

# Filter only items that have DriveItem (i.e., files)
$files = $listItems | Where-Object { $_.DriveItem -and $_.DriveItem.File }

Write-Host "Found $($files.Count) files."

# ---------------------------------------------
# PROCESS EACH FILE – KEEP LAST 5 VERSIONS
# ---------------------------------------------
foreach ($item in $files) {

    $file = $item.DriveItem

    Write-Host "`nProcessing file: $($file.Name)"

    $versions = Get-MgDriveItemVersion -DriveId $file.ParentReference.DriveId -DriveItemId $file.Id

    if ($versions.Count -le $keepVersions) {
        Write-Host "  Nothing to delete. Versions: $($versions.Count)"
        continue
    }

    $sorted = $versions | Sort-Object { [version]$_.Id }
    $toDelete = $sorted[0..($sorted.Count - $keepVersions - 1)]

	$versions | Select Id, LastModifiedDateTime, IsLatest, Publication, ContentType
    Write-Host "  Total versions: $($versions.Count). Deleting $($toDelete.Count) old versions..."

    foreach ($v in $toDelete) {
        Write-Host "    Deleting version $($v.Id)..."
        Remove-MgDriveItemVersion `
            -DriveId $file.ParentReference.DriveId `
            -DriveItemId $file.Id `
            -DriveItemVersionId $v.Id
    }

    Write-Host "  Done."
}

Write-Host "`nAll files processed."