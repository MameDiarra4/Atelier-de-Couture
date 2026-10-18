import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../data/app_state.dart';
import '../client/client_portal_screen.dart';

class ClientLoginScreen extends StatefulWidget {
  const ClientLoginScreen({Key? key}) : super(key: key);

  @override
  State<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends State<ClientLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String? _clientNotFoundError;

  void _continuer() {
    setState(() => _clientNotFoundError = null);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final raw = _phoneController.text.trim();
    final cleanPhone = raw.replaceAll(RegExp(r'[\s\-]'), '');

    // Récupérer TOUTES les fiches clientes ayant ce numéro
    // (une fiche par tailleur chez qui le client est enregistré)
    final fiches = globalClients
        .where((c) =>
            c.telephone.replaceAll(RegExp(r'[\s\-]'), '') == cleanPhone)
        .toList();

    if (fiches.isEmpty) {
      setState(() {
        _clientNotFoundError =
            "Aucun compte trouvé. Demandez à votre tailleur de créer votre fiche.";
      });
      _formKey.currentState!.validate();
      return;
    }

    // Récupérer toutes les commandes liées à toutes ces fiches
    final tousLesIds = fiches.map((c) => c.id).toSet();
    final commandes = globalCommandes
        .where((cmd) => tousLesIds.contains(cmd.clientId))
        .toList();

    // On utilise la première fiche (nom du client affiché dans l'en-tête)
    final clientPrincipal = fiches.first;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientPortalScreen(
          client: clientPrincipal,
          commandes: commandes,
          // Passer le map tailleurId → nom d'atelier pour afficher l'atelier
          tailleurs: {
            for (final t in globalTailleurs) t.id: t,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Espace Client"),
        backgroundColor: kCard,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_android, size: 60, color: kOrange),
              const SizedBox(height: 20),
              const Text(
                "Suivi de vos commandes",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Entrez le numéro de téléphone transmis à votre tailleur pour accéder à votre suivi.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: kInputDec("ex: 771234567", icon: Icons.phone),
                onChanged: (_) {
                  if (_clientNotFoundError != null) {
                    setState(() => _clientNotFoundError = null);
                  }
                },
                validator: (v) {
                  final raw = v?.trim() ?? '';
                  if (raw.isEmpty) return "Numéro de téléphone invalide";
                  final clean = raw.replaceAll(RegExp(r'[\s\-]'), '');
                  if (!RegExp(r'^[0-9]+$').hasMatch(clean) || clean.length != 9) {
                    return "Numéro de téléphone invalide";
                  }
                  if (_clientNotFoundError != null) {
                    return _clientNotFoundError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              kGradientButton(label: "Continuer", onPressed: _continuer),
            ],
          ),
        ),
      ),
    );
  }
}
