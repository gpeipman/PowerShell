# Credits to Mesut Talebi: https://medium.com/@mesut.talebi/using-iis-binding-and-powershell-to-apply-blue-green-deployment-strategy-and-acheived-zero-downtime-3ef07bdbc59e
param (
    [string]$blueSiteName = "GreenBlueLive",
    [string]$greenSiteName = "GreenBlueTest",
    [string]$ipAddress = "192.168.1.213",
    [int]$httpPort = 80,
    [int]$httpsPort = 443,
    [string]$certificateThumbprint = "20437383726bb2e609619ee345825c4854ab0598",
    [string]$certificateStore = "My"
)

Write-Host "Traffic switching from $greenSiteName to $blueSiteName ..."

# Import the WebAdministration module
Import-Module IISAdministration

# Display existing bindings for Blue environment
Write-Host "Existing bindings for $greenSiteName :"

$existingBindings = Get-IISSiteBinding -Name $greenSiteName

# Create a copy of the collection to avoid "Collection was modified" error
$bindingsCopy = @()

foreach ($binding in $existingBindings) {
	$bindingInfo = $binding.BindingInformation
# Do not copy green website's bindings, because we want keep them.
	if ($bindingInfo -notlike "*green*") {
		$bindingsCopy += $binding
	}
}

# Remove existing bindings for Blue environment
foreach ($binding in $bindingsCopy) {    
	$bindingInfo = $binding.BindingInformation
		
	Write-Host "Removing binding: $bindingInfo "
				
	Remove-IISSiteBinding -Name $greenSiteName -BindingInformation $bindingInfo -Confirm:$false  -Protocol $binding.Protocol -RemoveConfigOnly
}

#Reset-IISServerManager -Confirm:$false

# Add bindings for Green environment
foreach ($binding in $bindingsCopy) {
	if ($binding.Protocol -eq "http") {
		New-IISSiteBinding -Name $blueSiteName -BindingInformation $binding.BindingInformation -Protocol http
	}
	elseif ($binding.Protocol -eq "https") {
		New-IISSiteBinding -Name $blueSiteName -BindingInformation $binding.BindingInformation -CertificateThumbPrint $certificateThumbprint -CertStoreLocation "Cert:\LocalMachine\$certificateStore" -Protocol https
	}
	
}

#Reset-IISServerManager -Confirm:$false
Write-Host "Traffic switched from $greenSiteName to $blueSiteName"