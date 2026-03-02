# init-progress.ps1
# Creates the processing-status.csv from the original CSV

$projectRoot = "$PSScriptRoot + "\..""
$sourceFile = "$projectRoot\resale-report-pdfs\report-urls-with-pdf-links.csv"
$targetFile = "$projectRoot\batch\processing-status.csv"

# Read original CSV
$csv = Import-Csv $sourceFile

# Add new columns to each row
$csv | ForEach-Object {
    $_ | Add-Member -NotePropertyName 'Stage1Status' -NotePropertyValue '' -Force
    $_ | Add-Member -NotePropertyName 'Stage2Status' -NotePropertyValue '' -Force
    $_ | Add-Member -NotePropertyName 'Stage3Status' -NotePropertyValue '' -Force
    $_ | Add-Member -NotePropertyName 'Stage4Status' -NotePropertyValue '' -Force
    $_ | Add-Member -NotePropertyName 'Stage5Status' -NotePropertyValue '' -Force
    $_ | Add-Member -NotePropertyName 'FinalStatus' -NotePropertyValue '' -Force
    $_ | Add-Member -NotePropertyName 'LastUpdated' -NotePropertyValue '' -Force
    $_ | Add-Member -NotePropertyName 'Error' -NotePropertyValue '' -Force
}

# Export to new file
$csv | Export-Csv -Path $targetFile -NoTypeInformation -Encoding UTF8

Write-Host "Created $targetFile with $($csv.Count) rows"
Write-Host "Columns: Id, Slug, FilenameSuggestion, URL, PDF Report Link, Stage1Status, Stage2Status, Stage3Status, Stage4Status, Stage5Status, FinalStatus, LastUpdated, Error"
