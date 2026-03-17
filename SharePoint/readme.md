# SharePoint

## Liigsete versioonide eemaldamine 

Vaja on Azure AD/Entra peal kontot, mis kasutab App key autentimist. API õigustest on vaja järgmisi: "Sites.ReadWrite.All","Files.ReadWrite.All".

### Failid

- **remove-versions.ps1** - faili alguses on kirjas sait, millest otsitakse versioone. See fail jätab alles ainult nii palju versioone dokumentidest kui on faili alguses öeldud.