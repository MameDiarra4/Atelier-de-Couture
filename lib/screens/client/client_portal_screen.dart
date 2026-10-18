
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../data/app_state.dart';
import '../../models/models.dart';

class ClientPortalScreen extends StatelessWidget {
  final Client client;
  final List<Commande> commandes;

  /// Map tailleurId → Tailleur, pour résoudre le nom de l'atelier.
  /// Fourni par ClientLoginScreen ; vide par défaut pour la rétrocompatibilité.
  final Map<String, Tailleur> tailleurs;

  const ClientPortalScreen({
    Key? key,
    required this.client,
    required this.commandes,
    this.tailleurs = const {},
  }) : super(key: key);

  static const List<String> etapes = [
    'Mesure',
    'Coupe',
    'Essayage',
    'Finition',
    'Livré',
  ];

  /// Retourne le nom de l'atelier pour une commande donnée.
  /// Priorité : tailleurId de la commande → tailleurId de la fiche client → fallback.
  String _nomAtelier(Commande cmd) {
    if (cmd.tailleurId.isNotEmpty) {
      final t = tailleurs[cmd.tailleurId];
      if (t != null) return t.maisonCouture;
    }
    // Fallback : résoudre via la fiche client liée à la commande
    final ficheClient = globalClients.firstWhere(
      (c) => c.id == cmd.clientId,
      orElse: () => Client(
          id: '', nom: '', telephone: '', adresse: '', genre: '', mesures: {}),
    );
    if (ficheClient.tailleurId.isNotEmpty) {
      final t = tailleurs[ficheClient.tailleurId];
      if (t != null) return t.maisonCouture;
    }
    return 'Atelier inconnu';
  }

  @override
  Widget build(BuildContext context) {
    final rdvAVenir = rendezVousAVenir(clientId: client.id);
    final rdvDemain = rendezVousDemain(clientId: client.id);

    // Affiche le badge atelier si les commandes proviennent de plusieurs tailleurs
    final tailleurIds = commandes
        .map((cmd) => cmd.tailleurId.isNotEmpty ? cmd.tailleurId : cmd.clientId)
        .toSet();
    final afficherAtelier = tailleurIds.length > 1;

    return Scaffold(
      appBar: AppBar(
        title: Text("Bonjour ${client.nom}"),
        backgroundColor: kCard,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ── Rappel rendez-vous demain ──
          if (rdvDemain.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kOrange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, color: kOrange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Rappel : vous avez un rendez-vous ${rdvDemain.first.type.toLowerCase()} demain (${formatDateHeure(rdvDemain.first.dateHeure)}).",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Rendez-vous à venir ──
          if (rdvAVenir.isNotEmpty) ...[
            const Text(
              "Vos rendez-vous à venir",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ...rdvAVenir.map(
              (r) => Card(
                color: kCard,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    r.type == 'Essayage'
                        ? Icons.checkroom
                        : Icons.local_shipping_outlined,
                    color: kOrange,
                  ),
                  title: Text(
                    r.type,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    formatDateHeure(r.dateHeure),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],

          // ── Titre section commandes ──
          const Text(
            "Vos commandes",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // ── Liste des commandes ──
          if (commandes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "Vous n'avez aucune commande en cours.",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            ...commandes.map((cmd) {
              final currentStep = etapes.indexOf(cmd.statut);
              final nomAtelier = _nomAtelier(cmd);

              return Card(
                color: kCard,
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Badge atelier ──────────────────────────────────
                      // Affiché dès que le client a des commandes chez
                      // plusieurs tailleurs, pour lever toute ambiguïté.
                      if (afficherAtelier)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: kOrange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: kOrange.withValues(alpha: 0.6), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.store, size: 14, color: kOrange),
                              const SizedBox(width: 5),
                              Text(
                                nomAtelier,
                                style: const TextStyle(
                                  color: kOrange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ── Photo du modèle ──
                      if (cmd.photoModele != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              cmd.photoModele!,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      // ── Infos commande ──
                      Text(
                        cmd.modele,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Tissu : ${cmd.tissu}",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        "Livraison estimée : ${cmd.dateLivraison.day}/${cmd.dateLivraison.month}/${cmd.dateLivraison.year}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const Divider(height: 25, color: Colors.white24),

                      // ── Avancement ──
                      const Text(
                        "Avancement :",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(etapes.length, (i) {
                          final isDone = i <= currentStep;
                          return Column(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor:
                                    isDone ? kOrange : Colors.grey[700],
                                child: Icon(
                                  Icons.check,
                                  size: 14,
                                  color: isDone
                                      ? Colors.white
                                      : Colors.grey[400],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                etapes[i],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[300],
                                  fontWeight: isDone
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                      const Divider(height: 25, color: Colors.white24),

                      // ── Montants ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total: ${cmd.montantTotal} FCFA",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            "Reste à payer: ${cmd.resteAPayer} FCFA",
                            style: const TextStyle(
                              color: kOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
