import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../data/app_state.dart';
import '../../models/models.dart';

class ClientPortalScreen extends StatelessWidget {
  final Client client;
  final List<Commande> commandes;

  const ClientPortalScreen({
    Key? key,
    required this.client,
    required this.commandes,
  }) : super(key: key);

  final List<String> etapes = const [
    'Mesure',
    'Coupe',
    'Essayage',
    'Finition',
    'Livré',
  ];

  @override
  Widget build(BuildContext context) {
    final rdvAVenir = rendezVousAVenir(clientId: client.id);
    final rdvDemain = rendezVousDemain(clientId: client.id);

    return Scaffold(
      appBar: AppBar(
        title: Text("Bonjour ${client.nom}"),
        backgroundColor: kCard,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (rdvDemain.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kOrange.withOpacity(0.12),
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
          const Text(
            "Vos commandes",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
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
              int currentStep = etapes.indexOf(cmd.statut);
              return Card(
                color: kCard,
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          bool isDone = i <= currentStep;
                          return Column(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: isDone
                                    ? kOrange
                                    : Colors.grey[700],
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
