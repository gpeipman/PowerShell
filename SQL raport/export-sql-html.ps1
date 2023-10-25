# Kui masinasse paigaldatud SQL Serveri vahendid on installinud vanema 
# SQL Serveri PowerShelli mooduli, siis lae see sessioonist maha. Seejärel
# impordi uuem SQL Serveri moodul.
Remove-Module SQLPS
Import-Module SqlServer

# Koosta ühenduse string ja päring ning saada päring serverisse
$connectionString = "<your connection string here>"
$data = Invoke-SqlCmd "select top 100 * from Person.Address" -ConnectionString $connectionString

# Määra lehe pealkiri, raporti genereerimise aeg ja defineeri stiilid
$title = "Addresses"
$date = Get-Date
$styles = "
    <style> 
    body { font-family: segoeui, arial }
    table, td, th { border-collapse: collapse; border: 1px solid darkgray; }
    td, th { padding: 5px }
    th { background-color: lightgrey }
    </style>
"
# Ekspordi päringu tulemused HTML-i
$data |  
    Select -Property AddressID, AddressLine1, AddressLine2, City, PostalCode | 
    ConvertTo-Html -Title $title -PreContent "<h1>$title</h1>" -PostContent "<p>Report generated: $date</p>" -Head $styles | 
    Out-File Addresses.html