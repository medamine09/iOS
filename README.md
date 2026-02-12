# Application type Yuka (scan code-barres + rappels conso)

Ce dépôt contient un **socle Swift** pour créer une app mobile iOS qui :

1. scanne un code-barres,
2. récupère les informations produit (Open Food Facts),
3. vérifie si le produit est rappelé sur `rappel.conso.gouv.fr`,
4. fusionne le résultat pour affichage dans l'app.

## Ce qui est déjà prêt

- `YukaLikeCore` (Swift Package) avec :
  - `OpenFoodFactsClient` pour la recherche produit par EAN,
  - `RappelConsoClient` pour la recherche de rappels,
  - `ProductAnalyzer` pour agréger les deux résultats.
- Tests unitaires sur l'agrégation et la tolérance aux erreurs de l'API rappel.

## Architecture recommandée de l'app iOS

- **UI (SwiftUI)**
  - Écran scan (AVFoundation / VisionKit)
  - Écran résultat
  - Historique local des scans
- **Domain**
  - `ProductAnalyzer` (déjà implémenté)
- **Data**
  - `OpenFoodFactsClient`
  - `RappelConsoClient`
  - cache local (`SwiftData` / `CoreData`)

## Exemple d'utilisation

```swift
import YukaLikeCore

let analyzer = ProductAnalyzer()
let analysis = try await analyzer.analyze(barcode: "3270190207905")

print(analysis.name)
print(analysis.nutritionGrade ?? "-")
print("Rappel: \(analysis.recalled)")
```

## Points importants pour aller en prod

- Ajouter une couche de scoring (nutrition, additifs, allergènes) avec règles métier explicites.
- Gérer la fiabilité et l'évolution du format de l'API Rappel Conso.
- Ajouter du retry/backoff et un cache offline.
- Respecter RGPD (pas de collecte inutile, politique de confidentialité claire).
- Ajouter des tests d'intégration réseau + snapshots UI.

## Lancement des tests

```bash
swift test
```
