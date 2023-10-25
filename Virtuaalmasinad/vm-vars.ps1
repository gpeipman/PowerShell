# Variables for common values
$resourceGroup = "KoolitusRG"
$location = "westeurope"
$vmName = "KoolitusVM"
$vmSize = "Standard_DS2_v2"

$sshUserName = "tom"
$sshPassword = "P@ssw0rd123!!"
$subnetName = "mySubnet"
$subnetAddressPrefix = "192.168.1.0/24"
$vnetName = "MyvNET"
$vnetAddressPrefix = "192.168.0.0/16"
$nsgSshName = "myNetworkSecurityGroupRuleSSH"
$nsgHttpName = "myNetworkSecurityGroupRuleHTTP"
$nsgName = "myNetworkSecurityGroup"
$nicName = "myNic"
$nginxExtensionName = "NGINX"

# --------------------- DON'T TOUCH -------------------

# Define user name and blank password (never put a secret in code, but for this demo it is OK)
$securePassword = ConvertTo-SecureString $sshPassword -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($sshUserName, $securePassword)

# Create a resource group
Write-Host "Creating resource group"
New-AzResourceGroup -Name $resourceGroup -Location $location

# Create a subnet configuration
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetAddressPrefix

# Create a virtual network
Write-Host "Creating virtual network"
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroup -Location $location `
-Name $vnetName -AddressPrefix $vnetAddressPrefix -Subnet $subnetConfig

# Create a public IP address and specify a DNS name
Write-Host "Creating public IP"
$pip = New-AzPublicIpAddress -ResourceGroupName $resourceGroup -Location $location `
-Name "mypublicdns$(Get-Random)" -AllocationMethod Static -IdleTimeoutInMinutes 4

# Create an inbound network security group rule for port 22
$nsgRuleSSH = New-AzNetworkSecurityRuleConfig -Name $nsgSshName -Protocol Tcp `
-Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
-DestinationPortRange 22 -Access Allow

# Create an inbound network security group rule for port 80
$nsgRuleHTTP = New-AzNetworkSecurityRuleConfig -Name $nsgHttpName -Protocol Tcp `
-Direction Inbound -Priority 2000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
-DestinationPortRange 80 -Access Allow

# Create a network security group
Write-Host "Creating network security group"
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location `
-Name $nsgName -SecurityRules $nsgRuleSSH,$nsgRuleHTTP

# Create a virtual network card and associate with public IP address and NSG
Write-Host "Creating network interface"
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroup -Location $location `
-SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Create a virtual machine configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize | `
Set-AzVMOperatingSystem -Linux -ComputerName $vmName -Credential $cred | `
Set-AzVMSourceImage -PublisherName Canonical -Offer UbuntuServer -Skus 18.04-LTS -Version latest | `
Add-AzVMNetworkInterface -Id $nic.Id

# Create a virtual machine
Write-Host "Creating virtual machine"
New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig

# Install NGINX.
$PublicSettings = '{"commandToExecute":"apt-get -y update && apt-get -y install nginx"}'
Write-Host "Creating nginx extension"
Set-AzVMExtension -ExtensionName $nginxExtensionName -ResourceGroupName $resourceGroup -VMName $vmName `
-Publisher "Microsoft.Azure.Extensions" -ExtensionType "CustomScript" -TypeHandlerVersion 2.0 `
-SettingString $PublicSettings -Location $location