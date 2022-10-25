# Check if credential file exists
if(Test-Path -Path cred.xml -PathType Leaf)
{
    # File exists, let's load credential from file
    $cred = Import-Clixml cred.xml
}
else 
{
    # Ask credential using Windows login dialog
    $cred = Get-Credential
    
    # Save credential to file
    $cred | Export-Clixml -Path cred.xml
}

# Write out credential
$cred