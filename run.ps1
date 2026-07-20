param(
  [switch]$headless = $false,
  [string]$url = "https://example.com",
  [string]$test = "tests/template.ps1"
)

$testScript = "$PSScriptRoot/$test"
if (-not (Test-Path $testScript)) {
  Write-Host "Test introuvable : $testScript" -ForegroundColor Red
  exit 1
}

Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       Vibium Test Runner             ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host "  Target: $url"
Write-Host "  Mode: $(if($headless){'Headless'}else{'Headed'})"
Write-Host "  Test: $(Split-Path $testScript -Leaf)`n"

vibium stop 2>$null
$startArgs = @('start')
if ($headless) { $startArgs += '--headless' }
& vibium $startArgs

Write-Host "`nLaunching test suite: $testScript`n" -ForegroundColor Yellow
& $testScript -url $url

vibium stop 2>$null
Write-Host "Done." -ForegroundColor Cyan
