param(
  [string]$reportJson = "$PSScriptRoot/../reports/report.json",
  [string]$allureResults = "$PSScriptRoot/../reports/allure-results"
)

if (-not (Test-Path $reportJson)) {
  Write-Host "No report.json found at $reportJson" -ForegroundColor Red
  exit 1
}

$report = Get-Content $reportJson | ConvertFrom-Json
New-Item -ItemType Directory -Path $allureResults -Force | Out-Null

# Clean previous results
Remove-Item "$allureResults/*" -Recurse -Force -ErrorAction SilentlyContinue

foreach ($test in $report.results) {
  $uuid = [guid]::NewGuid().ToString()
  $timestamp = (Get-Date -UFormat %s).Replace(',','.')

  $allureTest = @{
    uuid = $uuid
    historyId = $uuid
    fullName = $test.name
    labels = @(
      @{ name = "suite"; value = "TodoMVC" }
      @{ name = "testMethod"; value = $test.name }
      @{ name = "package"; value = "todomvc" }
      @{ name = "host"; value = $env:COMPUTERNAME }
    )
    links = @()
    name = $test.name
    status = if ($test.status -eq "passed") { "passed" } else { "failed" }
    stage = "finished"
    steps = @()
    attachments = @()
    parameters = @()
    start = [long]($timestamp * 1000)
    stop = [long]($timestamp * 1000 + 100)
  }

  if ($test.error) {
    $allureTest.statusDetails = @{
      message = $test.error
      trace = $test.error
    }
  }

  $filePath = "$allureResults/$uuid-result.json"
  $allureTest | ConvertTo-Json -Depth 5 | Set-Content $filePath -Encoding UTF8

  # Container
  $container = @{
    uuid = [guid]::NewGuid().ToString()
    name = "TodoMVC Suite"
    children = @($uuid)
    description = "Automated vibium tests for TodoMVC"
    befores = @()
    afters = @()
    links = @()
    start = [long]($timestamp * 1000)
    stop = [long]($timestamp * 1000 + 100)
  }
  $container | ConvertTo-Json -Depth 5 | Set-Content "$allureResults/$($container.uuid)-container.json" -Encoding UTF8
}

Write-Host "Allure results generated: $allureResults" -ForegroundColor Green
Write-Host "Run: allure generate $allureResults -o reports/allure-report --clean" -ForegroundColor Yellow
Write-Host "Then: allure open reports/allure-report" -ForegroundColor Yellow
