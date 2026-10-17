import '../models/models.dart';

List<Tailleur> globalTailleurs = [
  Tailleur(
    id: 't1',
    nom: 'Cheikh Lo',
    maisonCouture: 'DigitSagnse Couture',
    email: 'cheikh@atelier.sn',
    telephone: '770000000',
    motDePasse: 'atelier123',
  ),
];

List<Client> globalClients = [
  Client(
    id: '1',
    tailleurId: 't1',
    nom: 'Awa Ndiaye',
    telephone: '771234567',
    adresse: 'Dakar',
    genre: 'Femme',
    mesures: {
      'poitrine': 90,
      'taille': 75,
      'hanches': 98,
      'epaule': 40,
      'manche': 60,
    },
    motDePasse: null,
  ),
];

List<Commande> globalCommandes = [
  Commande(
    id: '101',
    clientId: '1',
    modele: 'Robe de Soirée',
    tissu: 'Soie',
    dateLivraison: DateTime.now().add(const Duration(days: 5)),
    statut: 'Coupe',
    montantTotal: 25000,
    acompte: 10000,
  ),
];

List<RendezVous> globalRendezVous = [
  RendezVous(
    id: 'rdv1',
    commandeId: '101',
    clientId: '1',
    type: 'Essayage',
    dateHeure: DateTime.now().add(const Duration(days: 1, hours: 2)),
  ),
];

// Utilitaires FONCTIONNALITÉ 3 : rendez-vous "de demain" (simulation de rappel)
List<RendezVous> rendezVousDemain({String? clientId}) {
  return globalRendezVous.where((r) {
    final matchClient = clientId == null || r.clientId == clientId;
    return matchClient && r.estDemain;
  }).toList()..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
}

List<RendezVous> rendezVousAVenir({required String clientId}) {
  final now = DateTime.now();
  return globalRendezVous
      .where((r) => r.clientId == clientId && r.dateHeure.isAfter(now))
      .toList()
    ..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
}
