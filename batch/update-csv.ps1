param(
    [string]$Slug,
    [string]$Column,
    [string]$Value,
    [string]$ErrorMessage = ""
)

$csvPath = "$PSScriptRoot + "\..\batch\processing-status.csv""
$csv = Import-Csv $csvPath

$row = $csv | Where-Object { $_.Slug -eq $Slug }
if ($row) {
    $row.$Column = $Value
    $row.LastUpdated = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    if ($ErrorMessage -ne "") {
        $row.Error = $ErrorMessage
    }
    $csv | Export-Csv $csvPath -NoTypeInformation -Encoding UTF8
    Write-Output "Updated $Column to $Value for $Slug"
} else {
    Write-Output "Row not found for slug: $Slug"
}
