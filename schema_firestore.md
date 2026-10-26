# 📊 Schéma de la Base de Données Firestore — DigitSagnse

> **Base de données** : Firebase Cloud Firestore (NoSQL — documents/collections)
> **Projet Firebase** : digitsagnse

---

## Vue d'ensemble des Collections

```
Firestore
├── tailleurs/          ← Comptes des tailleurs (maisons de couture)
├── clients/            ← Fiches clients avec mesures
├── commandes/          ← Commandes de couture
├── rendezvous/         ← Essayages et retraits planifiés
└── paiements/          ← Historique des versements
```

---

## Collection `tailleurs`

**Document ID** : UUID généré par l'application (`tailleur_XXXX`)

| Champ | Type | Exemple | Description |
|:---|:---|:---|:---|
| `id` | String | `"tailleur_demo_001"` | ID document |
| `nom` | String | `"Cheikh Diallo"` | Nom complet |
| `maisonCouture` | String | `"DigitSagnse Couture"` | Nom de l'atelier |
| `email` | String | `"cheikh@atelier.sn"` | Email (identifiant login) |
| `telephone` | String | `"779876543"` | Téléphone |
| `motDePasse` | String | `"atelier123"` | Mot de passe (en clair pour la démo) |
| `createdAt` | Timestamp | `serverTimestamp()` | Date de création |
| `updatedAt` | Timestamp | `serverTimestamp()` | Dernière modification |

---

## Collection `clients`

**Document ID** : UUID généré par l'application (`client_XXXX`)

| Champ | Type | Exemple | Description |
|:---|:---|:---|:---|
| `id` | String | `"client_awa_001"` | ID document |
| `tailleurId` | String | `"tailleur_demo_001"` | Référence au tailleur propriétaire |
| `nom` | String | `"Awa Ndiaye"` | Nom complet |
| `telephone` | String | `"771234567"` | Téléphone (identifiant portail client) |
| `adresse` | String | `"Sicap Liberté 3, Dakar"` | Adresse postale |
| `genre` | String | `"Femme"` | `"Homme"` ou `"Femme"` |
| `mesures` | Map | voir ci-dessous | Mensurations en cm |
| `motDePasse` | String? | `null` | Mot de passe optionnel |
| `createdAt` | Timestamp | `serverTimestamp()` | Date de création |
| `updatedAt` | Timestamp | `serverTimestamp()` | Dernière modification |

### Champ `mesures` — Femme
```json
{
  "poitrine": 92.0,
  "epaule": 38.0,
  "taille": 74.0,
  "fesses": 98.0,
  "blouse": 58.0,
  "robe_jupe": 100.0,
  "boubou": 150.0
}
```

### Champ `mesures` — Homme
```json
{
  "poitrine": 102.0,
  "epaule": 46.0,
  "fesses": 105.0,
  "col": 41.0,
  "boubou": 160.0,
  "pantalon": 100.0,
  "manche": 62.0,
  "ceinture": 88.0
}
```

---

## Collection `commandes`

**Document ID** : UUID généré par l'application (`commande_XXXX`)

| Champ | Type | Exemple | Description |
|:---|:---|:---|:---|
| `id` | String | `"commande_001"` | ID document |
| `clientId` | String | `"client_awa_001"` | Référence au client |
| `tailleurId` | String | `"tailleur_demo_001"` | Référence au tailleur |
| `modele` | String | `"Robe soirée wax imprimé"` | Description du modèle |
| `tissu` | String | `"Wax hollandais"` | Type de tissu |
| `dateLivraison` | String (ISO 8601) | `"2026-11-09T10:00:00.000Z"` | Date de livraison prévue |
| `statut` | String | `"Coupe"` | Étape courante (voir valeurs ci-dessous) |
| `montantTotal` | Number | `45000.0` | Prix total en FCFA |
| `acompte` | Number | `20000.0` | Montant versé |
| `resteAPayer` | Number | `25000.0` | Solde restant (calculé) |
| `photoBase64` | String? | `null` | Photo du modèle encodée en Base64 |
| `createdAt` | Timestamp | `serverTimestamp()` | Date de création |
| `updatedAt` | Timestamp | `serverTimestamp()` | Dernière modification |

