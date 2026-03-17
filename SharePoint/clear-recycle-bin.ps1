  
Connect-PnPOnline `
    -Url "https://<tenant>.sharepoint.com/sites/<minu site>/" `
    -ClientId "<App client ID>" `
    -Tenant "<Azure tenanti ID>" `
    -CertificatePath "pnpdemo.pfx" `
    -CertificatePassword (ConvertTo-SecureString -AsPlainText "MinuTugevParool" -Force)
    
Clear-PnPRecycleBinItem -Force