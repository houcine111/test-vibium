param(
  [switch]$headless = $false,
  [switch]$allure = $false,
  [string]$url = "",
  [string]$test = "tests/todomvc.ps1"
)

# Load config if exists
$configFile = "$PSScriptRoot/config.json"
if (Test-Path $configFile) {
  $config = Get-Content $configFile | ConvertFrom-Json
  if (-not $url) { $url = $config.url }
  if (-not $test) { $test = "tests/$($config.name).ps1" }
}
if (-not $url) { $url = "https://example.com" }

$testScript = "$PSScriptRoot/$test"
if (-not (Test-Path $testScript)) { $testScript = "$PSScriptRoot/tests/template.ps1" }

Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       Vibium Test Runner             ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host "  Target: $url"
Write-Host "  Mode: $(if($headless){'Headless'}else{'Headed'})"
Write-Host "  Test: $(Split-Path $testScript -Leaf)"
Write-Host "  Allure: $(if($allure){'Yes'}else{'No'})`n"

# 1. Stop any previous session
vibium stop 2>$null

# 2. Start fresh browser
$startArgs = @('start')
if ($headless) { $startArgs += '--headless' }
& vibium $startArgs

# 3. Run tests
Write-Host "`nLaunching test suite: $testScript`n" -ForegroundColor Yellow
& $testScript -url $url

# 4. Allure report (optional)
if ($allure) {
  Write-Host "`nGenerating Allure report..." -ForegroundColor Yellow
  & "$PSScriptRoot/scripts/allure-convert.ps1"
  allure generate "$PSScriptRoot/reports/allure-results" -o "$PSScriptRoot/reports/allure-report" --clean
  Write-Host "Allure report: $PSScriptRoot/reports/allure-report/index.html" -ForegroundColor Green
}

# 5. Cleanup
vibium stop 2>$null

Write-Host "`nDone." -ForegroundColor Cyan
