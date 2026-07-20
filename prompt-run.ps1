param(
  [string]$prompt = ""
)

Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║   Prompt → Test : Générateur IA      ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Magenta

# ── Demander le prompt si pas fourni ─────
if (-not $prompt) {
  Write-Host "`nDécris ce que tu veux tester :" -ForegroundColor Yellow
  Write-Host "  Ex: ""va sur https://example.com/login et teste la connexion""" -ForegroundColor Gray
  Write-Host "  Ex: ""ouvre mon-app.com, ajoute un article au panier et vérifie le total""" -ForegroundColor Gray
  $prompt = Read-Host "`n> "
}

if (-not $prompt) { Write-Host "Annulé." -ForegroundColor Red; exit 1 }

Write-Host "`nAnalyse du prompt..." -ForegroundColor Cyan

# ── Extraire l'URL du prompt ─────────────
$url = ""
if ($prompt -match 'https?://[^\s]+') {
  $url = $matches[0]
} elseif ($prompt -match '(?:va sur|ouvre|navigue vers?|goto|open|visit)\s+(\S+)') {
  $domain = $matches[1]
  if (-not $domain.StartsWith("http")) { $domain = "https://$domain" }
  $url = $domain
}

if (-not $url) {
  Write-Host "Aucune URL trouvée dans le prompt. Donne une URL :" -ForegroundColor Yellow
  $url = Read-Host "URL"
}
if (-not $url) { Write-Host "Annulé." -ForegroundColor Red; exit 1 }

Write-Host "`nÉtape 1 : Navigation vers $url" -ForegroundColor Green
vibium stop 2>$null
vibium start | Out-Null
vibium go $url

Write-Host "`nÉtape 2 : Exploration de la page..." -ForegroundColor Green
$map = vibium map
Write-Host $map

$pageText = vibium text

Write-Host "`nÉtape 3 : Génération du script de test..." -ForegroundColor Green

# ── Extraire les actions du prompt ───────
$actions = @()
if ($prompt -match '(?:click|clique|appuie|press|cliquer)\s+(?:sur\s+)?[""“]?([^""""“”]+)[""”]?') {
  $actions += @{ type = "click"; target = $matches[1] }
}
if ($prompt -match '(?:fill|remplir|taper|type|écrire|saisir|write)\s+(?:[""“]?([^""""“”]+)[""”]?\s+(?:dans|in|sur|into)\s+[""“]?([^""""“”]+)[""”]?)') {
  $actions += @{ type = "fill"; text = $matches[1]; target = $matches[2] }
}
if ($prompt -match '(?:test|vérifier|check|verify|assert)') {
  $actions += @{ type = "verify" }
}

# ── Extraire les éléments map pour référence ──
$refs = @()
$map -split "`n" | ForEach-Object {
  if ($_ -match '@e\d+\s+\[([^\]]+)\]\s+"([^"]*)"') {
    $refs += @{ ref = $matches[0]; selector = "[$($matches[1])]"; text = $matches[2] }
  }
}

# ── Générer le script ────────────────────
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$testName = "prompt-$timestamp"
$testFile = "$PSScriptRoot/tests/$testName.ps1"

$scriptContent = @"
param(
  [string]${url} = "$url",
  [string]`$screenshotDir = "$PSScriptRoot/screenshots",
  [string]`$reportFile = "$PSScriptRoot/reports/report.json"
)

`$results = @()
`$passed = 0
`$failed = 0

function Test-Step {
  param(`$name, `$script)
  Write-Host "▶ `$name" -ForegroundColor Cyan
  try {
    & `$script
    `$results += @{ name = `$name; status = "passed" }
    `$global:passed++
    Write-Host "  ✓ PASS" -ForegroundColor Green
  } catch {
    `$results += @{ name = `$name; status = "failed"; error = `$_.Exception.Message }
    `$global:failed++
    Write-Host "  ✗ FAIL: `$_" -ForegroundColor Red
  }
}

