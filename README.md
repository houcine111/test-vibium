# test-vibium

Template de tests QA avec Vibium + opencode.

## Prérequis

- **Node.js 20+**
- **Vibium** (CLI) — `npm install -g vibium`

## Installation

```powershell
git clone <url> tests-e2e
cd tests-e2e
npm install
```

## Exécution

```powershell
npm run smoke       # Smoke tests
npm run e2e         # Parcours complet E2E
npm run regression  # Tests de régression
```

## Avec opencode

```powershell
cd tests-e2e
opencode
```

## Structure

```
tests/                      # Scripts de test TypeScript
├── lib.ts                  # Helper (TestReport, initRun)
├── smoke.ts
├── e2e.ts
├── regression.ts
└── template.ts             # Squelette à copier
features/                   # Documentation Gherkin
reports/                    # Résultats JSON + captures d'écran
├── screenshots/
├── smoke.json
├── e2e.json
└── regression.json
```
