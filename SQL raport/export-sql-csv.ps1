# Kui masinasse paigaldatud SQL Serveri vahendid on installinud vanema 
# SQL Serveri PowerShelli mooduli, siis lae see sessioonist maha. Seejärel
# impordi uuem SQL Serveri moodul.
Remove-Module SQLPS
Import-Module SqlServer

# Koosta ühenduse string ja päring ning saada päring serverisse
$connectionString = "<your connection string here>"
$sql = "select top 10 * from Person.Address"
$data = invoke-sqlcmd $sql -ConnectionString $connectionString 

# Ekspordi päringu tulemused CSV-sse
$data | Export-Csv -Path .\addresses.csv -NoTypeInformation -Delimiter "`t"