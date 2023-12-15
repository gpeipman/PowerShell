# Let's keep our Office 365 tenant information here
$domain = "<your tenant>.onmicrosoft.com"

# Name of CSV file to import
$fileName = "it21e.csv"

# Name of teams group for class
$teamName = "IT21E-Klassigrupp"
$securityGroupName = "IT21E-Security"

# License type for users
$licenseSku = "DEVELOPERPACK_E5"

# Read credentials from file. If credential file doesn't exists then ask
# credentials using dialog and save credentials to file.
if(Test-Path -Path cred.xml -PathType Leaf)
{
    $cred = Import-Clixml cred.xml
}
else 
{
    Write-Host "Getting credential"
    $cred = Get-Credential
    $cred | Export-Clixml -Path cred.xml
    Write-Host "Got credential"
}

# Import modules we need to communicate with Azure and Office 365 services
Import-Module AzureAD
Import-Module ExchangeOnlineManagement
Import-Module MicrosoftTeams

# Include create-password.ps1 so we can generate random passwords
. .\create-password.ps1

Write-Host "Importing users"
# Read new users from CSV file and generate temporary passwords
# Also generate new e-mail addresses for our domain
$newUsers = Import-Csv $fileName -Delimiter ";" | 
            Select Id,FirstName,LastName,
                   @{n="Password"; e={ New-Password }},
                   @{n="Email"; e={ $PSItem.ID + "@$domain"}}

Write-Host "Connecting to services"
# Connect to Azure on Office 365 services we need to use
Connect-ExchangeOnline -Credential $cred 3>$null
Connect-AzureAD -Credential $cred
Connect-MsolService -Credential $cred
Connect-MicrosoftTeams -Credential $cred

Write-Host "Finding/creating Teams team"
# Check if Teams room exists and if it doesn't then create new
$team = Get-Team -DisplayName $teamName
if(!$team)
{
    $team = New-Team -DisplayName $teamName -MailNickName $teamName
}

Write-Host "Team group ID: " + $team.GroupId

Write-Host "Finding/creating Azure AD group"
# Create AD group for class
$adGroup = Get-AzureADGroup -SearchString $securityGroupName
if(!$adGroup)
{
   $adGroup = New-AzureADGroup -DisplayName $securityGroupName -MailEnabled $false -MailNickName $securityGroupName -SecurityEnabled $true
}

Write-Host "Getting license"
# Get Office 365 subscription and read licenses
$sku = Get-AzureADSubscribedSku | Where SkuPartNumber -eq $licenseSku
$license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$license.SkuId = $sku.SkuId

# Create object for assigning license to users
$licensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$licensesToAssign.AddLicenses = $license

Write-Host "Processing users"
# Traverse through user objects loaded from CSV
foreach($newUser in $newUsers)
{
    Write-Host "Creating user " $newUser.Email
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
                -MicrosoftOnlineServicesID $upn `
                -WarningAction "SilentlyContinue"

    Write-Host "    Changing usage location"
    # We need to set usage location for new user to assign license
    $user = Get-AzureAdUser -ObjectId $mb.ExternalDirectoryObjectId 
    $user | Set-AzureADUser -UsageLocation US
    
    Write-Host "    Assigning license"
    # Assign license to user
    $user | Set-AzureADUserLicense -AssignedLicenses $licensesToAssign    

    Write-Host "    Adding to Teams team"
    # Add user to Teams group
    Add-TeamUser -GroupId $team.GroupId -User $user.ObjectId -Role Member

    Write-Host "    Adding to AD group"
    # Add user to AD group
    Add-AzureADGroupMember -ObjectId $adGroup.ObjectId -RefObjectId $user.ObjectId
}

# Write out new users
$newUsers