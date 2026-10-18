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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _loginErrorEmail;
  String? _loginErrorPassword;

  void _seConnecter() {
    setState(() {
      _loginErrorEmail = null;
      _loginErrorPassword = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim().toLowerCase();
    final motDePasse = _passwordController.text;

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
      setState(() {
        _loginErrorEmail = "Aucun compte tailleur trouvé pour cet email.";
      });
      _formKey.currentState!.validate();
      return;
    }

    if (tailleur.motDePasse != motDePasse) {
      setState(() {
        _loginErrorPassword = "Mot de passe incorrect.";
      });
      _formKey.currentState!.validate();
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
    final formKeyStep1 = GlobalKey<FormState>();
    final formKeyStep2 = GlobalKey<FormState>();
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
                      Form(
                        key: formKeyStep1,
                        child: TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: kInputDec(
                            "Votre email",
                            icon: Icons.mail_outline,
                          ),
                          validator: (v) {
                            final val = v?.trim() ?? '';
                            if (val.isEmpty || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(val)) {
                              return "Email invalide";
                            }
                            final trouve = globalTailleurs.firstWhere(
                              (t) => t.email.toLowerCase() == val.toLowerCase(),
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
                              return "Aucun compte trouvé pour cet email";
                            }
                            return null;
                          },
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
                      Form(
                        key: formKeyStep2,
                        child: Column(
                          children: [
                            TextFormField(
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
                              validator: (v) {
                                final val = v?.trim() ?? '';
                                if (val.isEmpty || val.length < 4) {
                                  return "Le mot de passe doit contenir au moins 4 caractères";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
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
                              validator: (v) {
                                final val = v?.trim() ?? '';
                                if (val != newPasswordController.text.trim()) {
                                  return "Les mots de passe ne correspondent pas";
                                }
                                return null;
                              },
                            ),
                          ],
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
                      if (!formKeyStep1.currentState!.validate()) {
                        return;
                      }
                      final email = emailController.text.trim().toLowerCase();
                      final trouve = globalTailleurs.firstWhere(
                        (t) => t.email.toLowerCase() == email,
                      );
                      setDialogState(() {
                        tailleurTrouve = trouve;
                        emailVerifie = true;
                      });
                    } else {
                      if (!formKeyStep2.currentState!.validate()) {
                        return;
                      }
                      final nouveau = newPasswordController.text.trim();
                      setState(() {
                        tailleurTrouve!.motDePasse = nouveau;
                      });
                      FirestoreService.instance.enregistrerTailleur(tailleurTrouve!);
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
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.white),
                              decoration: kInputDec(
                                "Entrez votre email",
                                icon: Icons.mail_outline,
                              ),
                              onChanged: (_) {
                                if (_loginErrorEmail != null) {
                                  setState(() => _loginErrorEmail = null);
                                }
                              },
                              validator: (v) {
                                final val = v?.trim() ?? '';
                                if (val.isEmpty ||
                                    !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                        .hasMatch(val)) {
                                  return "Email invalide";
                                }
                                if (_loginErrorEmail != null) {
                                  return _loginErrorEmail;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
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
                              onChanged: (_) {
                                if (_loginErrorPassword != null) {
                                  setState(() => _loginErrorPassword = null);
                                }
                              },
                              validator: (v) {
                                final val = v?.trim() ?? '';
                                if (val.isEmpty) {
                                  return "Mot de passe requis";
                                }
                                if (_loginErrorPassword != null) {
                                  return _loginErrorPassword;
                                }
                                return null;
                              },
                            ),
                          ],
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
