Param (
	$Group1,
	$Group2
)

$group1members = (Get-AdGroup $Group1 -Properties Member).Member
$group2members = (Get-AdGroup $Group2 -Properties Member).Member
$compare = Compare-Object $group1members $group2members -IncludeEqual

Write-Host "Users in both groups"
$compare | Where SideIndicator -eq "==" | Select @{ n="User"; e={ $PSItem.InputObject } } | Out-Host

Write-Host "Users only in group $Group1"
$compare | Where SideIndicator -eq "<=" | Select @{ n="User"; e={ $PSItem.InputObject } } | Out-Host

Write-Host "Users only in group $Group2"
$compare | Where SideIndicator -eq "=>" | Select @{ n="User"; e={ $PSItem.InputObject } } | Out-Host