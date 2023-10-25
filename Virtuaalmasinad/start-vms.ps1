param
(
    [string]$ResourceGroupName,
    [array]$ComputerNames
)

Import-Module Az

$ComputerNames | ForEach { Start-AzVm -ResourceGroupName $ResourceGroupName -Name $PSItem }