import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../data/app_state.dart';
import '../../../models/models.dart';
import '../../../services/firestore_service.dart';
import '../../clients/add_client_screen.dart';
import '../../clients/client_detail_screen.dart';

class ClientsTab extends StatefulWidget {
  final Tailleur tailleur;
  final VoidCallback onChanged;
  const ClientsTab({Key? key, required this.tailleur, required this.onChanged})
    : super(key: key);

  @override
  State<ClientsTab> createState() => _ClientsTabState();
}

class _ClientsTabState extends State<ClientsTab> {
  String _recherche = '';

  // Clients appartenant uniquement au tailleur connecté
  List<Client> get _mesClients =>
      globalClients.where((c) => c.tailleurId == widget.tailleur.id).toList();

  Future<void> _nouveauClient() async {
    final newClient = await Navigator.push<Client>(
      context,
      MaterialPageRoute(
        builder: (context) => AddClientScreen(tailleurId: widget.tailleur.id),
      ),
    );
    if (newClient != null) {
      setState(() => globalClients.add(newClient));
      await FirestoreService.instance.ajouterClient(newClient);
      widget.onChanged();
    }
  }

  Future<void> _modifierClient(Client client) async {
    final clientModifie = await Navigator.push<Client>(
      context,
      MaterialPageRoute(
        builder: (context) => AddClientScreen(
          tailleurId: widget.tailleur.id,
          existingClient: client,
        ),
      ),
    );
    if (clientModifie != null) {
      setState(() {
        final index = globalClients.indexWhere((c) => c.id == client.id);
        if (index != -1) globalClients[index] = clientModifie;
      });
      await FirestoreService.instance.modifierClient(clientModifie);
      widget.onChanged();
    }
  }

  Future<void> _supprimerClient(Client client) async {
    final nbCommandes = globalCommandes
        .where((c) => c.clientId == client.id)
        .length;
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: const Text(
          "Supprimer ce client ?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          nbCommandes > 0
              ? "Ce client a $nbCommandes commande(s) et ses rendez-vous associés. Tout sera supprimé définitivement."
              : "Cette action est définitive.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Supprimer",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirme == true) {
      setState(() {
        final commandeIds = globalCommandes
            .where((c) => c.clientId == client.id)
            .map((c) => c.id)
            .toSet();
        globalRendezVous.removeWhere(
          (r) => r.clientId == client.id || commandeIds.contains(r.commandeId),
        );
        globalCommandes.removeWhere((c) => c.clientId == client.id);
        globalClients.removeWhere((c) => c.id == client.id);
      });
      await FirestoreService.instance.supprimerClient(client.id);
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final clients = _mesClients
        .where(
          (c) =>
              _recherche.isEmpty ||
              c.nom.toLowerCase().contains(_recherche.toLowerCase()),
        )
        .toList();
    final total = _mesClients.length;
    final hommes = _mesClients.where((c) => c.genre == 'Homme').length;
    final femmes = _mesClients.where((c) => c.genre == 'Femme').length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  "Clients",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _nouveauClient,
                icon: const Icon(
                  Icons.person_add,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  "Nouveau client",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: kInputDec("Recherche...", icon: Icons.search),
            onChanged: (v) => setState(() => _recherche = v),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _stat(
                    Icons.groups_outlined,
                    kOrange,
                    "$total",
                    "Total",
                  ),
                ),
                Container(height: 30, width: 1, color: Colors.white12),
                Expanded(
                  child: _stat(
                    Icons.male,
                    Colors.blueAccent,
                    "$hommes",
                    "Homme",
                  ),
                ),
                Container(height: 30, width: 1, color: Colors.white12),
                Expanded(
                  child: _stat(
                    Icons.female,
                    Colors.pinkAccent,
                    "$femmes",
                    "Femme",
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: clients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_search_outlined,
                        size: 60,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Liste vide",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Les clients apparaîtront ici",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                        onPressed: _nouveauClient,
                        icon: const Icon(Icons.person_add, color: Colors.white),
                        label: const Text(
                          "Nouveau client",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    final client = clients[index];
                    final nbCommandes = globalCommandes
                        .where((c) => c.clientId == client.id)
                        .length;

                    return Card(
                      color: kCard,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: kOrange,
                          child: Icon(
                            client.genre == 'Homme' ? Icons.male : Icons.female,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          client.nom,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          "Tél: ${client.telephone} | Commandes: $nbCommandes",
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                          color: kCard,
                          onSelected: (value) {
                            if (value == 'modifier') _modifierClient(client);
                            if (value == 'supprimer') _supprimerClient(client);
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'modifier',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: kOrange,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Modifier",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'supprimer',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Supprimer",
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClientDetailScreen(
                                client: client,
                                commandes: globalCommandes
                                    .where((c) => c.clientId == client.id)
                                    .toList(),
                                onAddCommande: (nouvelleCommande) {
                                  setState(
                                    () => globalCommandes.add(nouvelleCommande),
                                  );
                                },
                              ),
                            ),
                          );
                          setState(() {});
                          widget.onChanged();
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _stat(IconData icon, Color color, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
      ],
    );
  }
}

// ---------- Onglet MON ATELIER ----------
