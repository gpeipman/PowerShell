# File with input data
$dataFileName = "data.csv"

# In-line css for report (localhost doesn't load CSS files)
$styles = "<style>
body { font-family: segoeui, arial }
table, td, th { border-collapse: collapse; border: 1px solid darkgray }
td, th { padding: 5px }
th { background-color: lightgrey }
</style>"

# Report title
$title = "Debtors"

# Today's date
$date = Get-Date

# Import CSV file with data, create calculated property called Balance, 
# find debtors, order them by debt and compose HTML file with debtors
Import-Csv $dataFileName -Delimiter ";" |
            Select ID,Customer,InvoicesTotal,PaymentsTotal, 
                    @{ n="Balance"; e={$PSItem.PaymentsTotal-$PSItem.InvoicesTotal}} |
            Where Balance -lt 0 |
            Sort Balance |
            ConvertTo-Html -Title $title -PreContent "<h1>$title</h1>" -Head $styles -PostContent "<p>Report generated: $date</p>" |
            Out-File report.html
