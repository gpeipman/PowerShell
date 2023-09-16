# Credentiali salvestamine ja laadimine

Credential on tükike infot, mida kasutatakse sisse logimiseks. See koosneb kasutaja tunnusest ja paroolist. Credentiali saab korduvkasutuseks salvestada faili. Parooli selles failis lahtiselt ei hoita, vaid parool krüpteeritakse ära. Käesolev demo näitab kuidas credentialit küsida ja see faili salvestada. Samuti on siin näide credentiali laadimise kohta failist.

## Failid

- **cred.xml** - credentiali fail (XML formaadis)
- **persist-credential.ps1** - skript, mis credentialit küsib ja salvestab

## Märkused

Credentiali dialoogiga esineb hetkel (16.09.2023) tõrkeid Windows PowerShelli peal. Kui Get-Credential annab veateateid ja dialooge ei näita, siis üks variant on PowerShelli konsoolis avada uus tab ja lasta käsud seal käima. Teine variant on käivitada järgnev käsk vastu registryt (admini õigustes):

Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds" -Name "ConsolePrompting" -Value $True