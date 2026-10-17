import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/app_state.dart';
import '../../../models/models.dart';

class AccueilTab extends StatelessWidget {
  final Tailleur tailleur;
  final VoidCallback onChanged;
  const AccueilTab({Key? key, required this.tailleur, required this.onChanged})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mesClients = globalClients
        .where((c) => c.tailleurId == tailleur.id)
        .toList();
    final mesClientIds = mesClients.map((c) => c.id).toSet();
    final mesCommandes = globalCommandes
        .where((c) => mesClientIds.contains(c.clientId))
        .toList();
    final rdvDemain = rendezVousDemain()
        .where((r) => mesClientIds.contains(r.clientId))
        .toList();
    final totalClients = mesClients.length;
    final totalCommandes = mesCommandes.length;
    final resteAPercevoir = mesCommandes.fold<double>(
      0,
      (s, c) => s + c.resteAPayer,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          tailleur.maisonCouture.isEmpty ? "Atelier" : tailleur.maisonCouture,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          "Bonjour ${tailleur.nom}",
          style: TextStyle(color: Colors.grey[400]),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _statCard(
                Icons.groups_outlined,
                "$totalClients",
                "Clients",
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                Icons.shopping_bag_outlined,
                "$totalCommandes",
                "Commandes",
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                Icons.payments_outlined,
                "${resteAPercevoir.toStringAsFixed(0)}",
                "FCFA à percevoir",
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (rdvDemain.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kOrange),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notifications_active, color: kOrange),
                    SizedBox(width: 8),
                    Text(
                      "Rappels de demain",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ...rdvDemain.map((r) {
                  final c = globalClients.firstWhere(
                    (cl) => cl.id == r.clientId,
                    orElse: () => Client(
                      id: '',
                      nom: 'Client inconnu',
                      telephone: '',
                      adresse: '',
                      genre: 'Femme',
                      mesures: {},
                    ),
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      "• ${r.type} — ${c.nom} (${formatDateHeure(r.dateHeure)})",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                }),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Icon(Icons.event_available, color: Colors.grey[600], size: 32),
                const SizedBox(height: 8),
                Text(
                  "Aucun rendez-vous prévu demain",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _statCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: kOrange, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------- Onglet COMMANDES ----------