function Screenshot {
  param(`$name)
  vibium screenshot -o "`$screenshotDir/`$name.png" --full-page | Out-Null
}

New-Item -ItemType Directory -Path `$screenshotDir -Force | Out-Null

Write-Host "`n═══════════════════════════════════════" -ForegroundColor Yellow
Write-Host "  Test : $prompt" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════`n" -ForegroundColor Yellow

"@

# Ajouter les étapes générées
$scriptContent += "# ── Navigation ──────────────────────────`n"
$scriptContent += "Test-Step ""Charger la page"" { vibium go `$url }`n"
$scriptContent += "Screenshot ""01-accueil""`n`n"

$scriptContent += "# ── Tests générés ──────────────────────`n"

if ($actions.Count -gt 0) {
  foreach ($action in $actions) {
    switch ($action.type) {
      "click" {
        $safeTarget = $action.target -replace "'", "''"
        $scriptContent += "Test-Step ""Cliquer sur $safeTarget"" {`n"
        $scriptContent += "  vibium click ""$safeTarget""`n"
        $scriptContent += "}`n"
      }
      "fill" {
        $safeTarget = $action.target -replace "'", "''"
        $safeText = $action.text -replace "'", "''"
        $scriptContent += "Test-Step ""Remplir $safeTarget"" {`n"
        $scriptContent += "  vibium fill ""$safeTarget"" ""$safeText""`n"
        $scriptContent += "}`n"
      }
      "verify" {
        $scriptContent += "Test-Step ""Vérifier le contenu"" {`n"
        $scriptContent += "  `$text = vibium text`n"
        $scriptContent += "  if (-not `$text) { throw ""Page vide"" }`n"
        $scriptContent += "}`n"
      }
    }
  }
} else {
  # Si aucune action détectée, générer des étapes basées sur la map
  $scriptContent += "# Actions suggérées basées sur la map :`n"
  $scriptContent += "Test-Step ""Lire le titre de la page"" {`n"
  $scriptContent += "  `$title = vibium title`n"
  $scriptContent += "  if (-not `$title) { throw ""Pas de titre"" }`n"
  $scriptContent += "}`n"
  $scriptContent += "Screenshot ""02-page""`n"
  $scriptContent += "`n"
  $scriptContent += "# Ajoute ici tes actions personnalisées`n"
  $scriptContent += "# Exemples :`n"
  $scriptContent += "# Test-Step ""Remplir email"" { vibium fill ""input[name=email]"" ""test@test.com"" }`n"
  $scriptContent += "# Test-Step ""Soumettre"" { vibium click ""button[type=submit]"" }`n"
}

$scriptContent += @"

Screenshot ""99-final""

# ── Rapport ────────────────────────────────
`$summary = @{
  date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  prompt = "$prompt"
  app = `$url
  total = `$passed + `$failed
  passed = `$passed
  failed = `$failed
  results = `$results
  screenshots = @(Get-ChildItem `$screenshotDir/*.png | % { `$_.Name })
}
`$summary | ConvertTo-Json -Depth 3 | Set-Content `$reportFile

Write-Host "`n═══════════════════════════════════════" -ForegroundColor Yellow
Write-Host "  Results: `$passed passed, `$failed failed" -ForegroundColor `$(if (`$failed -eq 0) { "Green" } else { "Red" })
Write-Host "═══════════════════════════════════════`n" -ForegroundColor Yellow
"@

# ── Écrire le fichier ────────────────────
$scriptContent | Set-Content $testFile -Encoding UTF8
Write-Host "`nScript généré : $testFile" -ForegroundColor Green

# ── Afficher les éléments détectés ───────
Write-Host "`nÉléments interactifs trouvés sur la page :" -ForegroundColor Cyan
foreach ($ref in $refs) {
  Write-Host "  $($ref.ref)" -ForegroundColor Gray
}

# ── Demander si on exécute ───────────────
Write-Host "`n"
$runNow = Read-Host "Lancer le test maintenant ? (O/n)"
if ($runNow -ne "n") {
  Write-Host "`nExécution du test..." -ForegroundColor Yellow
  & $testFile -url $url
} else {
  Write-Host "Test sauvegardé. Lance-le avec : ./run.ps1 -test tests/$testName.ps1 -url $url" -ForegroundColor Yellow
}

vibium stop 2>$null
