# Kontrolli kas credentiali fail eksisteerib
if(Test-Path -Path cred.xml -PathType Leaf)
{
    # Fail on olemas, laadime selle sisse
    $cred = Import-Clixml cred.xml
}
else 
{
    # Faili pole. Küsi credential ja salvesta see faili
    $cred = Get-Credential
    $cred | Export-Clixml -Path cred.xml
}

# Kirjuta credential välja
$cred