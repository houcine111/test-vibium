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

Ouvre opencode dans ce dossier et donne-lui une instruction. Exemple :

> *"va sur https://demo.playwright.dev/todomvc, explore l'app, exécute des tests e2e, sauvegarde les captures et le rapport, puis génère le script de test dans tests/todomvc.ps1"*

opencode va générer `tests/todomvc.ps1` avec l'URL directement dans le fichier.

## Rejouer un script

```powershell
./run.ps1           # si un seul script dans tests/
./run.ps1 -headless # ou en mode headless
```

Si plusieurs scripts dans `tests/`, un menu te demandera lequel choisir.

## Reporting

Deux rapports générés automatiquement après chaque test :

| Format | Emplacement | Visualisation |
|--------|------------|---------------|
| JSON | `reports/report.json` | Lecture directe |
| Allure | `reports/allure-results/` | `allure serve reports/allure-results/` |

## Structure

```
tests/                      # Scripts de test (générés par opencode)
screenshots/                # Captures d'écran
reports/
├── report.json             # Résultats lisibles
└── allure-results/         # Résultats format Allure
run.ps1                     # Lanceur
tests/template.ps1          # Squelette à copier
```
