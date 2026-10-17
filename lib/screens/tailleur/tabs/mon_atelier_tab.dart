import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/app_state.dart';
import '../../../models/models.dart';
import '../../../services/firestore_service.dart';
import '../../role_selection_screen.dart';

class MonAtelierTab extends StatelessWidget {
  final Tailleur tailleur;
  const MonAtelierTab({Key? key, required this.tailleur}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Mon Atelier",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: kOrange,
            child: Text(
              tailleur.nom.isNotEmpty ? tailleur.nom[0].toUpperCase() : "?",
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            tailleur.nom,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Center(
          child: Text(
            tailleur.maisonCouture.isEmpty ? "" : tailleur.maisonCouture,
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.mail_outline, color: kOrange),
                title: const Text(
                  "Email",
                  style: TextStyle(color: Colors.grey),
                ),
                subtitle: Text(
                  tailleur.email,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const Divider(color: Colors.white12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone_outlined, color: kOrange),
                title: const Text(
                  "Téléphone",
                  style: TextStyle(color: Colors.grey),
                ),
                subtitle: Text(
                  tailleur.telephone.isEmpty
                      ? "Non renseigné"
                      : tailleur.telephone,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF2A1A16),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
          ),
          child: TextButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const RoleSelectionScreen(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text(
              "Se déconnecter",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