### Valeurs possibles du champ `statut`
```
"Mesure"  →  "Coupe"  →  "Essayage"  →  "Finition"  →  "Livré"
```

---

## Collection `rendezvous`

**Document ID** : UUID généré par l'application (`rdv_XXXX`)

| Champ | Type | Exemple | Description |
|:---|:---|:---|:---|
| `id` | String | `"rdv_001"` | ID document |
| `commandeId` | String | `"commande_001"` | Référence à la commande |
| `clientId` | String | `"client_awa_001"` | Référence au client |
| `type` | String | `"Essayage"` | `"Essayage"` ou `"Retrait"` |
| `dateHeure` | String (ISO 8601) | `"2026-10-27T10:30:00.000Z"` | Date et heure du RDV |
| `note` | String? | `"Vérifier les manches"` | Note optionnelle |
| `createdAt` | Timestamp | `serverTimestamp()` | Date de création |

---

## Collection `paiements`

**Document ID** : UUID généré par l'application (`paiement_XXXX`)

| Champ | Type | Exemple | Description |
|:---|:---|:---|:---|
| `id` | String | `"paiement_001"` | ID document |
| `commandeId` | String | `"commande_001"` | Référence à la commande |
| `clientId` | String | `"client_awa_001"` | Référence au client |
| `tailleurId` | String | `"tailleur_demo_001"` | Référence au tailleur |
| `montant` | Number | `20000.0` | Montant du versement (FCFA) |
| `date` | String (ISO 8601) | `"2026-10-19T08:00:00.000Z"` | Date du versement |
| `mode` | String | `"Wave"` | Mode de paiement (voir ci-dessous) |
| `note` | String? | `"Acompte initial"` | Note optionnelle |
| `createdAt` | Timestamp | `serverTimestamp()` | Date de création |

### Valeurs possibles du champ `mode`
```
"Espèces"  |  "Wave"  |  "Orange Money"  |  "Autre"
```

---

## Diagramme des Relations

```
tailleurs (1)
    │
    └──── clients (N)
               │
               └──── commandes (N)
                          │
                          ├──── rendezvous (N)
                          │
                          └──── paiements (N)
```

**Règle de cohérence** :
- Un `client` appartient à un seul `tailleur` (via `tailleurId`)
- Une `commande` appartient à un seul `client` (via `clientId`)
- Un `rendezVous` est lié à une `commande` ET à un `client`
- Un `paiement` est lié à une `commande`, un `client` ET un `tailleur`

---

## Instructions pour Utiliser le Script de Peuplement

### 1. Prérequis
```bash
# Node.js doit être installé
node --version

# Installer firebase-admin
npm install firebase-admin
```

### 2. Clé de service Firebase
1. Aller sur [Firebase Console](https://console.firebase.google.com/)
2. **Paramètres du projet** → **Comptes de service**
3. Cliquer **Générer une nouvelle clé privée**
4. Enregistrer le fichier JSON sous `serviceAccountKey.json`
5. Placer `serviceAccountKey.json` dans le dossier racine du projet

### 3. Exécuter le script
```bash
# Depuis la racine du projet
node seed_data.js
```

### 4. Résultat attendu
```
🚀 Démarrage du peuplement de Firestore — DigitSagnse...

📌 Insertion du tailleur de démo...
   ✅ Tailleur "Cheikh Diallo" inséré

📌 Insertion des clients...
   ✅ Client "Awa Ndiaye" inséré
   ✅ Client "Moussa Ba" inséré
   ✅ Client "Fatou Sow" inséré

📌 Insertion des commandes...
   ✅ Commande "Robe soirée wax imprimé" insérée (statut: Coupe)
   ...

✅ Peuplement Firestore terminé avec succès !
```
