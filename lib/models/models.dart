import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

// ==========================================
// MODÈLE TAILLEUR
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'maisonCouture': maisonCouture,
      'email': email,
      'telephone': telephone,
      'motDePasse': motDePasse,
    };
  }

  factory Tailleur.fromMap(Map<String, dynamic> map, String docId) {
    return Tailleur(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      nom: map['nom'] ?? '',
      maisonCouture: map['maisonCouture'] ?? '',
      email: map['email'] ?? '',
      telephone: map['telephone'] ?? '',
      motDePasse: map['motDePasse'] ?? '',
    );
  }
}

// ==========================================
// MODÈLE CLIENT
// ==========================================
class Client {
  final String id;
  final String tailleurId;
  final String nom;
  final String telephone;
  final String adresse;
  final String genre; // 'Homme' ou 'Femme'
  final Map<String, double> mesures;
  String? motDePasse;

  Client({
    required this.id,
    this.tailleurId = '',
    required this.nom,
    required this.telephone,
    required this.adresse,
    required this.genre,
    required this.mesures,
    this.motDePasse,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tailleurId': tailleurId,
      'nom': nom,
      'telephone': telephone,
      'adresse': adresse,
      'genre': genre,
      'mesures': mesures,
      'motDePasse': motDePasse,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map, String docId) {
    Map<String, double> parsedMesures = {};
    if (map['mesures'] is Map) {
      final raw = map['mesures'] as Map;
      raw.forEach((key, value) {
        if (value is num) {
          parsedMesures[key.toString()] = value.toDouble();
        } else if (value is String) {
          final p = double.tryParse(value);
          if (p != null) parsedMesures[key.toString()] = p;
        }
      });
    }

    return Client(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      tailleurId: map['tailleurId'] ?? '',
      nom: map['nom'] ?? '',
      telephone: map['telephone'] ?? '',
      adresse: map['adresse'] ?? '',
      genre: map['genre'] ?? 'Femme',
      mesures: parsedMesures,
      motDePasse: map['motDePasse'],
    );
  }
}

// ==========================================
// MODÈLE COMMANDE
// ==========================================
class Commande {
  final String id;
  final String clientId;
  final String tailleurId;
  final String modele;
  final String tissu;
  final DateTime dateLivraison;
  String statut; // 'Mesure', 'Coupe', 'Essayage', 'Finition', 'Livré'
  final double montantTotal;
  double acompte;
  final Uint8List? photoModele;

  Commande({
    required this.id,
    required this.clientId,
    this.tailleurId = '',
    required this.modele,
    required this.tissu,
    required this.dateLivraison,
    required this.statut,
    required this.montantTotal,
    required this.acompte,
    this.photoModele,
  });

  double get resteAPayer => montantTotal - acompte;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'tailleurId': tailleurId,
      'modele': modele,
      'tissu': tissu,
      'dateLivraison': dateLivraison.toIso8601String(),
      'statut': statut,
      'montantTotal': montantTotal,
      'acompte': acompte,
      'resteAPayer': resteAPayer,
      'photoBase64': photoModele != null ? base64Encode(photoModele!) : null,
    };
  }

  factory Commande.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedDate;
    if (map['dateLivraison'] is String) {
      parsedDate = DateTime.tryParse(map['dateLivraison']) ?? DateTime.now();
    } else if (map['dateLivraison'] is Timestamp) {
      parsedDate = (map['dateLivraison'] as Timestamp).toDate();
    } else {
      parsedDate = DateTime.now();
    }

    Uint8List? photoBytes;
    if (map['photoBase64'] != null &&
        map['photoBase64'] is String &&
        (map['photoBase64'] as String).isNotEmpty) {
      try {
        photoBytes = base64Decode(map['photoBase64']);
      } catch (_) {}
    }

    return Commande(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      clientId: map['clientId'] ?? '',
      tailleurId: map['tailleurId'] ?? '',
      modele: map['modele'] ?? '',
      tissu: map['tissu'] ?? '',
      dateLivraison: parsedDate,
      statut: map['statut'] ?? 'Mesure',
      montantTotal: (map['montantTotal'] as num?)?.toDouble() ?? 0.0,
      acompte: (map['acompte'] as num?)?.toDouble() ?? 0.0,
      photoModele: photoBytes,
    );
  }
}

// ==========================================
// MODÈLE RENDEZ-VOUS
// ==========================================
class RendezVous {
  final String id;
  final String commandeId;
  final String clientId;
  final String type; // 'Essayage' ou 'Retrait'
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'commandeId': commandeId,
      'clientId': clientId,
      'type': type,
      'dateHeure': dateHeure.toIso8601String(),
      'note': note,
    };
  }

  factory RendezVous.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedDate;
    if (map['dateHeure'] is String) {
      parsedDate = DateTime.tryParse(map['dateHeure']) ?? DateTime.now();
    } else if (map['dateHeure'] is Timestamp) {
      parsedDate = (map['dateHeure'] as Timestamp).toDate();
    } else {
      parsedDate = DateTime.now();
    }

    return RendezVous(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      commandeId: map['commandeId'] ?? '',
      clientId: map['clientId'] ?? '',
      type: map['type'] ?? 'Essayage',
      dateHeure: parsedDate,
      note: map['note'],
    );
  }
}

// ==========================================
// MODÈLE PAIEMENT (FONCTIONNALITÉ PAIEMENT)
// ==========================================
class Paiement {
  final String id;
  final String commandeId;
  final String clientId;
  final String tailleurId;
  final double montant;
  final DateTime date;
  final String? note;
  final String mode; // 'Espèces', 'Wave', 'Orange Money', 'Autre'

  Paiement({
    required this.id,
    required this.commandeId,
    required this.clientId,
    this.tailleurId = '',
    required this.montant,
    required this.date,
    this.note,
    this.mode = 'Espèces',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'commandeId': commandeId,
      'clientId': clientId,
      'tailleurId': tailleurId,
      'montant': montant,
      'date': date.toIso8601String(),
      'note': note,
      'mode': mode,
    };
  }

  factory Paiement.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedDate;
    if (map['date'] is String) {
      parsedDate = DateTime.tryParse(map['date']) ?? DateTime.now();
    } else if (map['createdAt'] is Timestamp) {
      parsedDate = (map['createdAt'] as Timestamp).toDate();
    } else {
      parsedDate = DateTime.now();
    }

    return Paiement(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      commandeId: map['commandeId'] ?? '',
      clientId: map['clientId'] ?? '',
      tailleurId: map['tailleurId'] ?? '',
      montant: (map['montant'] as num?)?.toDouble() ?? 0.0,
      date: parsedDate,
      note: map['note'],
      mode: map['mode'] ?? 'Espèces',
    );
  }
}
