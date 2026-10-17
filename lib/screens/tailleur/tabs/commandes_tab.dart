import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../data/app_state.dart';
import '../../../models/models.dart';
import '../../../services/firestore_service.dart';
import '../../commandes/add_commande_screen.dart';
import '../../clients/client_detail_screen.dart';

class CommandesTab extends StatefulWidget {
  final Tailleur tailleur;
  final VoidCallback onChanged;
  const CommandesTab({
    Key? key,
    required this.tailleur,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<CommandesTab> createState() => _CommandesTabState();
}

class _CommandesTabState extends State<CommandesTab> {
  String _recherche = '';
  String _filtre = 'Toutes';

  final List<String> _filtres = [
    'Toutes',
    'À traiter',
    'En couture',
    'Terminé',
    'Livré',
  ];

  // Clients et commandes appartenant uniquement au tailleur connecté
  List<Client> get _mesClients =>
      globalClients.where((c) => c.tailleurId == widget.tailleur.id).toList();
  Set<String> get _mesClientIds => _mesClients.map((c) => c.id).toSet();
  List<Commande> get _mesCommandes =>
      globalCommandes.where((c) => _mesClientIds.contains(c.clientId)).toList();

  bool _matchFiltre(Commande c) {
    switch (_filtre) {
      case 'À traiter':
        return c.statut == 'Mesure';
      case 'En couture':
        return c.statut == 'Coupe' || c.statut == 'Essayage';
      case 'Terminé':
        return c.statut == 'Finition';
      case 'Livré':
        return c.statut == 'Livré';
      default:
        return true;
    }
  }

  int _countFiltre(String f) {
    if (f == 'Toutes') return _mesCommandes.length;
    final avant = _filtre;
    _filtre = f;
    final n = _mesCommandes.where(_matchFiltre).length;
    _filtre = avant;
    return n;
  }

  Future<void> _nouvelleCommande() async {
    if (_mesClients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Créez d'abord un client depuis l'onglet Clients."),
        ),
      );
      return;
    }
    final client = await showModalBottomSheet<Client>(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Choisir un client",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              ..._mesClients.map(
                (c) => ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: kOrange,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    c.nom,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    c.telephone,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  onTap: () => Navigator.pop(ctx, c),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (client == null) return;

    final nouvelleCommande = await Navigator.push<Commande>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddCommandeScreen(clientId: client.id, clientNom: client.nom),
      ),
    );
    if (nouvelleCommande != null) {
      setState(() => globalCommandes.add(nouvelleCommande));
      await FirestoreService.instance.creerCommande(nouvelleCommande);
      widget.onChanged();
    }
  }

  Future<void> _modifierCommande(Commande cmd) async {
    final client = globalClients.firstWhere(
      (cl) => cl.id == cmd.clientId,
      orElse: () => Client(
        id: '',
        nom: 'Client inconnu',
        telephone: '',
        adresse: '',
        genre: 'Femme',
        mesures: {},
      ),
    );
    final commandeModifiee = await Navigator.push<Commande>(
      context,
      MaterialPageRoute(
        builder: (context) => AddCommandeScreen(
          clientId: cmd.clientId,
          clientNom: client.nom,
          existingCommande: cmd,
        ),
      ),
    );
    if (commandeModifiee != null) {
      setState(() {
        final index = globalCommandes.indexWhere((c) => c.id == cmd.id);
        if (index != -1) globalCommandes[index] = commandeModifiee;
      });
      await FirestoreService.instance.modifierCommande(commandeModifiee);
      widget.onChanged();
    }
  }

  Future<void> _supprimerCommande(Commande cmd) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: const Text(
          "Supprimer cette commande ?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Les rendez-vous liés seront aussi supprimés. Cette action est définitive.",
          style: TextStyle(color: Colors.white70),
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
        globalRendezVous.removeWhere((r) => r.commandeId == cmd.id);
        globalCommandes.removeWhere((c) => c.id == cmd.id);
      });
      await FirestoreService.instance.supprimerCommande(cmd.id);
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final commandes = _mesCommandes.where((c) {
      final client = globalClients.firstWhere(
        (cl) => cl.id == c.clientId,
        orElse: () => Client(
          id: '',
          nom: '',
          telephone: '',
          adresse: '',
          genre: 'Femme',
          mesures: {},
        ),
      );
      final matchTexte =
          _recherche.isEmpty ||
          c.modele.toLowerCase().contains(_recherche.toLowerCase()) ||
          client.nom.toLowerCase().contains(_recherche.toLowerCase());
      return _matchFiltre(c) && matchTexte;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  "Commandes",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: kOrange, size: 30),
                onPressed: _nouvelleCommande,
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
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filtres.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final f = _filtres[i];
              final selected = f == _filtre;
              return ChoiceChip(
                label: Text("$f (${_countFiltre(f)})"),
                selected: selected,
                selectedColor: kOrange,
                backgroundColor: kCard,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.grey[300],
                  fontSize: 12,
                ),
                onSelected: (_) => setState(() => _filtre = f),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: commandes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
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
                        "Les commandes apparaîtront ici",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: commandes.length,
                  itemBuilder: (context, index) {
                    final cmd = commandes[index];
                    final client = globalClients.firstWhere(
                      (cl) => cl.id == cmd.clientId,
                      orElse: () => Client(
                        id: '',
                        nom: 'Client inconnu',
                        telephone: '',
                        adresse: '',
                        genre: 'Femme',
                        mesures: {},
                      ),
                    );
                    return Card(
                      color: kCard,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: cmd.photoModele != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  cmd.photoModele!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const CircleAvatar(
                                backgroundColor: kOrange,
                                child: Icon(
                                  Icons.checkroom,
                                  color: Colors.white,
                                ),
                              ),
                        title: Text(
                          cmd.modele,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "${client.nom} • ${cmd.tissu}",
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(
                                cmd.statut,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                              backgroundColor: kOrange,
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.grey[400],
                              ),
                              color: kCard,
                              onSelected: (value) {
                                if (value == 'modifier') _modifierCommande(cmd);
                                if (value == 'supprimer')
                                  _supprimerCommande(cmd);
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
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                                onAddCommande: (nc) =>
                                    setState(() => globalCommandes.add(nc)),
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
}

// ---------- Onglet CLIENTS ----------
