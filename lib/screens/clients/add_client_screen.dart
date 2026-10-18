import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../data/app_state.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';

class AddClientScreen extends StatefulWidget {
  final String tailleurId;
  final Client?
  existingClient; // si non-null : on modifie ce client au lieu d'en créer un
  const AddClientScreen({
    Key? key,
    required this.tailleurId,
    this.existingClient,
  }) : super(key: key);

  @override
  _AddClientScreenState createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _telController = TextEditingController();
  final _adresseController = TextEditingController();

  String? _genre;
  // Pour une cliente : type de modèle, qui détermine les mesures affichées
  // ('Robe' → Longueur robe ; sinon → Longueur jupe + Longueur boubou)
  String _modeleFemme = 'Robe';
  final Map<String, TextEditingController> _mesureControllers = {};

  bool _genreErreur = false;

  bool get _estModification => widget.existingClient != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existingClient;
    if (c != null) {
      _nomController.text = c.nom;
      _telController.text = c.telephone;
      _adresseController.text = c.adresse;
      _genre = c.genre;
      if (c.genre == 'Femme') {
        _modeleFemme = c.mesures.containsKey('longueur_robe')
            ? 'Robe'
            : 'Autre';
      }
      _rebuildControleurs();
      for (final label in _labelsMesures) {
        final valeur = c.mesures[_cleMesure(label)];
        if (valeur != null) {
          _mesureControllers[label]!.text = valeur == valeur.roundToDouble()
              ? valeur.toStringAsFixed(0)
              : valeur.toString();
        }
      }
    }
  }

  List<String> get _labelsMesures {
    if (_genre == 'Homme') return kMesuresHomme;
    if (_genre == 'Femme') {
      return [
        ...kMesuresFemmeBase,
        if (_modeleFemme == 'Robe')
          'Longueur robe'
        else ...[
          'Longueur jupe',
          'Longueur boubou',
        ],
      ];
    }
    return [];
  }

  void _choisirGenre(String genre) {
    setState(() {
      _genre = genre;
      _genreErreur = false;
      _rebuildControleurs();
    });
  }

  void _choisirModeleFemme(String modele) {
    setState(() {
      _modeleFemme = modele;
      _rebuildControleurs();
    });
  }

  void _rebuildControleurs() {
    // Prépare un contrôleur vide pour chaque mesure du genre (et du modèle) choisi,
    // en réutilisant la valeur déjà saisie pour les mesures communes.
    final anciens = Map<String, TextEditingController>.from(_mesureControllers);
    _mesureControllers.clear();
    for (final label in _labelsMesures) {
      _mesureControllers[label] = anciens[label] ?? TextEditingController();
    }
    // Dispose les contrôleurs devenus inutiles
    for (final entry in anciens.entries) {
      if (!_mesureControllers.containsKey(entry.key)) {
        entry.value.dispose();
      }
    }
  }

  String _cleMesure(String label) {
    return label
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll(' ', '_');
  }

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
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kOrange, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
    );
  }

  @override
  void dispose() {
    for (final c in _mesureControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_estModification ? "Modifier le Client" : "Nouveau Client"),
        backgroundColor: kCard,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Informations Générales",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nomController,
                style: const TextStyle(color: Colors.white),
                decoration: _dec("Nom Complet"),
                validator: (v) {
                  final val = v?.trim() ?? '';
                  if (val.isEmpty) return "Le nom du client est requis";
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _telController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: _dec("Téléphone"),
                validator: (v) {
                  final raw = v?.trim() ?? '';
                  if (raw.isEmpty) return "Numéro de téléphone invalide";
                  final clean = raw.replaceAll(RegExp(r'[\s\-]'), '');
                  if (!RegExp(r'^[0-9]+$').hasMatch(clean) || clean.length != 9) {
                    return "Numéro de téléphone invalide";
                  }
                  // Unicité du téléphone chez CE tailleur uniquement
                  // (un même numéro peut exister chez un autre tailleur)
                  final doublon = globalClients.any((c) {
                    if (c.tailleurId != widget.tailleurId) return false; // autre tailleur → ignoré
                    if (c.id == widget.existingClient?.id) return false;  // propre fiche en édition → ignoré
                    final cPhone = c.telephone.trim().replaceAll(RegExp(r'[\s\-]'), '');
                    return cPhone == clean;
                  });
                  if (doublon) {
                    return "Ce numéro est déjà utilisé par un client de cet atelier";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _adresseController,
                style: const TextStyle(color: Colors.white),
                decoration: _dec("Adresse"),
                validator: (v) {
                  final val = v?.trim() ?? '';
                  if (val.isEmpty) return "L'adresse est requise";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Genre",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: _genreErreur && _genre == null
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent, width: 1.5),
                      )
                    : null,
                padding: _genreErreur && _genre == null
                    ? const EdgeInsets.all(4)
                    : EdgeInsets.zero,
                child: Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("Homme"),
                        avatar: const Icon(Icons.male, size: 18),
                        selected: _genre == 'Homme',
                        selectedColor: kOrange,
                        labelStyle: TextStyle(
                          color: _genre == 'Homme'
                              ? Colors.white
                              : Colors.grey[300],
                        ),
                        backgroundColor: kInputBg,
                        onSelected: (_) => _choisirGenre('Homme'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("Femme"),
                        avatar: const Icon(Icons.female, size: 18),
                        selected: _genre == 'Femme',
                        selectedColor: kOrange,
                        labelStyle: TextStyle(
                          color: _genre == 'Femme'
                              ? Colors.white
                              : Colors.grey[300],
                        ),
                        backgroundColor: kInputBg,
                        onSelected: (_) => _choisirGenre('Femme'),
                      ),
                    ),
                  ],
                ),
              ),
              if (_genreErreur && _genre == null)
                const Padding(
                  padding: EdgeInsets.only(left: 4, top: 6),
                  child: Text(
                    "Veuillez choisir un genre",
                    style: TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
              if (_genre == 'Femme') ...[
                const SizedBox(height: 16),
                const Text(
                  "Type de modèle",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("Robe"),
                        selected: _modeleFemme == 'Robe',
                        selectedColor: kOrange,
                        labelStyle: TextStyle(
                          color: _modeleFemme == 'Robe'
                              ? Colors.white
                              : Colors.grey[300],
                        ),
                        backgroundColor: kInputBg,
                        onSelected: (_) => _choisirModeleFemme('Robe'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("Autre (jupe / boubou)"),
                        selected: _modeleFemme != 'Robe',
                        selectedColor: kOrange,
                        labelStyle: TextStyle(
                          color: _modeleFemme != 'Robe'
                              ? Colors.white
                              : Colors.grey[300],
                        ),
                        backgroundColor: kInputBg,
                        onSelected: (_) => _choisirModeleFemme('Autre'),
                      ),
                    ),
                  ],
                ),
              ],
              if (_genre != null) ...[
                const SizedBox(height: 20),
                Text(
                  "Mesures Corporelles — ${_genre == 'Homme' ? 'Homme' : 'Femme'} (cm)",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                ..._buildChampsMesures(),
              ],
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final formValide = _formKey.currentState!.validate();
                  if (_genre == null) {
                    setState(() => _genreErreur = true);
                  }
                  if (!formValide || _genre == null) {
                    return;
                  }

                  final mesures = <String, double>{};
                  _mesureControllers.forEach((label, controller) {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      final val = double.tryParse(text);
                      if (val != null && val > 0) {
                        mesures[_cleMesure(label)] = val;
                      }
                    }
                  });

                  final client = Client(
                    id:
                        widget.existingClient?.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    tailleurId: widget.tailleurId,
                    nom: _nomController.text.trim(),
                    telephone: _telController.text.trim().replaceAll(RegExp(r'\s+'), ''),
                    adresse: _adresseController.text.trim(),
                    genre: _genre!,
                    mesures: mesures,
                    motDePasse: widget.existingClient?.motDePasse,
                  );
                  Navigator.pop(context, client);
                },
                child: Text(
                  _estModification
                      ? "Enregistrer les modifications"
                      : "Enregistrer le Client",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validerMesure(String? v) {
    final val = v?.trim() ?? '';
    if (val.isEmpty) return null;
    final n = double.tryParse(val);
    if (n == null || n <= 0) {
      return "Mesure invalide";
    }
    return null;
  }

  // Affiche les champs de mesures deux par deux, adaptés au genre choisi
  List<Widget> _buildChampsMesures() {
    final widgets = <Widget>[];
    for (int i = 0; i < _labelsMesures.length; i += 2) {
      final label1 = _labelsMesures[i];
      final label2 = i + 1 < _labelsMesures.length
          ? _labelsMesures[i + 1]
          : null;
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _mesureControllers[label1],
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _dec(label1),
                  validator: _validerMesure,
                ),
              ),
              if (label2 != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _mesureControllers[label2],
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _dec(label2),
                    validator: _validerMesure,
                  ),
                ),
              ] else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }
    return widgets;
  }
}
