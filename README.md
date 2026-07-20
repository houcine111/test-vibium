# test-vibium

Template de tests QA avec vibium + opencode.

## Dépendances

- **vibium** — `npm install -g vibium`

## Installation

```powershell
git clone <url> tests-e2e
cd tests-e2e
```

## Utilisation avec opencode

Ouvre opencode dans ce dossier et donne-lui une instruction comme :

> *"va sur https://demo.playwright.dev/todomvc, explore l'app, identifie tous les workflows, exécute des tests end-to-end, sauvegarde les screenshots dans screenshots/ et le rapport dans reports/report.json, puis génère le script de test dans tests/todomvc.ps1"*

**opencode va :**
1. Charger le skill `vibe-check` → utiliser vibium
2. Naviguer, explorer, exécuter les tests
3. Sauvegarder les captures et le rapport
4. Générer le script `tests/todomvc.ps1` réutilisable

## Rejouer un script généré

Une fois qu'opencode a créé un script, tu peux le relancer directement :

```powershell
./run.ps1 -url https://demo.playwright.dev/todomvc -test tests/todomvc.ps1
```

## Reporting avec Allure

Installe Allure pour visualiser les rapports :

```powershell
winget install Allure.Allure
# ou : scoop install allure
# ou : npx -y allure-commandline install
```

Le rapport `reports/report.json` généré par les tests peut être converti en Allure avec cette commande :

```powershell
# Installer allure-commandline (une fois)
npm install -g allure-commandline

# Lancer le serveur de rapport directement depuis le JSON
allure serve reports/
```

Cela ouvre un navigateur avec l'historique des tests, les durées, les échecs et les captures d'écran.

## Structure

```
tests/              # Scripts générés par opencode
screenshots/        # Captures d'écran
reports/report.json # Résultats des tests
run.ps1             # Pour rejouer un script existant
tests/template.ps1  # Squelette (copie pour écrire un test manuellement)
```
