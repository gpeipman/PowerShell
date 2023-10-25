param (
    $user1,
    $user2
)

$memberships1 = (Get-ADUser -Identity $user1 -Properties MemberOf | Select-Object MemberOf).MemberOf
$memberships2 = (Get-ADUser -Identity $user2 -Properties MemberOf | Select-Object MemberOf).MemberOf

$compare = Compare-Object $memberships1 $memberships2 -IncludeEqual

Write-Host "Both are members of"
$compare | Where SideIndicator -eq "==" | Select @{ n="Group"; e={ $PSItem.InputObject } } | Out-Host

Write-Host "$user1 is only in groups"
$compare | Where SideIndicator -eq "<=" | Select @{ n="Group"; e={ $PSItem.InputObject } } | Out-Host

Write-Host "$user2 is only in groups"
$compare | Where SideIndicator -eq "=>" | Select @{ n="Group"; e={ $PSItem.InputObject } } | Out-Host