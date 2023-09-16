# SQL Serveri päringust CSV loomine

Skript ühendub SQL Serverisse, käivitab päringu ning salvestab tulemused CSV failina. Veergude eraldajana kasutatakse semikoolonit (;), et fail oleks Exceliga avatav ilma täiendavate tegevusteta lõppkasutaja poolt.

## Failid

- **addresses.csv** - demokeskkonnas loodud väljundfail klientide aadressidest
- **export-sql.csv** - skript, mis SQL Serverist andmed toob ja CSV faili teeb

## Märkused

- See näide kasutab SQL Serveri näiteandmebaasi AdventureWorks2019, mille saab tasuta allalaadida [SQL Serveri demoandmebaaside lehelt](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure)
- SQL Serveri ühenduse stringide kohta leiab näiteid [connectionstrings.com](https://www.connectionstrings.com/) lehelt
- Kui SQL Serverisse logitakse sisse domeeni või Windowsi kontoga, siis saab kasutada näiteks sellist ühenduse stringi:  
  "Data Source=(local); Initial Catalog=AdventureWorks2019; Integrated Security=True; Encrypt=No"
    - Data source - serveri DSN-i nimi või IP, (local) tähendab SQL Serverit samas masinas
    - Initial Catalog - andmebaas, millesse ühenduse loomisel sisenetakse
    - Integrated Security - kui True, siis kasutame domeeni või Windowsi kontot sisse logimiseks
    - Encrypt - kui andmevahetus serveriga ei toimu üle SSL-i (demo- ja testkeskkonnad), siis No