import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../data/app_state.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../tailleur/tailleur_home_screen.dart';
import 'tailleur_signup_screen.dart';

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

    final tailleur = globalTailleurs.firstWhere(
      (t) => t.email.toLowerCase() == email,
      orElse: () => Tailleur(
        id: '',
        nom: '',
        maisonCouture: '',
        email: '',
        telephone: '',
        motDePasse: '',
      ),
    );

    if (tailleur.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Aucun compte tailleur trouvé pour cet email."),
        ),
      );
      return;
    }

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

  // FONCTIONNALITÉ : Mot de passe oublié — l'utilisateur saisit son email,
  // on vérifie qu'un compte existe, puis on lui demande un nouveau mot de passe.
  void _showForgotPasswordDialog() {
    final emailController = TextEditingController(text: _emailController.text);
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool emailVerifie = false;
    Tailleur? tailleurTrouve;
    bool obscure1 = true;
    bool obscure2 = true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: kCard,
              title: const Text(
                "Mot de passe oublié",
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!emailVerifie) ...[
                      const Text(
                        "Entrez l'email de votre compte tailleur pour continuer.",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: kInputDec(
                          "Votre email",
                          icon: Icons.mail_outline,
                        ),
                      ),
                    ] else ...[
                      Text(
                        "Compte trouvé : ${tailleurTrouve?.nom ?? ''}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: newPasswordController,
                        obscureText: obscure1,
                        style: const TextStyle(color: Colors.white),
                        decoration: kInputDec(
                          "Nouveau mot de passe",
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            icon: Icon(
                              obscure1
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey[400],
                            ),
                            onPressed: () =>
                                setDialogState(() => obscure1 = !obscure1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: obscure2,
                        style: const TextStyle(color: Colors.white),
                        decoration: kInputDec(
                          "Confirmer le mot de passe",
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            icon: Icon(
                              obscure2
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey[400],
                            ),
                            onPressed: () =>
                                setDialogState(() => obscure2 = !obscure2),
                          ),
                        ),
                      ),
                    ],
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
                  onPressed: () {
                    if (!emailVerifie) {
                      final email = emailController.text.trim().toLowerCase();
                      if (email.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text("Merci de saisir votre email."),
                          ),
                        );
                        return;
                      }
                      final trouve = globalTailleurs.firstWhere(
                        (t) => t.email.toLowerCase() == email,
                        orElse: () => Tailleur(
                          id: '',
                          nom: '',
                          maisonCouture: '',
                          email: '',
                          telephone: '',
                          motDePasse: '',
                        ),
                      );
                      if (trouve.id.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Aucun compte tailleur trouvé pour cet email.",
                            ),
                          ),
                        );
                        return;
                      }
                      setDialogState(() {
                        tailleurTrouve = trouve;
                        emailVerifie = true;
                      });
                    } else {
                      final nouveau = newPasswordController.text;
                      final confirme = confirmPasswordController.text;
                      if (nouveau.isEmpty || nouveau.length < 4) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Le mot de passe doit contenir au moins 4 caractères.",
                            ),
                          ),
                        );
                        return;
                      }
                      if (nouveau != confirme) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Les mots de passe ne correspondent pas.",
                            ),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        tailleurTrouve!.motDePasse = nouveau;
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Mot de passe réinitialisé avec succès. Connectez-vous.",
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    emailVerifie ? "Réinitialiser" : "Vérifier",
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
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF241C16),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _showForgotPasswordDialog,
                          child: const Text(
                            "Mot de passe oublié?",
                            style: TextStyle(
                              color: Color(0xFFFF8A5C),
                              fontWeight: FontWeight.bold,
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
