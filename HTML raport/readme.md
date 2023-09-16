# HTML raporti genereerimine

Skript loeb andmed sisse data.csv failist, kus on toodud kliendid ning nende arvete ja maksete kogusummad. PowerShelli pipeline abil lisatakse sisendandmetele kliendi saldo veerg ning filtreeritakse välja võlglased (negatiivse saldoga kliendid). Võlglaste andmed sorteeritakse ära ja seejärel tehakse neist HTML raport, mis kirjutatakse faili sample-report.html.

## Failid

- **data.cvs** - demo jaoks mõeldud andmed
- **sample-report.html** - valmis genereeritud raport
- **report.ps1** - skript, mis raporti genereerib

## Märkused

Valmis genereeritud HTML sisaldab ka stiilide plokki. See tähendab seda, et raporti saab avada ka lokaalse masina kettalt ilma, et brauseritega tõrkeid tekiks. Samuti saab raporti edastada huvilistele e-posti vahendusel.