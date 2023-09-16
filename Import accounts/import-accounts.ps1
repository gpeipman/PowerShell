# Let's keep our Office 365 tenant information here
$domain = "yourtenant.onmicrosoft.com"

# Name of CSV file to import
$fileName = "it21e.csv"

# Name of teams group for class
$teamName = "IT21E"

# Read credentials from file. If credential file doesn't exists then ask
# credentials using dialog and save credentials to file.
if(Test-Path -Path cred.xml -PathType Leaf)
{
    $cred = Import-Clixml cred.xml
}
else 
{
    $cred = Get-Credential
    $cred | Export-Clixml -Path cred.xml
}

# Import modules we need to communicate with Azure and Office 365 services
Import-Module AzureAD
Import-Module ExchangeOnlineManagement
Import-Module MicrosoftTeams

# Include create-password.ps1 so we can generate random passwords
. .\create-password.ps1

# Read new users from CSV file and generate temporary passwords
# Also generate new e-mail addresses for our domain
$newUsers = Import-Csv $fileName -Delimiter ";" | 
            Select Id,FirstName,LastName,
                   @{n="Password"; e={ New-Password }},
                   @{n="Email"; e={"$PSItem.ID@$domain"}}

# Connect to Azure on Office 365 services we need to use
Connect-ExchangeOnline -Credential $cred
Connect-AzureAD -Credential $cred
Connect-MsolService -Credential $cred
Connect-MicrosoftTeams -Credential $cred

# Check if Teams room exists and if it doesn't then create new
$team = Get-Team -DisplayName $teamName
if($team -eq $null)
{
    $team = New-Team -DisplayName $teamName -MailNickName $teamName
}

Write-Host "Team group ID: $team.GroupId"

# Get Office 365 subscription and read licenses
$sku = Get-AzureADSubscribedSku | Where SkuPartNumber -eq ENTERPRISEPACK
$license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$license.SkuId = $sku.SkuId

# Create object for assigning license to users
$licensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$licensesToAssign.AddLicenses = $license

# Traverse through user objects loaded from CSV
foreach($newUser in $newUsers)
{
    # Create new SecureString to hold user password
    $securePassword = ConvertTo-SecureString $newUser.Password -AsPlainText -Force

    # Create display name and UPN
    $displayName = $newUser.FirstName + " " + $newUser.LastName
    $upn = $newUser.Id + "@$domain"

    # Create mailbox for user. When creating new mailbox then new Office 365 
    # user account is also created
    $mb = New-Mailbox -Alias $newUser.ID `
                -Name $newUser.ID `
                -FirstName $newUser.FirstName `
                -LastName $newUser.LastName `
                -DisplayName $displayName `
                -Password $securePassword `
                -MicrosoftOnlineServicesID $upn

    # We need to set usage location for new user to assign license
    $user = Get-AzureAdUser -ObjectId $mb.ExternalDirectoryObjectId 
    $user | Set-AzureADUser -UsageLocation EE
    
    # Assign license to user
    $user | Set-AzureADUserLicense -AssignedLicenses $licensesToAssign
    
    # Add user to Teams group
    Add-TeamUser -GroupId $team.GroupId -User $mb.ExternalDirectoryObjectId -Role Member
}

# Write out new users
$newUsers