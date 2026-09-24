import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const ApplicationTailleur());
}

class ApplicationTailleur extends StatelessWidget {
  const ApplicationTailleur({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Clientèle Tailleur',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0F17),
        primaryColor: const Color(0xFFFF5722),
      ),
      home: const RoleSelectionScreen(),
    );
  }
}

// ==========================================
// CONSTANTES ET STYLES REUTILISABLES
// ==========================================

const Color kBg = Color(0xFF0D0F17);
const Color kCard = Color(0xFF161A26);
const Color kInputBg = Color(0xFF161A26);
const Color kOrange = Color(0xFFFF6B35);

InputDecoration kInputDec(String hint, {IconData? icon, Widget? suffix}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[500]),
    filled: true,
    fillColor: kInputBg,
    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    prefixIcon: icon != null ? Icon(icon, color: kOrange) : null,
    suffixIcon: suffix,
  );
}

Widget kGradientButton({
  required String label,
  required VoidCallback onPressed,
  IconData? icon,
}) {
  return Container(
    width: double.infinity,
    height: 55,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFFF9455), Color(0xFFE0632B)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: kOrange.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

// ==========================================
// MODÈLES DE DONNÉES
// ==========================================

class Tailleur {
  final String id;
  final String nom;
  final String maisonCouture;
  final String email;
  final String telephone;
  String motDePasse;

  Tailleur({
    required this.id,
    required this.nom,
    required this.maisonCouture,
    required this.email,
    required this.telephone,
    required this.motDePasse,
  });
}

class Client {
  final String id;
  final String nom;
  final String telephone;
  final String adresse;
  final Map<String, double> mesures;
  String? motDePasse;

  Client({
    required this.id,
    required this.nom,
    required this.telephone,
    required this.adresse,
    required this.mesures,
    this.motDePasse,
  });
}

class Commande {
  final String id;
  final String clientId;
  final String modele;
  final String tissu;
  final DateTime dateLivraison;
  String statut;
  final double montantTotal;
  double acompte;
  final Uint8List? photoModele;

  Commande({
    required this.id,
    required this.clientId,
    required this.modele,
    required this.tissu,
    required this.dateLivraison,
    required this.statut,
    required this.montantTotal,
    required this.acompte,
    this.photoModele,
  });

  double get resteAPayer => montantTotal - acompte;
}

class RendezVous {
  final String id;
  final String commandeId;
  final String clientId;
  final String type;
  final DateTime dateHeure;
  final String? note;

  RendezVous({
    required this.id,
    required this.commandeId,
    required this.clientId,
    required this.type,
    required this.dateHeure,
    this.note,
  });

  bool get estDemain {
    final now = DateTime.now();
    final demain = DateTime(now.year, now.month, now.day + 1);
    return dateHeure.year == demain.year &&
        dateHeure.month == demain.month &&
        dateHeure.day == demain.day;
  }

  bool get estPasse => dateHeure.isBefore(DateTime.now());
}

// ==========================================
// DONNÉES SIMULÉES (EN MÉMOIRE)
// ==========================================

List<Tailleur> globalTailleurs = [
  Tailleur(
    id: 't1',
    nom: 'Cheikh Lo',
    maisonCouture: 'ÑawalMa Couture',
    email: 'cheikh@atelier.sn',
    telephone: '770000000',
    motDePasse: 'atelier123',
  ),
];

List<Client> globalClients = [
  Client(
    id: '1',
    nom: 'Awa Ndiaye',
    telephone: '771234567',
    adresse: 'Dakar',
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

// Fonctions utilitaires
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

String formatDateHeure(DateTime d) {
  final jours = ['', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  final jour = jours[d.weekday];
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return "$jour ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} à $h:$m";
}

// ==========================================
// ECRAN 1 : SÉLECTION DU RÔLE
// ==========================================

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.4),
                radius: 1.2,
                colors: [Color(0xFF1E2230), Color(0xFF0A0B10)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF7E40), Color(0xFFFF4500)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.content_cut,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Ñawal",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: kOrange,
                                ),
                              ),
                              TextSpan(
                                text: "Ma",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Bienvenue !",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Sélectionnez votre espace pour continuer",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 32),
                          kGradientButton(
                            label: "Espace Tailleur",
                            icon: Icons.content_cut,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TailleurLoginScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              color: const Color(0xFF202534),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ClientLoginScreen(),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Espace Client",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[200],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// ECRAN 2 : CONNEXION TAILLEUR
// ==========================================

class TailleurLoginScreen extends StatefulWidget {
  const TailleurLoginScreen({Key? key}) : super(key: key);

  @override
  State<TailleurLoginScreen> createState() => _TailleurLoginScreenState();
}

class _TailleurLoginScreenState extends State<TailleurLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _seConnecter() {
    final email = _emailController.text.trim().toLowerCase();
    final motDePasse = _passwordController.text;

    if (email.isEmpty || motDePasse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Merci de remplir l'email et le mot de passe."),
        ),
      );
      return;
    }

    final tailleurIndex = globalTailleurs.indexWhere(
      (t) => t.email.toLowerCase() == email,
    );

    if (tailleurIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Aucun compte tailleur trouvé pour cet email."),
        ),
      );
      return;
    }

    final tailleur = globalTailleurs[tailleurIndex];

    if (tailleur.motDePasse != motDePasse) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Mot de passe incorrect.")));
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TailleurHomeScreen(tailleur: tailleur),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.4),
                radius: 1.2,
                colors: [Color(0xFF1E2230), Color(0xFF0A0B10)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Bon retour",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Gérez votre atelier en toute simplicité",
                        style: TextStyle(fontSize: 15, color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kOrange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Démo : cheikh@atelier.sn / atelier123",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: kInputDec(
                          "Entrez votre email",
                          icon: Icons.mail_outline,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: kInputDec(
                          "Entrez votre mot de passe",
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey[400],
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      kGradientButton(
                        label: "Se connecter",
                        onPressed: _seConnecter,
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TailleurSignupScreen(),
                              ),
                            );
                          },
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(fontSize: 14),
                              children: [
                                TextSpan(
                                  text: "Pas encore de compte? ",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                TextSpan(
                                  text: "S'inscrire",
                                  style: TextStyle(
                                    color: kOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// ECRAN 3 : INSCRIPTION TAILLEUR
// ==========================================

class TailleurSignupScreen extends StatefulWidget {
  const TailleurSignupScreen({Key? key}) : super(key: key);

  @override
  State<TailleurSignupScreen> createState() => _TailleurSignupScreenState();
}

class _TailleurSignupScreenState extends State<TailleurSignupScreen> {
  int _etape = 1;

  final _nomController = TextEditingController();
  final _maisonController = TextEditingController();
  final _emailController = TextEditingController();
  final _telController = TextEditingController();

  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _accepteConditions = false;

  void _continuer() {
    if (_nomController.text.trim().isEmpty ||
        _maisonController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Merci de remplir tous les champs obligatoires."),
        ),
      );
      return;
    }
    final emailExiste = globalTailleurs.any(
      (t) =>
          t.email.toLowerCase() == _emailController.text.trim().toLowerCase(),
    );
    if (emailExiste) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Un compte existe déjà avec cet email.")),
      );
      return;
    }
    setState(() => _etape = 2);
  }

  void _creerCompte() {
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Le mot de passe doit contenir au moins 6 caractères."),
        ),
      );
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Les mots de passe ne correspondent pas."),
        ),
      );
      return;
    }
    if (!_accepteConditions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Merci d'accepter les conditions.")),
      );
      return;
    }

    final nouveauTailleur = Tailleur(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nom: _nomController.text.trim(),
      maisonCouture: _maisonController.text.trim(),
      email: _emailController.text.trim(),
      telephone: _telController.text.trim(),
      motDePasse: _passwordController.text,
    );
    globalTailleurs.add(nouveauTailleur);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TailleurHomeScreen(tailleur: nouveauTailleur),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_etape == 2)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => setState(() => _etape = 1),
                  ),
                Text(
                  "Création de compte - Étape $_etape",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                if (_etape == 1) ...[
                  TextField(
                    controller: _nomController,
                    style: const TextStyle(color: Colors.white),
                    decoration: kInputDec("Nom complet", icon: Icons.person),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _maisonController,
                    style: const TextStyle(color: Colors.white),
                    decoration: kInputDec(
                      "Nom de l'atelier / Maison",
                      icon: Icons.store,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: kInputDec("Email", icon: Icons.email),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _telController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: kInputDec("Téléphone", icon: Icons.phone),
                  ),
                  const SizedBox(height: 20),
                  kGradientButton(label: "Continuer", onPressed: _continuer),
                ] else ...[
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: kInputDec(
                      "Mot de passe",
                      icon: Icons.lock,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    style: const TextStyle(color: Colors.white),
                    decoration: kInputDec(
                      "Confirmer le mot de passe",
                      icon: Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _accepteConditions,
                        activeColor: kOrange,
                        onChanged: (v) =>
                            setState(() => _accepteConditions = v ?? false),
                      ),
                      const Expanded(
                        child: Text(
                          "J'accepte les conditions d'utilisation",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  kGradientButton(
                    label: "Finaliser mon compte",
                    onPressed: _creerCompte,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// ECRAN 4 : AUTHENTIFICATION CLIENT
// ==========================================

class ClientLoginScreen extends StatefulWidget {
  const ClientLoginScreen({Key? key}) : super(key: key);

  @override
  State<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends State<ClientLoginScreen> {
  final _phoneController = TextEditingController();

  void _continuer() {
    String phone = _phoneController.text.trim();
    final clientIndex = globalClients.indexWhere((c) => c.telephone == phone);

    if (clientIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Aucun compte trouvé. Demandez à votre tailleur de vous enregistrer.",
          ),
        ),
      );
      return;
    }

    final client = globalClients[clientIndex];

    if (client.motDePasse == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClientActivateAccountScreen(client: client),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClientPasswordScreen(client: client),
        ),
      );
    }
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
              "Entrez le numéro de téléphone communiqué à votre atelier de couture.",
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

class ClientActivateAccountScreen extends StatefulWidget {
  final Client client;
  const ClientActivateAccountScreen({Key? key, required this.client})
    : super(key: key);

  @override
  State<ClientActivateAccountScreen> createState() =>
      _ClientActivateAccountScreenState();
}

class _ClientActivateAccountScreenState
    extends State<ClientActivateAccountScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  void _activer() {
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Le mot de passe doit contenir au moins 6 caractères."),
        ),
      );
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Les mots de passe ne correspondent pas."),
        ),
      );
      return;
    }
    setState(() => widget.client.motDePasse = _passwordController.text);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ClientPortalScreen(client: widget.client),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activation Compte"),
        backgroundColor: kCard,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Créer un mot de passe pour le compte de ${widget.client.nom}",
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: kInputDec("Nouveau mot de passe"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: kInputDec("Confirmer mot de passe"),
            ),
            const SizedBox(height: 20),
            kGradientButton(label: "Activer mon compte", onPressed: _activer),
          ],
        ),
      ),
    );
  }
}

