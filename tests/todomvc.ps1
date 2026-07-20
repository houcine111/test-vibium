param(
  [string]$url = "https://demo.playwright.dev/todomvc",
  [string]$screenshotDir = "$PSScriptRoot/../screenshots",
  [string]$reportFile = "$PSScriptRoot/../reports/report.json"
)

$results = @()
$passed = 0
$failed = 0

function Test-Step {
  param($name, $script)
  Write-Host "▶ $name" -ForegroundColor Cyan
  try {
    $result = Invoke-Command -ScriptBlock $script
    $results += @{ name = $name; status = "passed" }
    $global:passed++
    Write-Host "  ✓ PASS" -ForegroundColor Green
    return $result
  } catch {
    $results += @{ name = $name; status = "failed"; error = $_.Exception.Message }
    $global:failed++
    Write-Host "  ✗ FAIL: $_" -ForegroundColor Red
    return $null
  }
}

function Screenshot {
  param($name)
  vibium screenshot -o "$screenshotDir/$name.png" --full-page | Out-Null
}

# Ensure screenshots dir exists
New-Item -ItemType Directory -Path $screenshotDir -Force | Out-Null

Write-Host "`n═══════════════════════════════════════" -ForegroundColor Yellow
Write-Host "  TodoMVC Test Suite" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════`n" -ForegroundColor Yellow

# ── Setup ──────────────────────────────────
Test-Step "Navigate to TodoMVC" { vibium go $url }
Screenshot "00-initial"

# ── 1. Add Todos ──────────────────────────
Test-Step "Add: Buy groceries" {
  vibium fill "input[placeholder='What needs to be done?']" "Buy groceries"
  vibium press Enter "input[placeholder='What needs to be done?']"
}
Test-Step "Add: Walk the dog" {
  vibium fill "input[placeholder='What needs to be done?']" "Walk the dog"
  vibium press Enter "input[placeholder='What needs to be done?']"
}
Test-Step "Add: Write tests" {
  vibium fill "input[placeholder='What needs to be done?']" "Write tests"
  vibium press Enter "input[placeholder='What needs to be done?']"
}
Screenshot "01-three-todos"

# ── 2. Mark Complete ──────────────────────
Test-Step "Complete: first todo" {
  vibium click ".todo-list li:nth-child(1) .toggle"
}
Screenshot "02-first-completed"

# ── 3. Edit Todo ──────────────────────────
Test-Step "Edit: second todo" {
  vibium dblclick ".todo-list li:nth-child(2) label"
  vibium fill ".todo-list li:nth-child(2) .edit" "Walk the dog daily"
  vibium press Enter ".todo-list li:nth-child(2) .edit"
}
Screenshot "03-edited"

# ── 4. Delete Todo ────────────────────────
Test-Step "Delete: third todo" {
  vibium hover ".todo-list li:nth-child(3)"
  Start-Sleep -Milliseconds 300
  vibium click ".todo-list li:nth-child(3) .destroy"
}
Screenshot "04-deleted"

# ── 5. Clear Completed ────────────────────
Test-Step "Clear completed" {
  vibium click ".clear-completed"
}
Screenshot "05-cleared"

# ── 6. Filters ────────────────────────────
Test-Step "Add more for filter tests" {
  vibium fill "input[placeholder='What needs to be done?']" "Read a book"
  vibium press Enter "input[placeholder='What needs to be done?']"
  vibium fill "input[placeholder='What needs to be done?']" "Learn Svelte"
  vibium press Enter "input[placeholder='What needs to be done?']"
  vibium click ".todo-list li:nth-child(2) .toggle"  # complete one
}
Test-Step "Filter: Active" { vibium click "a[href='#/active']" }
Screenshot "06-filter-active"
Test-Step "Filter: Completed" { vibium click "a[href='#/completed']" }
Screenshot "07-filter-completed"
Test-Step "Filter: All" { vibium click "a[href='#/']" }
Screenshot "08-filter-all"

# ── 7. Toggle All ─────────────────────────
Test-Step "Toggle all" { vibium click ".toggle-all" }
Screenshot "09-toggle-all"

# ── 8. Edge Cases ─────────────────────────
Test-Step "Edge: empty input" {
  vibium press Enter "input[placeholder='What needs to be done?']"
}
Test-Step "Edge: whitespace only" {
  vibium fill "input[placeholder='What needs to be done?']" "   "
  vibium press Enter "input[placeholder='What needs to be done?']"
}
Test-Step "Edge: XSS injection" {
  vibium fill "input[placeholder='What needs to be done?']" "<script>alert('XSS')</script>"
  vibium press Enter "input[placeholder='What needs to be done?']"
}
Test-Step "Edge: duplicate" {
  vibium fill "input[placeholder='What needs to be done?']" "Buy groceries"
  vibium press Enter "input[placeholder='What needs to be done?']"
}
Screenshot "10-edge-cases"

# ── 9. Persistence ────────────────────────
Test-Step "Persistence: reload" { vibium reload }
Screenshot "11-after-reload"

# ── 10. Cleanup ───────────────────────────
vibium click ".clear-completed" | Out-Null

# ── Report ────────────────────────────────
$summary = @{
  date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  total = $passed + $failed
  passed = $passed
  failed = $failed
  results = $results
  screenshots = @(Get-ChildItem $screenshotDir/*.png | % { $_.Name })
}
$summary | ConvertTo-Json -Depth 3 | Set-Content $reportFile

Write-Host "`n═══════════════════════════════════════" -ForegroundColor Yellow
Write-Host "  Results: $passed passed, $failed failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host "  Report: $reportFile" -ForegroundColor Gray
Write-Host "  Screenshots: $screenshotDir" -ForegroundColor Gray
Write-Host "═══════════════════════════════════════`n" -ForegroundColor Yellow
