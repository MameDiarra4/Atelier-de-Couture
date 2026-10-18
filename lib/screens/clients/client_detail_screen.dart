import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../data/app_state.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../commandes/add_commande_screen.dart';
import 'add_client_screen.dart';

class ClientDetailScreen extends StatefulWidget {
  final Client client;
  final List<Commande> commandes;
  final Function(Commande) onAddCommande;

  const ClientDetailScreen({
    Key? key,
    required this.client,
    required this.commandes,
    required this.onAddCommande,
  }) : super(key: key);

  @override
  _ClientDetailScreenState createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  final List<String> etapes = const [
    'Mesure',
    'Coupe',
    'Essayage',
    'Finition',
    'Livré',
  ];

  // Toujours recalculée à partir des données globales, pour refléter
  // immédiatement les ajouts/modifications/suppressions de commandes.
  List<Commande> get _commandes =>
      globalCommandes.where((c) => c.clientId == widget.client.id).toList();

  List<RendezVous> _rdvPourCommande(String commandeId) {
    return globalRendezVous.where((r) => r.commandeId == commandeId).toList()
      ..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
  }

  Future<void> _modifierCommande(Commande cmd) async {
    final commandeModifiee = await Navigator.push<Commande>(
      context,
      MaterialPageRoute(
        builder: (context) => AddCommandeScreen(
          clientId: widget.client.id,
          clientNom: widget.client.nom,
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
    }
  }

  Future<void> _supprimerRdv(RendezVous rdv) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: const Text(
          "Supprimer ce rendez-vous ?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Cette action est définitive.",
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
      setState(() => globalRendezVous.removeWhere((r) => r.id == rdv.id));
      await FirestoreService.instance.supprimerRendezVous(rdv.id);
    }
  }

  Future<void> _planifierRdv(Commande cmd, {RendezVous? existingRdv}) async {
    String? type = existingRdv?.type ?? 'Essayage';
    DateTime? date = existingRdv?.dateHeure;
    TimeOfDay? heure = existingRdv != null
        ? TimeOfDay(
            hour: existingRdv.dateHeure.hour,
            minute: existingRdv.dateHeure.minute,
          )
        : null;

    String? typeError;
    String? dateError;
    String? heureError;
    String? dateTimeError;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: kCard,
              title: Text(
                existingRdv == null
                    ? "Planifier un rendez-vous"
                    : "Modifier le rendez-vous",
                style: const TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Type", style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text("Essayage"),
                          selected: type == 'Essayage',
                          selectedColor: kOrange,
                          labelStyle: TextStyle(
                            color: type == 'Essayage'
                                ? Colors.white
                                : Colors.grey[300],
                          ),
                          backgroundColor: const Color(0xFF0D0F17),
                          onSelected: (_) => setDialogState(() {
                            type = 'Essayage';
                            typeError = null;
                          }),
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: const Text("Livraison"),
                          selected: type == 'Livraison' || type == 'Retrait',
                          selectedColor: kOrange,
                          labelStyle: TextStyle(
                            color: (type == 'Livraison' || type == 'Retrait')
                                ? Colors.white
                                : Colors.grey[300],
                          ),
                          backgroundColor: const Color(0xFF0D0F17),
                          onSelected: (_) => setDialogState(() {
                            type = 'Livraison';
                            typeError = null;
                          }),
                        ),
                      ],
                    ),
                    if (typeError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          typeError!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: kInputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: (dateError != null || dateTimeError != null)
                            ? Border.all(color: Colors.redAccent, width: 1.5)
                            : null,
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        leading:
                            const Icon(Icons.calendar_today, color: kOrange),
                        title: Text(
                          date == null
                              ? "Choisir la date *"
                              : "${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: date ??
                                DateTime.now().add(const Duration(days: 1)),
                            firstDate: DateTime(2020),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              date = picked;
                              dateError = null;
                              dateTimeError = null;
                            });
                          }
                        },
                      ),
                    ),
                    if (dateError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(
                          dateError!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: kInputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: (heureError != null || dateTimeError != null)
                            ? Border.all(color: Colors.redAccent, width: 1.5)
                            : null,
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        leading: const Icon(Icons.access_time, color: kOrange),
                        title: Text(
                          heure == null
                              ? "Choisir l'heure *"
                              : heure!.format(context),
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: heure ??
                                const TimeOfDay(hour: 10, minute: 0),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              heure = picked;
                              heureError = null;
                              dateTimeError = null;
                            });
                          }
                        },
                      ),
                    ),
                    if (heureError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(
                          heureError!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (dateTimeError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 6),
                        child: Text(
                          dateTimeError!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kOrange),
                  onPressed: () async {
                    setDialogState(() {
                      typeError = null;
                      dateError = null;
                      heureError = null;
                      dateTimeError = null;
                    });

                    bool aErreur = false;
                    if (type == null) {
                      typeError = "Veuillez choisir un type de rendez-vous";
                      aErreur = true;
                    }
                    if (date == null) {
                      dateError = "La date est requise";
                      aErreur = true;
                    }
                    if (heure == null) {
                      heureError = "L'heure est requise";
                      aErreur = true;
                    }

                    DateTime? dateHeure;
                    if (date != null && heure != null) {
                      dateHeure = DateTime(
                        date!.year,
                        date!.month,
                        date!.day,
                        heure!.hour,
                        heure!.minute,
                      );
                      if (dateHeure.isBefore(DateTime.now())) {
                        dateTimeError = "Le rendez-vous ne peut pas être dans le passé";
                        aErreur = true;
                      }
                    }

                    if (aErreur) {
                      setDialogState(() {});
                      return;
                    }

                    final rdvFinal = RendezVous(
                      id:
                          existingRdv?.id ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      commandeId: cmd.id,
                      clientId: widget.client.id,
                      type: type!,
                      dateHeure: dateHeure!,
                      note: existingRdv?.note,
                    );
                    setState(() {
                      if (existingRdv == null) {
                        globalRendezVous.add(rdvFinal);
                      } else {
                        final index = globalRendezVous.indexWhere(
                          (r) => r.id == existingRdv.id,
                        );
                        if (index != -1) {
                          globalRendezVous[index] = rdvFinal;
                        }
                      }
                    });
                    await FirestoreService.instance.creerRendezVous(rdvFinal);
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    existingRdv == null ? "Planifier" : "Enregistrer",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client.nom),
        backgroundColor: kCard,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: kCard,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Mesures du Client :",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final clientModifie = await Navigator.push<Client>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddClientScreen(
                                  tailleurId: widget.client.tailleurId,
                                  existingClient: widget.client,
                                ),
                              ),
                            );
                            if (clientModifie != null) {
                              setState(() {
                                widget.client.mesures.clear();
                                widget.client.mesures.addAll(
                                  clientModifie.mesures,
                                );
                                final index = globalClients.indexWhere(
                                  (c) => c.id == widget.client.id,
                                );
                                if (index != -1)
                                  globalClients[index] = clientModifie;
                              });
                              await FirestoreService.instance.modifierMesures(
                                widget.client.id,
                                clientModifie.mesures,
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: kOrange,
                          ),
                          label: const Text(
                            "Modifier",
                            style: TextStyle(color: kOrange, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.client.mesures.entries.map((e) {
                        final label = e.key
                            .replaceAll('_', ' ')
                            .split(' ')
                            .map(
                              (w) => w.isEmpty
                                  ? w
                                  : w[0].toUpperCase() + w.substring(1),
                            )
                            .join(' ');
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: kInputBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "$label: ${e.value.toStringAsFixed(0)} cm",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Historique des Commandes",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            _commandes.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        "Aucune commande pour ce client.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _commandes.length,
                    itemBuilder: (context, index) {
                      final cmd = _commandes[index];
                      int currentStep = etapes.indexOf(cmd.statut);
                      final rdvs = _rdvPourCommande(cmd.id);

                      return Card(
                        color: kCard,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      cmd.modele,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      cmd.statut,
                                      style: const TextStyle(
                                        color: Colors.white,
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
                                      if (value == 'modifier')
                                        _modifierCommande(cmd);
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
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
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
                              Text(
                                "Tissu : ${cmd.tissu}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                "Livraison prévue : ${cmd.dateLivraison.day}/${cmd.dateLivraison.month}/${cmd.dateLivraison.year}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const Divider(color: Colors.white24),
                              const Text(
                                "Progression :",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(etapes.length, (i) {
                                  bool isDone = i <= currentStep;
                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(
                                            () => cmd.statut = etapes[i],
                                          );
                                          FirestoreService.instance
                                              .modifierStatutCommande(
                                                cmd.id,
                                                etapes[i],
                                              );
                                        },
                                        child: CircleAvatar(
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
                              const Divider(color: Colors.white24),
                              // FONCTIONNALITÉ 3 : rendez-vous liés à cette commande
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Rendez-vous :",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _planifierRdv(cmd),
                                    icon: const Icon(
                                      Icons.event_available,
                                      size: 16,
                                      color: kOrange,
                                    ),
                                    label: const Text(
                                      "Planifier",
                                      style: TextStyle(color: kOrange),
                                    ),
                                  ),
                                ],
                              ),
                              if (rdvs.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    "Aucun rendez-vous planifié.",
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              else
                                ...rdvs.map(
                                  (r) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          r.type == 'Essayage'
                                              ? Icons.checkroom
                                              : Icons.local_shipping_outlined,
                                          size: 14,
                                          color: r.estDemain
                                              ? kOrange
                                              : Colors.white38,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            "${r.type} — ${formatDateHeure(r.dateHeure)}",
                                            style: TextStyle(
                                              color: r.estDemain
                                                  ? kOrange
                                                  : Colors.white70,
                                              fontSize: 12,
                                              fontWeight: r.estDemain
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => _planifierRdv(
                                            cmd,
                                            existingRdv: r,
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Icon(
                                              Icons.edit_outlined,
                                              size: 14,
                                              color: kOrange,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => _supprimerRdv(r),
                                          child: const Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Icon(
                                              Icons.delete_outline,
                                              size: 14,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const Divider(color: Colors.white24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total: ${cmd.montantTotal.toStringAsFixed(0)} FCFA",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        "Reste: ${cmd.resteAPayer.toStringAsFixed(0)} FCFA",
                                        style: const TextStyle(
                                          color: kOrange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kOrange,
                                    ),
                                    onPressed: () =>
                                        _showPaymentDialog(context, cmd),
                                    icon: const Icon(
                                      Icons.payment,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      "Payer",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kOrange,
        onPressed: () async {
          final nouvelleCommande = await Navigator.push<Commande>(
            context,
            MaterialPageRoute(
              builder: (context) => AddCommandeScreen(
                clientId: widget.client.id,
                clientNom: widget.client.nom,
              ),
            ),
          );
          if (nouvelleCommande != null) {
            widget.onAddCommande(nouvelleCommande);
            await FirestoreService.instance.creerCommande(nouvelleCommande);
            setState(() {});
          }
        },
        child: const Icon(Icons.add_shopping_cart, color: Colors.white),
      ),
    );
  }

  // FONCTIONNALITÉ 4 : Enregistrer un paiement
  void _showPaymentDialog(BuildContext context, Commande cmd) {
    final versementController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: const Text(
          "Enregistrer un paiement",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Montant Total: ${cmd.montantTotal} FCFA",
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              "Reste à Payer: ${cmd.resteAPayer} FCFA",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: kOrange,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: versementController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Nouveau Versement (FCFA)",
                labelStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF0D0F17),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kOrange),
            onPressed: () async {
              double v = double.tryParse(versementController.text) ?? 0.0;
              if (v > 0) {
                setState(() => cmd.acompte += v);
                final paiement = Paiement(
                  id: "pay_${DateTime.now().millisecondsSinceEpoch}",
                  commandeId: cmd.id,
                  clientId: cmd.clientId,
                  tailleurId: widget.client.tailleurId,
                  montant: v,
                  date: DateTime.now(),
                  note: "Versement",
                );
                await FirestoreService.instance.enregistrerPaiement(paiement);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Valider", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
