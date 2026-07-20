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
├── prompt-run.ps1                  # Générateur : un prompt → un test
├── tests/
│   └── template.ps1                # Squelette à copier pour chaque projet
├── examples/
│   └── todomvc.ps1                 # Exemple concret (TodoMVC, hors tests/)
├── scripts/
│   └── allure-convert.ps1          # JSON → rapport Allure
├── screenshots/                    # Captures d'écran (gitignoré)
└── reports/                        # Rapports JSON + Allure (gitignoré)
```

## Installation

```powershell
# 1. Installer vibium (une fois)
npm install -g vibium

# 2. Installer Allure (optionnel, pour les rapports)
#    Via npm (recommandé) :
npx allure-commandline install
#    Ou via winget :
winget install Allure.Allure
#    Ou via scoop :
scoop install allure

# 3. Cloner dans ton projet
cd mon-projet
git clone <url-du-repo-test-vibium> tests-e2e
cd tests-e2e

# 4. Configurer
#    Édite config.json avec l'URL de ton app
#    Copie tests/template.ps1 → tests/mon-app.ps1
#    Ajoute tes propres étapes de test
#    Voir examples/todomvc.ps1 pour un exemple complet

# 5. Lancer
./run.ps1
```

## Commandes

| Commande | Action |
|----------|--------|
| `./run.ps1` | Test en mode fenêtré |
| `./run.ps1 -headless` | Test sans UI (CI) |
| `./run.ps1 -allure` | Test + rapport Allure |
| `./run.ps1 -test tests/ma-app.ps1 -url https://site.com` | Cible personnalisée |
| `./prompt-run.ps1` | Mode interactif (tape ce que tu veux tester) |
| `./prompt-run.ps1 -prompt "va sur https://... et teste le login"` | Mode direct |
| `npm test` | Mode headless |
| `npm run test:headed` | Mode fenêtré |
| `npm run report:open` | Générer + ouvrir Allure |

## Générateur par prompt

Tu décris ce que tu veux tester en langage naturel, le script explore la page et génère le test automatiquement.

```powershell
./prompt-run.ps1
# > va sur https://demo.playwright.dev/todomvc, ajoute 3 todos et vérifie le compteur

# Ou en une ligne :
./prompt-run.ps1 -prompt "teste le formulaire de connexion sur https://example.com/login"
```

Ce qu'il fait :
1. Extrait l'URL de ton prompt
2. Navigue et explore la page avec `vibium map`
3. Génère un script `tests/prompt-<timestamp>.ps1`
4. Te propose de l'exécuter immédiatement
5. Sauvegarde le script pour le rejouer plus tard

## Personnalisation

1. **`config.json`** → URL cible par défaut
2. **`tests/mon-app.ps1`** → copie de `template.ps1`, ajoute tes `Test-Step`
3. **`run.ps1 -headless -allure`** → CI-ready

## Dépendances

| Outil | Obligatoire | Installation |
|-------|-------------|-------------|
| **vibium** | Oui | `npm install -g vibium` |
| **Allure** | Non (rapports) | `winget install Allure.Allure` ou `scoop install allure` ou `npx allure-commandline install` |

## Pourquoi ce template ?

- **Portable** : tout est dans le repo, rien à configurer
- **Rejouable** : `./run.ps1` sur n'importe quelle machine
- **CI-ready** : mode headless + rapport JSON/Allure
- **Zéro dépendance** lourde : juste vibium et PowerShell
