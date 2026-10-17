// Mesures corporelles spécifiques à chaque genre
const List<String> kMesuresHomme = [
  'Poitrine',
  'Épaule',
  'Tour de fesse',
  'Col',
  'Longueur boubou',
  'Longueur pantalon',
  'Manche',
  'Ceinture',
];

// Mesures de base pour une femme ; on y ajoute ensuite dynamiquement
// soit "Longueur robe" (si le modèle est une robe), soit "Longueur jupe"
// + "Longueur boubou" (pour les autres modèles).
const List<String> kMesuresFemmeBase = [
  'Poitrine',
  'Épaule',
  'Taille',
  'Tour de fesse',
  'Blouse',
];

const List<String> kEtapesCommande = [
  'Mesure',
  'Coupe',
  'Essayage',
  'Finition',
  'Livré',
];
