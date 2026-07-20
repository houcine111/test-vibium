param(
  [string]$url = "https://example.com",
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

New-Item -ItemType Directory -Path $screenshotDir -Force | Out-Null

Write-Host "`n═══════════════════════════════════════" -ForegroundColor Yellow
Write-Host "  Test Suite" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════`n" -ForegroundColor Yellow

# ── Ouvre l'app ───────────────────────────
Test-Step "Naviguer vers $url" { vibium go $url }
Screenshot "01-accueil"

# ── Exemple : lire le contenu ─────────────
Test-Step "Lire le titre de la page" {
  $title = vibium title
  if (-not $title) { throw "Titre vide" }
}
Screenshot "02-page-chargee"

# ── TODO : ajoute tes tests ici ───────────
# Test-Step "Cliquer sur connexion" { vibium click "a[href='/login']" }
# Test-Step "Remplir email" { vibium fill "input[name=email]" "user@test.com" }

# ── Rapport ────────────────────────────────
$summary = @{
  date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  app = $url
  total = $passed + $failed
  passed = $passed
  failed = $failed
  results = $results
  screenshots = @(Get-ChildItem $screenshotDir/*.png | % { $_.Name })
}
$summary | ConvertTo-Json -Depth 3 | Set-Content $reportFile

Write-Host "`n═══════════════════════════════════════" -ForegroundColor Yellow
Write-Host "  Results: $passed passed, $failed failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host "═══════════════════════════════════════`n" -ForegroundColor Yellow
