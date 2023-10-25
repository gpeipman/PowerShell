# Virtuaalmasinad

Skriptid Azure virtuaalmasinate loomiseks ja nendega tegelemiseks.

## Failid

- **start-vms.ps1** - käivitab antud ressursigruppi kuuluvad virtuaalmasinad (mõeldud virtuaalmasinate jaoks, mis tööpäeva lõpus automaatselt suletakse)
- **vm.ps1** - algne skript virtuaalmasina loomiseks (allikas skripti alguses), luuakse virtuaalmasin, kuhu paigaldatakse NGINX-veebiserver
- **vm-vars.ps2** - eelmise skripti muudatus, kus skripti jõuga kirjutatud väärtused on skripti alguses defineeritud muutujatena