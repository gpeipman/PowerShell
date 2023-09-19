# Office 365 kontode loomine õpilastele

Skript loeb failist sisse kontod, mis tuleb Office 365 peale luua, genereerib paroolid, loob kontod, omistab neile litsentsid ja lisab need Teamsi gruppi. Skript küsib parooli ainult korra ning salvestab selle PowerShelli credentialina XML-formaadis kettale. Kui cred.xml fail on olemas, siis püüab skript sealt sisselogimise info kätte saada.

## Failid

- **create-password.ps1** - sisaldab parooli genereerimise funktsiooni
- **cred.xml** - sisaldab Office 365 sisse logimise infot XML-is (PowerShelli credential)
- **import-accounts.ps1** - skript, mis importimiseks käima tuleb lasta
- **it21e.csv** - andmefail loodavate kontode infoga

## Seaded

Skripti alguses saab määrata seadeid:

- **domain** - Office 365 domeen, milles tegutseme
- **fileName** - andmefaili nimi
- **teamName** - Teamsi grupi nimi, kuhu kasutajad lisada
- **licenseSku** - määrab litsentsi, mis uutele kasutajatele omistatakse (litsentside loendi saab kätte käsuga Get-AzureADSubscribedSku)

## Märkused

- Credentiali dialoogiga esineb hetkel (16.09.2023) tõrkeid Windows PowerShelli peal. Kui Get-Credential annab veateateid ja dialooge ei näita, siis üks variant on PowerShelli konsoolis avada uus tab ja lasta käsud seal käima. Teine variant on käivitada järgnev käsk vastu registryt (admini õigustes):  
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds" -Name "ConsolePrompting" -Value $True
- Skript töötab kontodega, millel pole MFA aktiveeritud (näiteks rakenduste kontod, mida skriptide juures laialdaselt kasutatakse)
- Teamsi gruppidesse kasutajate lisandumine võib võtta aega. Microsofti poolt on selline hoiatus: ***The command will return immediately, but the Teams application will not reflect the update immediately. The change can take between 24 and 48 hours to appear within the Teams client.***