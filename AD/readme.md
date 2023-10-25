# Active Directory näited

## Failid

- **Compare-AdGroups.ps1** - Skript kahe AD grupi võrdlemiseks. Skript toob eraldi välja kasutajad, kes on mõlemas grupis ning kes on esimeses ja teises võrreldavas grupis. Skripti saab kasutada nagu igat teist PowerShelli käsku: Compare-AdGroups Grupp1 Grupp 2

- **Compare-AdUsersByGroups.ps1** - Võrdleb kahe AD kasutaja kuulumist gruppidesse. Toob välja ühised grupid ning grupid kuhu ainult esimene või teine kasutaja kuulub. Skripti saab käivitada nagu PowerShelli käsu: Compare-AdUsersByGroups johndoe janedoe