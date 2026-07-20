# test-vibium

Template portable de tests QA avec vibium + opencode.

## Dépendances

- **vibium** — `npm install -g vibium`

## Installation

```powershell
git clone <url> tests-e2e
cd tests-e2e
```

## Utilisation

### 1. Écrire un test

Copie `tests/template.ps1` → `tests/mon-app.ps1` et ajoute tes étapes :

```powershell
Test-Step "Ajouter un article au panier" {
  vibium fill "input[name=search]" "chaise"
  vibium click "button[type=submit]"
  vibium click ".product:first-child .add-to-cart"
}
Screenshot "03-panier"
```

### 2. Lancer

```powershell
./run.ps1 -url https://mon-site.com -test tests/mon-app.ps1
```

### 3. Rapport

Les résultats sont dans `reports/report.json`, les captures dans `screenshots/`.

---

## Comment opencode génère les tests automatiquement

**opencode ne fait rien tout seul.** Le skill `vibe-check` lui donne juste la capacité d'utiliser vibium. C'est **toi** qui lui dis quoi faire.

Exemple — tu tapes dans opencode :

> *"va sur https://demo.playwright.dev/todomvc, explore l'app, identifie tous les workflows, exécute des tests end-to-end, sauvegarde les screenshots dans screenshots/ et le rapport dans reports/report.json, puis génère le script de test dans tests/todomvc.ps1"*

opencode va alors :

1. Charger le skill vibe-check → savoir utiliser `vibium go`, `vibium map`, `vibium click`, etc.
2. Naviguer, explorer, exécuter les tests
3. Sauvegarder screenshots et rapport
4. **Générer le fichier `tests/todomvc.ps1`** avec toutes les étapes

Le résultat : un script réutilisable pour la prochaine fois.

**En résumé :** C'est toi qui donnes l'instruction. opencode exécute et génère le fichier de test dans `tests/`. Le template ne fait que fournir la structure (dossiers `screenshots/`, `reports/`, squelette `tests/template.ps1`).
