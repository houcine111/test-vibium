# test-vibium

Template portable de tests QA automatisés avec [vibium](https://vibium.ai).

Clone-le dans n'importe quel projet pour lancer des tests browser en 30 secondes.

## Structure

```
test-vibium/
├── .gitignore
├── package.json                    # npm test, npm run report:open
├── config.json                     # URL + config de ton app
├── run.ps1                         # Lanceur unique (start → test → stop)
├── tests/
│   ├── template.ps1                # Template à copier pour un nouveau projet
│   └── todomvc.ps1                 # Exemple concret (TodoMVC)
├── scripts/
│   └── allure-convert.ps1          # JSON → rapport Allure
├── screenshots/                    # Captures d'écran (gitignoré)
└── reports/                        # Rapports JSON + Allure (gitignoré)
```

## Utilisation

```powershell
# 1. Installer vibium (une fois)
npm install -g vibium

# 2. Cloner dans ton projet
cd mon-projet
git clone <url-du-repo-test-vibium> tests-e2e
cd tests-e2e

# 3. Configurer
#    Édite config.json avec l'URL de ton app
#    Copie tests/template.ps1 → tests/mon-app.ps1
#    Ajoute tes propres étapes de test

# 4. Lancer
./run.ps1
```

## Commandes

| Commande | Action |
|----------|--------|
| `./run.ps1` | Test en mode fenêtré |
| `./run.ps1 -headless` | Test sans UI (CI) |
| `./run.ps1 -allure` | Test + rapport Allure |
| `./run.ps1 -test tests/ma-app.ps1 -url https://site.com` | Cible personnalisée |
| `npm test` | Mode headless |
| `npm run test:headed` | Mode fenêtré |
| `npm run report:open` | Générer + ouvrir Allure |

## Personnalisation

1. **`config.json`** → URL cible par défaut
2. **`tests/mon-app.ps1`** → copie de `template.ps1`, ajoute tes `Test-Step`
3. **`run.ps1 -headless -allure`** → CI-ready

## Pourquoi ce template ?

- **Portable** : tout est dans le repo, rien à configurer
- **Rejouable** : `./run.ps1` sur n'importe quelle machine
- **CI-ready** : mode headless + rapport JSON/Allure
- **Zéro dépendance** lourde : juste vibium et PowerShell
