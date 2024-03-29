# Credits: https://techcommunity.microsoft.com/t5/azure-compute/using-the-powershell-in-azure-to-provide-a-linux-vm-virtual/m-p/1795729
# Thanks for excellent work :)

# Variables for common values
$resourceGroup = "myResourceGroup"
$location = "westeurope"
$vmName = "myVM"

# Define user name and blank password (never put a secret in code, but for this demo it is OK)
$securePassword = ConvertTo-SecureString 'P@ssw0rd123!!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("tom", $securePassword)

# Create a resource group
New-AzResourceGroup -Name $resourceGroup -Location $location

# Create a subnet configuration
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name mySubnet -AddressPrefix 192.168.1.0/24

# Create a virtual network
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroup -Location $location `
-Name MYvNET -AddressPrefix 192.168.0.0/16 -Subnet $subnetConfig

# Create a public IP address and specify a DNS name
$pip = New-AzPublicIpAddress -ResourceGroupName $resourceGroup -Location $location `
-Name "mypublicdns$(Get-Random)" -AllocationMethod Static -IdleTimeoutInMinutes 4

# Create an inbound network security group rule for port 22
$nsgRuleSSH = New-AzNetworkSecurityRuleConfig -Name myNetworkSecurityGroupRuleSSH -Protocol Tcp `
-Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
-DestinationPortRange 22 -Access Allow

# Create an inbound network security group rule for port 80
$nsgRuleHTTP = New-AzNetworkSecurityRuleConfig -Name myNetworkSecurityGroupRuleHTTP -Protocol Tcp `
-Direction Inbound -Priority 2000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
-DestinationPortRange 80 -Access Allow

# Create a network security group
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location `
-Name myNetworkSecurityGroup -SecurityRules $nsgRuleSSH,$nsgRuleHTTP

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzNetworkInterface -Name myNic -ResourceGroupName $resourceGroup -Location $location `
-SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Create a virtual machine configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize Standard_DS2_v2 | `
Set-AzVMOperatingSystem -Linux -ComputerName $vmName -Credential $cred | `
Set-AzVMSourceImage -PublisherName Canonical -Offer UbuntuServer -Skus 18.04-LTS -Version latest | `
Add-AzVMNetworkInterface -Id $nic.Id

# Create a virtual machine
New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig

# Install NGINX.
$PublicSettings = '{"commandToExecute":"apt-get -y update && apt-get -y install nginx"}'

Set-AzVMExtension -ExtensionName "NGINX" -ResourceGroupName $resourceGroup -VMName $vmName `
-Publisher "Microsoft.Azure.Extensions" -ExtensionType "CustomScript" -TypeHandlerVersion 2.0 `
-SettingString $PublicSettings -Location $location