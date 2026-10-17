import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../data/app_state.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../tailleur/tailleur_home_screen.dart';

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

  Widget _label(String texte) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[400],
            letterSpacing: 0.5,
          ),
          children: [
            TextSpan(text: texte),
            const TextSpan(
              text: " *",
              style: TextStyle(color: Color(0xFFE05B3F)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressBar() {
    Widget bar(bool actif) => Expanded(
      child: Container(
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: actif ? kOrange : const Color(0xFF2A2F3D),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
    return Row(children: [bar(true), bar(_etape == 2)]);
  }

  void _continuer() {
    if (_nomController.text.trim().isEmpty ||
        _maisonController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Merci de remplir les champs requis.")),
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

  Future<void> _creerCompte() async {
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
        const SnackBar(
          content: Text("Merci d'accepter la politique de confidentialité."),
        ),
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
    await FirestoreService.instance.enregistrerTailleur(nouveauTailleur);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TailleurHomeScreen(tailleur: nouveauTailleur),
      ),
    );
  }

  Widget _etape1() {
    return Column(
      key: const ValueKey('etape1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("NOM COMPLET"),
        TextField(
          controller: _nomController,
          style: const TextStyle(color: Colors.white),
          decoration: kInputDec("Ex: Cheikh Lo", icon: Icons.person_outline),
        ),
        const SizedBox(height: 18),
        _label("MAISON DE COUTURE"),
        TextField(
          controller: _maisonController,
          style: const TextStyle(color: Colors.white),
          decoration: kInputDec(
            "Nom de votre atelier",
            icon: Icons.storefront_outlined,
          ),
        ),
        const SizedBox(height: 18),
        _label("EMAIL"),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: kInputDec("votre@email.com", icon: Icons.mail_outline),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Text(
              "Téléphone",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF202534),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Optionnel",
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
              decoration: BoxDecoration(
                color: kInputBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Text("🇸🇳", style: TextStyle(fontSize: 18)),
                  SizedBox(width: 6),
                  Text(
                    "+221",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _telController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: kInputDec("Numéro de téléphone"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        kGradientButton(
          label: "Continuer",
          icon: Icons.arrow_forward,
          onPressed: _continuer,
        ),
      ],
    );
  }

  Widget _etape2() {
    return Column(
      key: const ValueKey('etape2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("MOT DE PASSE"),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white),
          decoration: kInputDec(
            "Minimum 6 caractères",
            icon: Icons.lock_outline,
            suffix: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey[400],
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _label("CONFIRMER LE MOT DE PASSE"),
        TextField(
          controller: _confirmController,
          obscureText: _obscureConfirm,
          style: const TextStyle(color: Colors.white),
          decoration: kInputDec(
            "Répétez le mot de passe",
            icon: Icons.lock_outline,
            suffix: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey[400],
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kInputBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _accepteConditions,
                activeColor: kOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (v) =>
                    setState(() => _accepteConditions = v ?? false),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(text: "J'accepte la "),
                        TextSpan(
                          text: "politique de confidentialité",
                          style: TextStyle(
                            color: kOrange,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
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
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            color: const Color(0xFF202534),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _creerCompte,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  "Créer mon compte",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_etape == 2)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white70,
                          ),
                          onPressed: () => setState(() => _etape = 1),
                        ),
                      ),
                    const Text(
                      "Créer un compte",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Étape $_etape sur 2",
                      style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 12),
                    _progressBar(),
                    const SizedBox(height: 26),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _etape == 1 ? _etape1() : _etape2(),
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 14),
                            children: [
                              TextSpan(
                                text: "Déjà inscrit? ",
                                style: TextStyle(color: Colors.grey),
                              ),
                              TextSpan(
                                text: "Se connecter",
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
        ],
      ),
    );
  }
}
