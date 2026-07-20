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

## Structure

```
tests/          # Scripts générés par opencode
screenshots/    # Captures d'écran
reports/        # Rapports JSON
run.ps1         # Pour rejouer un script existant
tests/template.ps1   # Squelette (copie pour écrire un test manuellement)
```
