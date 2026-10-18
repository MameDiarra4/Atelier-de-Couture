import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';

class AddCommandeScreen extends StatefulWidget {
  final String clientId;
  final String clientNom;
  final Commande?
  existingCommande; // si non-null : on modifie cette commande au lieu d'en créer une

  const AddCommandeScreen({
    Key? key,
    required this.clientId,
    required this.clientNom,
    this.existingCommande,
  }) : super(key: key);

  @override
  _AddCommandeScreenState createState() => _AddCommandeScreenState();
}

class _AddCommandeScreenState extends State<AddCommandeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _modeleController = TextEditingController();
  final TextEditingController _tissuController = TextEditingController();
  final TextEditingController _montantTotalController = TextEditingController();
  final TextEditingController _acompteController = TextEditingController();

  DateTime? _selectedDate;
  double _resteAPayer = 0.0;
  Uint8List? _photoModele;
  final ImagePicker _picker = ImagePicker();

  bool get _estModification => widget.existingCommande != null;

  @override
  void initState() {
    super.initState();
    final cmd = widget.existingCommande;
    if (cmd != null) {
      _modeleController.text = cmd.modele;
      _tissuController.text = cmd.tissu;
      _montantTotalController.text = cmd.montantTotal.toStringAsFixed(0);
      _acompteController.text = cmd.acompte.toStringAsFixed(0);
      _selectedDate = cmd.dateLivraison;
      _photoModele = cmd.photoModele;
      _resteAPayer = cmd.resteAPayer;
    }
  }

  void _calculerReste() {
    double total = double.tryParse(_montantTotalController.text) ?? 0.0;
    double acompte = double.tryParse(_acompteController.text) ?? 0.0;
    setState(() => _resteAPayer = total - acompte);
  }

  Future<void> _choisirPhoto() async {
    showModalBottomSheet(
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
                  "Photo du modèle",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera_outlined,
                  color: kOrange,
                ),
                title: const Text(
                  "Prendre une photo",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _prendrePhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: kOrange,
                ),
                title: const Text(
                  "Choisir depuis la galerie",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _prendrePhoto(ImageSource.gallery);
                },
              ),
              if (_photoModele != null)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    "Retirer la photo",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () {
                    setState(() => _photoModele = null);
                    Navigator.pop(ctx);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _prendrePhoto(ImageSource source) async {
    try {
      final XFile? fichier = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (fichier != null) {
        final bytes = await fichier.readAsBytes();
        setState(() => _photoModele = bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Impossible d'accéder à la caméra/galerie : $e"),
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  InputDecoration _dec(String label, {Widget? icon}) {
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
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _estModification
              ? "Modifier commande - ${widget.clientNom}"
              : "Commande - ${widget.clientNom}",
        ),
        backgroundColor: kCard,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _modeleController,
                style: const TextStyle(color: Colors.white),
                decoration: _dec(
                  "Modèle",
                  icon: const Icon(Icons.checkroom, color: kOrange),
                ),
                validator: (v) {
                  final val = v?.trim() ?? '';
                  if (val.isEmpty) return "Le modèle est requis";
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _tissuController,
                style: const TextStyle(color: Colors.white),
                decoration: _dec(
                  "Tissu",
                  icon: const Icon(Icons.color_lens, color: kOrange),
                ),
                validator: (v) {
                  final val = v?.trim() ?? '';
                  if (val.isEmpty) return "Le tissu est requis";
                  return null;
                },
              ),
              const SizedBox(height: 15),
              FormField<DateTime>(
                initialValue: _selectedDate,
                validator: (_) {
                  if (_selectedDate == null) {
                    return "La date doit être dans le futur";
                  }
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final selected = DateTime(
                    _selectedDate!.year,
                    _selectedDate!.month,
                    _selectedDate!.day,
                  );
                  if (selected.isBefore(today)) {
                    return "La date doit être dans le futur";
                  }
                  return null;
                },
                builder: (fieldState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Material(
                        color: kInputBg,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: fieldState.hasError
                                ? Border.all(color: Colors.redAccent, width: 1.5)
                                : null,
                          ),
                          child: ListTile(
                            tileColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          leading: const Icon(Icons.calendar_today, color: kOrange),
                          title: Text(
                            _selectedDate == null
                                ? "Choisir la date de livraison"
                                : "Livraison le : ${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white70,
                            size: 16,
                          ),
                          onTap: () async {
                            await _selectDate(context);
                            fieldState.didChange(_selectedDate);
                          },
                        ),
                      ),
                    ),
                      if (fieldState.hasError)
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 6),
                          child: Text(
                            fieldState.errorText!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const Divider(color: Colors.white24),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _montantTotalController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _dec("Montant Total"),
                      onChanged: (_) {
                        _calculerReste();
                        if (_acompteController.text.isNotEmpty) {
                          _formKey.currentState?.validate();
                        }
                      },
                      validator: (v) {
                        final val = v?.trim() ?? '';
                        if (val.isEmpty) return "Montant invalide";
                        final n = double.tryParse(val);
                        if (n == null || n <= 0) {
                          return "Montant invalide";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _acompteController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _dec("Acompte"),
                      onChanged: (_) => _calculerReste(),
                      validator: (v) {
                        final val = v?.trim() ?? '';
                        if (val.isEmpty) return null;
                        final acompte = double.tryParse(val);
                        if (acompte == null || acompte < 0) {
                          return "Montant invalide";
                        }
                        final total = double.tryParse(_montantTotalController.text.trim()) ?? 0.0;
                        if (acompte > total) {
                          return "L'acompte ne peut pas dépasser le montant total";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kOrange),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Reste à Payer :",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "${_resteAPayer.toStringAsFixed(0)} FCFA",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kOrange,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Photo du modèle",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _choisirPhoto,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: kInputBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: _photoModele == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_a_photo_outlined,
                              color: kOrange,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Prendre une photo ou choisir dans la galerie",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.memory(
                                _photoModele!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black.withOpacity(0.6),
                                radius: 16,
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(280, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  final commande = Commande(
                    id:
                        widget.existingCommande?.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    clientId: widget.clientId,
                    modele: _modeleController.text.trim(),
                    tissu: _tissuController.text.trim(),
                    dateLivraison: _selectedDate!,
                    statut: widget.existingCommande?.statut ?? "Mesure",
                    montantTotal:
                        double.parse(_montantTotalController.text.trim()),
                    acompte:
                        double.tryParse(_acompteController.text.trim()) ?? 0.0,
                    photoModele: _photoModele,
                  );

                  Navigator.pop(context, commande);
                },
                child: Text(
                  _estModification
                      ? "Enregistrer les modifications"
                      : "Enregistrer la Commande",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
