# MPP Batch Orchestrator - Fresh session per report
# Supports interruption/resumption via CSV state

param(
    [int]$Limit = 0,
    [switch]$Status,
    [int]$PauseBetween = 5  # Seconds between reports
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

# Pass-through status check
if ($Status) {
    & "$PSScriptRoot\run-orchestrator.ps1" -Status
    exit 0
}

$csvPath = "$ProjectRoot\batch\processing-status.csv"
$csv = Import-Csv $csvPath
$pending = $csv | Where-Object { $_.FinalStatus -ne "completed" }

if ($Limit -gt 0) {
    $pending = $pending | Select-Object -First $Limit
}

$total = ($pending | Measure-Object).Count
if ($total -eq 0) {
    Write-Host "No pending reports." -ForegroundColor Green
    exit 0
}

Write-Host "=== MPP Batch Processing ===" -ForegroundColor Cyan
Write-Host "Pending: $total reports" -ForegroundColor Yellow
Write-Host "Each report runs in fresh Claude Code session"
Write-Host "Ctrl+C to stop - resume anytime with same command"
Write-Host ""

$i = 0
foreach ($report in $pending) {
    $i++
    $slug = $report.Slug

    Write-Host "`n[$i/$total] Processing: $slug" -ForegroundColor Cyan
    Write-Host "----------------------------------------"

    # Fresh session per report
    & "$PSScriptRoot\run-orchestrator.ps1" -Slug $slug

    # Re-read CSV to check result
    $updated = Import-Csv $csvPath | Where-Object { $_.Slug -eq $slug }
    $reportStatus = $updated.FinalStatus

    if ($reportStatus -eq "completed") {
        Write-Host "Completed: $slug" -ForegroundColor Green
    } else {
        Write-Host "Status: $reportStatus" -ForegroundColor Yellow
    }

    if ($i -lt $total) {
        Write-Host "Next report in $PauseBetween seconds... (Ctrl+C to stop)" -ForegroundColor Gray
        Start-Sleep -Seconds $PauseBetween
    }
}

Write-Host "`n=== Batch Complete ===" -ForegroundColor Green