class ClientPasswordScreen extends StatefulWidget {
  final Client client;
  const ClientPasswordScreen({Key? key, required this.client})
    : super(key: key);

  @override
  State<ClientPasswordScreen> createState() => _ClientPasswordScreenState();
}

class _ClientPasswordScreenState extends State<ClientPasswordScreen> {
  final _passwordController = TextEditingController();

  void _seConnecter() {
    if (_passwordController.text != widget.client.motDePasse) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Mot de passe incorrect.")));
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ClientPortalScreen(client: widget.client),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bonjour ${widget.client.nom}"),
        backgroundColor: kCard,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: kInputDec(
                "Saisissez votre mot de passe",
                icon: Icons.lock,
              ),
            ),
            const SizedBox(height: 20),
            kGradientButton(label: "Se connecter", onPressed: _seConnecter),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ECRAN 5 : PORTAIL SUIVI CLIENT
// ==========================================

class ClientPortalScreen extends StatelessWidget {
  final Client client;

  const ClientPortalScreen({Key? key, required this.client}) : super(key: key);

  final List<String> etapes = const [
    'Mesure',
    'Coupe',
    'Essayage',
    'Finition',
    'Livré',
  ];

  @override
  Widget build(BuildContext context) {
    final mesCommandes = globalCommandes
        .where((c) => c.clientId == client.id)
        .toList();
    final rdvAVenir = rendezVousAVenir(clientId: client.id);
    final rdvDemain = rendezVousDemain(clientId: client.id);

    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenue ${client.nom}"),
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
              "Vos prochains rendez-vous",
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
          if (mesCommandes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "Aucune commande en cours.",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            ...mesCommandes.map((cmd) {
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
                      const Divider(height: 25, color: Colors.white24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(etapes.length, (i) {
                          bool isDone = i <= currentStep;
                          return Column(
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: isDone
                                    ? kOrange
                                    : Colors.grey[700],
                                child: Icon(
                                  Icons.check,
                                  size: 12,
                                  color: isDone
                                      ? Colors.white
                                      : Colors.grey[400],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                etapes[i],
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isDone ? Colors.white : Colors.grey,
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
                            "Reste: ${cmd.resteAPayer} FCFA",
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

// ==========================================
// ECRAN 6 : ACCUEIL TAILLEUR
// ==========================================

class TailleurHomeScreen extends StatefulWidget {
  final Tailleur tailleur;
  const TailleurHomeScreen({Key? key, required this.tailleur})
    : super(key: key);

  @override
  State<TailleurHomeScreen> createState() => _TailleurHomeScreenState();
}

class _TailleurHomeScreenState extends State<TailleurHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final rdvDemain = rendezVousDemain();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.tailleur.maisonCouture.isEmpty
              ? "Mon Atelier"
              : widget.tailleur.maisonCouture,
        ),
        backgroundColor: kCard,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (rdvDemain.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(10),
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
                        mesures: {},
                      ),
                    );
                    return Text(
                      "• ${r.type} — ${c.nom} (${formatDateHeure(r.dateHeure)})",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    );
                  }),
                ],
              ),
            ),
          Expanded(
            child: globalClients.isEmpty
                ? Center(
                    child: Text(
                      "Aucun client enregistré.\nCliquez sur le bouton + pour en ajouter un.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.grey[400]),
                    ),
                  )
                : ListView.builder(
                    itemCount: globalClients.length,
                    itemBuilder: (context, index) {
                      final client = globalClients[index];
                      final nbCommandes = globalCommandes
                          .where((c) => c.clientId == client.id)
                          .length;

                      return Card(
                        color: kCard,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: kOrange,
                            child: Icon(Icons.person, color: Colors.white),
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
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ClientDetailScreen(client: client),
                              ),
                            );
                            setState(() {}); // Actualise l'écran au retour
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kOrange,
        onPressed: () async {
          final newClient = await Navigator.push<Client>(
            context,
            MaterialPageRoute(builder: (context) => const AddClientScreen()),
          );
          if (newClient != null) {
            setState(() => globalClients.add(newClient));
          }
        },
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          "Nouveau Client",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

// ==========================================
// ECRAN 7 : NOUVEAU CLIENT
// ==========================================

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({Key? key}) : super(key: key);

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _telController = TextEditingController();
  final _adresseController = TextEditingController();

  final _poitrineController = TextEditingController();
  final _tailleController = TextEditingController();
  final _hanchesController = TextEditingController();
  final _epauleController = TextEditingController();
  final _mancheController = TextEditingController();

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: kInputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un Client"),
        backgroundColor: kCard,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Informations Générales",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nomController,
                style: const TextStyle(color: Colors.white),
                decoration: _dec("Nom Complet"),
                validator: (v) => v!.isEmpty ? "Nom requis" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _telController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: _dec("Téléphone"),
                validator: (v) => v!.isEmpty ? "Téléphone requis" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _adresseController,
                style: const TextStyle(color: Colors.white),
                decoration: _dec("Adresse"),
              ),
              const SizedBox(height: 20),
              const Text(
                "Mesures (cm)",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _poitrineController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _dec("Poitrine"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _tailleController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _dec("Taille"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hanchesController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _dec("Hanches"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _epauleController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _dec("Épaule"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _mancheController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _dec("Longueur Manche"),
              ),
              const SizedBox(height: 25),
              kGradientButton(
                label: "Enregistrer le client",
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final client = Client(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      nom: _nomController.text,
                      telephone: _telController.text,
                      adresse: _adresseController.text,
                      mesures: {
                        'poitrine':
                            double.tryParse(_poitrineController.text) ?? 0,
                        'taille': double.tryParse(_tailleController.text) ?? 0,
                        'hanches':
                            double.tryParse(_hanchesController.text) ?? 0,
                        'epaule': double.tryParse(_epauleController.text) ?? 0,
                        'manche': double.tryParse(_mancheController.text) ?? 0,
                      },
                    );
                    Navigator.pop(context, client);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// ECRAN 8 : DÉTAIL CLIENT & COMMANDES
// ==========================================

class ClientDetailScreen extends StatefulWidget {
  final Client client;

  const ClientDetailScreen({Key? key, required this.client}) : super(key: key);

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  final List<String> etapes = const [
    'Mesure',
    'Coupe',
    'Essayage',
    'Finition',
    'Livré',
  ];

  @override
  Widget build(BuildContext context) {
    final mesCommandes = globalCommandes
        .where((c) => c.clientId == widget.client.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.client.nom), backgroundColor: kCard),
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
                    const Text(
                      "Fiche Mesures :",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Poitrine: ${widget.client.mesures['poitrine']} cm | Taille: ${widget.client.mesures['taille']} cm | Hanches: ${widget.client.mesures['hanches']} cm",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "Épaule: ${widget.client.mesures['epaule']} cm | Manche: ${widget.client.mesures['manche']} cm",
                      style: const TextStyle(color: Colors.white70),
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
            mesCommandes.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Aucune commande enregistrée.",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: mesCommandes.length,
                    itemBuilder: (context, index) {
                      final cmd = mesCommandes[index];
                      int currentStep = etapes.indexOf(cmd.statut);

                      return Card(
                        color: kCard,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    cmd.modele,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
                                ],
                              ),
                              Text(
                                "Tissu : ${cmd.tissu}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const Divider(color: Colors.white24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(etapes.length, (i) {
                                  bool isDone = i <= currentStep;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        cmd.statut = etapes[i];
                                      });
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
                                  );
                                }),
                              ),
                              const Divider(color: Colors.white24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Reste : ${cmd.resteAPayer.toStringAsFixed(0)} FCFA",
                                    style: const TextStyle(
                                      color: kOrange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kOrange,
                                    ),
                                    onPressed: () => _showPaymentDialog(cmd),
                                    child: const Text(
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
          final newCmd = await Navigator.push<Commande>(
            context,
            MaterialPageRoute(
              builder: (context) => AddCommandeScreen(
                clientId: widget.client.id,
                clientNom: widget.client.nom,
              ),
            ),
          );
          if (newCmd != null) {
            setState(() {
              globalCommandes.add(newCmd);
            });
          }
        },
        child: const Icon(Icons.add_shopping_cart, color: Colors.white),
      ),
    );
  }

  void _showPaymentDialog(Commande cmd) {
    final versementController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: const Text(
          "Enregistrer un paiement",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: versementController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: kInputDec("Montant du versement (FCFA)"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kOrange),
            onPressed: () {
              double v = double.tryParse(versementController.text) ?? 0.0;
              if (v > 0) {
                setState(() => cmd.acompte += v);
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

// ==========================================
// ECRAN 9 : CREER COMMANDE
// ==========================================

class AddCommandeScreen extends StatefulWidget {
  final String clientId;
  final String clientNom;

  const AddCommandeScreen({
    Key? key,
    required this.clientId,
    required this.clientNom,
  }) : super(key: key);

  @override
  State<AddCommandeScreen> createState() => _AddCommandeScreenState();
}

class _AddCommandeScreenState extends State<AddCommandeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modeleController = TextEditingController();
  final _tissuController = TextEditingController();
  final _montantTotalController = TextEditingController();
  final _acompteController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  Uint8List? _photoModele;
  final ImagePicker _picker = ImagePicker();

  Future<void> _prendrePhoto() async {
    final XFile? fichier = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (fichier != null) {
      final bytes = await fichier.readAsBytes();
      setState(() => _photoModele = bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nouvelle Commande - ${widget.clientNom}"),
        backgroundColor: kCard,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _prendrePhoto,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kInputBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _photoModele == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: kOrange, size: 30),
                            SizedBox(height: 6),
                            Text(
                              "Ajouter la photo du modèle",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        )
                      : Image.memory(_photoModele!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _modeleController,
                style: const TextStyle(color: Colors.white),
                decoration: kInputDec("Modèle"),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _tissuController,
                style: const TextStyle(color: Colors.white),
                decoration: kInputDec("Tissu"),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _montantTotalController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: kInputDec("Montant Total"),
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _acompteController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: kInputDec("Acompte"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              kGradientButton(
                label: "Enregistrer la commande",
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final nouvelleCommande = Commande(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      clientId: widget.clientId,
                      modele: _modeleController.text,
                      tissu: _tissuController.text,
                      dateLivraison: _selectedDate,
                      statut: "Mesure",
                      montantTotal:
                          double.tryParse(_montantTotalController.text) ?? 0.0,
                      acompte: double.tryParse(_acompteController.text) ?? 0.0,
                      photoModele: _photoModele,
                    );
                    Navigator.pop(context, nouvelleCommande);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
