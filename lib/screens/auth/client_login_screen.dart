import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../data/app_state.dart';
import '../../models/models.dart';
import '../client/client_portal_screen.dart';

class ClientLoginScreen extends StatefulWidget {
  const ClientLoginScreen({Key? key}) : super(key: key);

  @override
  State<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends State<ClientLoginScreen> {
  final _phoneController = TextEditingController();

  void _continuer() {
    String phone = _phoneController.text.trim();
    final client = globalClients.firstWhere(
      (c) => c.telephone == phone,
      orElse: () => Client(
        id: '',
        nom: '',
        telephone: '',
        adresse: '',
        genre: 'Femme',
        mesures: {},
      ),
    );

    if (client.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Aucun compte trouvé. Demandez à votre tailleur de créer votre fiche.",
          ),
        ),
      );
      return;
    }

    final commandes = globalCommandes
        .where((c) => c.clientId == client.id)
        .toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ClientPortalScreen(client: client, commandes: commandes),
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
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: kInputDec("ex: 771234567", icon: Icons.phone),
            ),
            const SizedBox(height: 20),
            kGradientButton(label: "Continuer", onPressed: _continuer),
          ],
        ),
      ),
    );
  }
}
