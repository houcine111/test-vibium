# test-vibium

Template portable de tests QA automatisés avec [vibium](https://vibium.ai).

## Structure

```
test-vibium/
├── .gitignore
├── run.ps1              # Lanceur unique (start → test → stop)
├── tests/
│   └── template.ps1     # Squelette à copier pour chaque projet
├── screenshots/         # Captures d'écran (gitignoré)
└── reports/             # Rapports (gitignoré)
```

## Utilisation

```powershell
npm install -g vibium
git clone <url> tests-e2e
cd tests-e2e

# Copier le template et ajouter tes tests
cp tests/template.ps1 tests/mon-app.ps1

# Lancer
./run.ps1
```

## Commandes

| Commande | Action |
|----------|--------|
| `./run.ps1` | Mode fenêtré |
| `./run.ps1 -headless` | Mode headless (CI) |
| `./run.ps1 -url https://site.com -test tests/mon-app.ps1` | Cible personnalisée |
