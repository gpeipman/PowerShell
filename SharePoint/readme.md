# SharePoint

**NB!** SharePointi näidete jaoks tuleb kasutada PowerShell 7.4 või uuemat!

Moodulite installeerimisel veenduge, et mooduleid ei ole vanemates PowerShell 5.1 kaustades juba olemas. Kui on, siis sulgege kõik PowerShelli aknad ning eemaldage need moodulid käsitsi. Seejärel käivitage PowerShell 7 ja installige vajaminevad moodulid.

## Liigsete versioonide eemaldamine 

Vaja on Azure AD/Entra peal kontot, mis kasutab App key autentimist. API õigustest on vaja järgmisi: "Sites.ReadWrite.All","Files.ReadWrite.All". Käsu tööks on vaja Microsoft Graphi moodulit (Microsoft.Graph).

### Failid

- **remove-versions.ps1** - faili alguses on kirjas sait, millest otsitakse versioone. See fail jätab alles ainult nii palju versioone dokumentidest kui on faili alguses öeldud.

## Prügikastide tühjendamine

Vaja on Azure AD/Entra peal kontot, mis kasutab App key autentimist sertifikaadiga. Lisaks on vaja PnP.PowerShell moodulit.

Sertifikaadi loomiseks saab peale mooduli paigaldamist kasutada järgmist käsku:

<pre>
New-PnPAzureCertificate `
  -CommonName "PnP Demo Cert" `
  -OutPfx pnpdemo.pfx `
  -OutCert pnpdemo.cer `
  -CertificatePassword (ConvertTo-SecureString "MinuTugevParool" -AsPlainText –Force)
</pre>

### Failid

- **clear-rycyle-bin.ps1** - logib sisse sertifikaadi ja App-keyga ning tühjendab faili alguses toodud saidi prügikasti.