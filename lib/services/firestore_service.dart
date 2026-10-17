import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../firebase_options.dart';

// ==========================================
// SERVICE FIRESTORE PRINCIPAL
// ==========================================
class FirestoreService {
  FirestoreService._privateConstructor();
  static final FirestoreService instance =
      FirestoreService._privateConstructor();

  static bool isAvailable = false;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Initialisation sécurisée de Firebase (Web et Mobile)
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      isAvailable = true;
      debugPrint(
        "✅ Firebase connecté avec succès sur ${kIsWeb ? 'Web/Chrome' : 'Mobile'} !",
      );
    } catch (e) {
      isAvailable = false;
      debugPrint("⚠️ Erreur connexion Firebase : $e");
    }
  }

  // ----------------------------------------------------
  // GESTION DES CLIENTS (Étape 4)
  // ----------------------------------------------------

  /// Ajouter un client dans Firestore
  Future<void> ajouterClient(Client client) async {
    if (!isAvailable) return;
    try {
      await _db.collection('clients').doc(client.id).set({
        ...client.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint(
        "✅ Client ${client.nom} ajouté à Firestore (ID: ${client.id})",
      );
    } catch (e) {
      debugPrint("❌ Erreur ajouterClient : $e");
      rethrow;
    }
  }

  /// Modifier un client existant dans Firestore
  Future<void> modifierClient(Client client) async {
    if (!isAvailable) return;
    try {
      await _db.collection('clients').doc(client.id).update({
        ...client.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint(
        "✅ Client ${client.nom} modifié dans Firestore (ID: ${client.id})",
      );
    } catch (e) {
      debugPrint("❌ Erreur modifierClient : $e");
      rethrow;
    }
  }

  /// Modifier spécifiquement les mesures d'un client
  Future<void> modifierMesures(
    String clientId,
    Map<String, double> nouvellesMesures,
  ) async {
    if (!isAvailable) return;
    try {
      await _db.collection('clients').doc(clientId).update({
        'mesures': nouvellesMesures,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Mesures du client $clientId mises à jour dans Firestore");
    } catch (e) {
      debugPrint("❌ Erreur modifierMesures : $e");
      rethrow;
    }
  }

  /// Supprimer un client et ses données associées
  Future<void> supprimerClient(String clientId) async {
    if (!isAvailable) return;
    try {
      await _db.collection('clients').doc(clientId).delete();

      // Supprimer les commandes associées
      final commandesSnap = await _db
          .collection('commandes')
          .where('clientId', isEqualTo: clientId)
          .get();
      for (final doc in commandesSnap.docs) {
        await doc.reference.delete();
      }

      // Supprimer les rendez-vous associés
      final rdvSnap = await _db
          .collection('rendezvous')
          .where('clientId', isEqualTo: clientId)
          .get();
      for (final doc in rdvSnap.docs) {
        await doc.reference.delete();
      }

      // Supprimer les paiements associés
      final pSnap = await _db
          .collection('paiements')
          .where('clientId', isEqualTo: clientId)
          .get();
      for (final doc in pSnap.docs) {
        await doc.reference.delete();
      }

      debugPrint(
        "✅ Client $clientId et données associées supprimés de Firestore",
      );
    } catch (e) {
      debugPrint("❌ Erreur supprimerClient : $e");
      rethrow;
    }
  }

  /// Récupérer la liste des clients depuis Firestore
  Future<List<Client>> getClients({String? tailleurId}) async {
    if (!isAvailable) return [];
    try {
      Query<Map<String, dynamic>> query = _db.collection('clients');
      if (tailleurId != null && tailleurId.isNotEmpty) {
        query = query.where('tailleurId', isEqualTo: tailleurId);
      }
      final snap = await query.get();
      return snap.docs
          .map((doc) => Client.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("❌ Erreur getClients : $e");
      return [];
    }
  }

  /// Stream des clients en temps réel
  Stream<List<Client>> streamClients({String? tailleurId}) {
    if (!isAvailable) return const Stream.empty();
    Query<Map<String, dynamic>> query = _db.collection('clients');
    if (tailleurId != null && tailleurId.isNotEmpty) {
      query = query.where('tailleurId', isEqualTo: tailleurId);
    }
    return query.snapshots().map(
      (snap) => snap.docs.map((d) => Client.fromMap(d.data(), d.id)).toList(),
    );
  }

  // ----------------------------------------------------
  // GESTION DES COMMANDES (Étape 4)
  // ----------------------------------------------------

  /// Créer une commande dans Firestore
  Future<void> creerCommande(Commande commande) async {
    if (!isAvailable) return;
    try {
      await _db.collection('commandes').doc(commande.id).set({
        ...commande.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint(
        "✅ Commande ${commande.id} (${commande.modele}) créée dans Firestore",
      );
    } catch (e) {
      debugPrint("❌ Erreur creerCommande : $e");
      rethrow;
    }
  }

  /// Modifier une commande
  Future<void> modifierCommande(Commande commande) async {
    if (!isAvailable) return;
    try {
      await _db.collection('commandes').doc(commande.id).update({
        ...commande.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Commande ${commande.id} mise à jour dans Firestore");
    } catch (e) {
      debugPrint("❌ Erreur modifierCommande : $e");
      rethrow;
    }
  }

  /// Modifier le statut d'une commande (ex: Mesure -> Coupe -> Essayage -> Finition -> Livré)
  Future<void> modifierStatutCommande(
    String commandeId,
    String nouveauStatut,
  ) async {
    if (!isAvailable) return;
    try {
      await _db.collection('commandes').doc(commandeId).update({
        'statut': nouveauStatut,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint(
        "✅ Statut de la commande $commandeId mis à jour : $nouveauStatut",
      );
    } catch (e) {
      debugPrint("❌ Erreur modifierStatutCommande : $e");
      rethrow;
    }
  }

  /// Supprimer une commande
  Future<void> supprimerCommande(String commandeId) async {
    if (!isAvailable) return;
    try {
      await _db.collection('commandes').doc(commandeId).delete();

      final rdvSnap = await _db
          .collection('rendezvous')
          .where('commandeId', isEqualTo: commandeId)
          .get();
      for (final doc in rdvSnap.docs) {
        await doc.reference.delete();
      }

      final pSnap = await _db
          .collection('paiements')
          .where('commandeId', isEqualTo: commandeId)
          .get();
      for (final doc in pSnap.docs) {
        await doc.reference.delete();
      }

      debugPrint("✅ Commande $commandeId supprimée de Firestore");
    } catch (e) {
      debugPrint("❌ Erreur supprimerCommande : $e");
      rethrow;
    }
  }

  /// Récupérer les commandes depuis Firestore
  Future<List<Commande>> getCommandes({String? clientId}) async {
    if (!isAvailable) return [];
    try {
      Query<Map<String, dynamic>> query = _db.collection('commandes');
      if (clientId != null && clientId.isNotEmpty) {
        query = query.where('clientId', isEqualTo: clientId);
      }
      final snap = await query.get();
      return snap.docs
          .map((doc) => Commande.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("❌ Erreur getCommandes : $e");
      return [];
    }
  }

  /// Stream des commandes en temps réel
  Stream<List<Commande>> streamCommandes({String? clientId}) {
    if (!isAvailable) return const Stream.empty();
    Query<Map<String, dynamic>> query = _db.collection('commandes');
    if (clientId != null && clientId.isNotEmpty) {
      query = query.where('clientId', isEqualTo: clientId);
    }
    return query.snapshots().map(
      (snap) => snap.docs.map((d) => Commande.fromMap(d.data(), d.id)).toList(),
    );
  }

  // ----------------------------------------------------
  // GESTION DES PAIEMENTS (Étape 4)
  // ----------------------------------------------------

  /// Enregistrer un paiement et mettre à jour l'acompte de la commande
  Future<void> enregistrerPaiement(Paiement paiement) async {
    if (!isAvailable) return;
    try {
      final paiementRef = _db.collection('paiements').doc(paiement.id);
      final commandeRef = _db.collection('commandes').doc(paiement.commandeId);

      // Création du paiement
      await paiementRef.set({
        ...paiement.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Mise à jour de l'acompte de la commande dans une transaction
      await _db.runTransaction((transaction) async {
        final commandeDoc = await transaction.get(commandeRef);
        if (commandeDoc.exists) {
          final data = commandeDoc.data()!;
          final double acompteActuel =
              (data['acompte'] as num?)?.toDouble() ?? 0.0;
          final double total =
              (data['montantTotal'] as num?)?.toDouble() ?? 0.0;
          final double nouvelAcompte = acompteActuel + paiement.montant;
          final double reste = total - nouvelAcompte;

          transaction.update(commandeRef, {
            'acompte': nouvelAcompte,
            'resteAPayer': reste,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      debugPrint(
        "✅ Versement de ${paiement.montant} FCFA enregistré pour la commande ${paiement.commandeId}",
      );
    } catch (e) {
      debugPrint("❌ Erreur enregistrerPaiement : $e");
      rethrow;
    }
  }

  /// Récupérer les paiements d'une commande
  Future<List<Paiement>> getPaiements(String commandeId) async {
    if (!isAvailable) return [];
    try {
      final snap = await _db
          .collection('paiements')
          .where('commandeId', isEqualTo: commandeId)
          .get();
      return snap.docs
          .map((doc) => Paiement.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("❌ Erreur getPaiements : $e");
      return [];
    }
  }

  // ----------------------------------------------------
  // GESTION DES RENDEZ-VOUS
  // ----------------------------------------------------

  Future<void> creerRendezVous(RendezVous rdv) async {
    if (!isAvailable) return;
    try {
      await _db.collection('rendezvous').doc(rdv.id).set({
        ...rdv.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Rendez-vous ${rdv.id} enregistré dans Firestore");
    } catch (e) {
      debugPrint("❌ Erreur creerRendezVous : $e");
      rethrow;
    }
  }

  Future<void> supprimerRendezVous(String id) async {
    if (!isAvailable) return;
    try {
      await _db.collection('rendezvous').doc(id).delete();
      debugPrint("✅ Rendez-vous $id supprimé de Firestore");
    } catch (e) {
      debugPrint("❌ Erreur supprimerRendezVous : $e");
      rethrow;
    }
  }

  Future<List<RendezVous>> getRendezVous({String? clientId}) async {
    if (!isAvailable) return [];
    try {
      Query<Map<String, dynamic>> query = _db.collection('rendezvous');
      if (clientId != null && clientId.isNotEmpty) {
        query = query.where('clientId', isEqualTo: clientId);
      }
      final snap = await query.get();
      return snap.docs
          .map((doc) => RendezVous.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("❌ Erreur getRendezVous : $e");
      return [];
    }
  }

  // ----------------------------------------------------
  // GESTION DES TAILLEURS
  // ----------------------------------------------------

  Future<void> enregistrerTailleur(Tailleur tailleur) async {
    if (!isAvailable) return;
    try {
      await _db.collection('tailleurs').doc(tailleur.id).set({
        ...tailleur.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Tailleur ${tailleur.nom} enregistré dans Firestore");
    } catch (e) {
      debugPrint("❌ Erreur enregistrerTailleur : $e");
      rethrow;
    }
  }

  Future<List<Tailleur>> getTailleurs() async {
    if (!isAvailable) return [];
    try {
      final snap = await _db.collection('tailleurs').get();
      return snap.docs
          .map((doc) => Tailleur.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("❌ Erreur getTailleurs : $e");
      return [];
    }
  }

  /// Récupérer un tailleur par son email (insensible à la casse)
  Future<Tailleur?> getTailleurByEmail(String email) async {
    if (!isAvailable) return null;
    try {
      final cleanEmail = email.trim().toLowerCase();
      final snap = await _db.collection('tailleurs').get();
      for (final doc in snap.docs) {
        final t = Tailleur.fromMap(doc.data(), doc.id);
        if (t.email.trim().toLowerCase() == cleanEmail) {
          return t;
        }
      }
      return null;
    } catch (e) {
      debugPrint("❌ Erreur getTailleurByEmail : $e");
      return null;
    }
  }

  /// Récupérer un client par son numéro de téléphone
  Future<Client?> getClientByTelephone(String telephone) async {
    if (!isAvailable) return null;
    try {
      final cleanTel = telephone.replaceAll(RegExp(r'\s+'), '').trim();
      final snap = await _db.collection('clients').get();
      for (final doc in snap.docs) {
        final c = Client.fromMap(doc.data(), doc.id);
        if (c.telephone.replaceAll(RegExp(r'\s+'), '').trim() == cleanTel) {
          return c;
        }
      }
      return null;
    } catch (e) {
      debugPrint("❌ Erreur getClientByTelephone : $e");
      return null;
    }
  }

  /// Charge spécifiquement et complètement les données d'un tailleur connecté
  Future<void> chargerDonneesTailleur({
    required String tailleurId,
    required List<Client> targetClients,
    required List<Commande> targetCommandes,
    required List<RendezVous> targetRendezVous,
  }) async {
    if (!isAvailable) return;
    try {
      // 1. Récupérer les clients appartenant à ce tailleur
      final snapClients = await _db
          .collection('clients')
          .where('tailleurId', isEqualTo: tailleurId)
          .get();

      final clients = snapClients.docs
          .map((doc) => Client.fromMap(doc.data(), doc.id))
          .toList();

      targetClients.clear();
      targetClients.addAll(clients);

      final clientIds = clients.map((c) => c.id).toSet();

      // 2. Récupérer les commandes
      final snapCommandes = await _db.collection('commandes').get();
      final mesCommandes = <Commande>[];
      for (final doc in snapCommandes.docs) {
        final data = doc.data();
        final c = Commande.fromMap(data, doc.id);
        if (clientIds.contains(c.clientId) ||
            data['tailleurId'] == tailleurId) {
          mesCommandes.add(c);
        }
      }
      targetCommandes.clear();
      targetCommandes.addAll(mesCommandes);

      // 3. Récupérer les rendez-vous
      final commandeIds = mesCommandes.map((c) => c.id).toSet();
      final snapRdv = await _db.collection('rendezvous').get();
      final mesRdv = <RendezVous>[];
      for (final doc in snapRdv.docs) {
        final r = RendezVous.fromMap(doc.data(), doc.id);
        if (clientIds.contains(r.clientId) ||
            commandeIds.contains(r.commandeId)) {
          mesRdv.add(r);
        }
      }
      targetRendezVous.clear();
      targetRendezVous.addAll(mesRdv);

      debugPrint(
        "🔄 Données chargées pour tailleur $tailleurId : "
        "${targetClients.length} client(s), ${targetCommandes.length} commande(s), ${targetRendezVous.length} rdv.",
      );
    } catch (e) {
      debugPrint("❌ Erreur chargerDonneesTailleur : $e");
    }
  }

  // ----------------------------------------------------
  // SYNCHRONISATION GLOBALE AVEC L'APPLICATION
  // ----------------------------------------------------

  /// Charge toutes les données de Firestore dans les listes mémoire de l'application
  Future<void> synchroniserDonnees({
    required List<Client> targetClients,
    required List<Commande> targetCommandes,
    required List<Tailleur> targetTailleurs,
    required List<RendezVous> targetRendezVous,
  }) async {
    if (!isAvailable) return;
    try {
      final clients = await getClients();
      final commandes = await getCommandes();
      final tailleurs = await getTailleurs();
      final rdv = await getRendezVous();

      if (clients.isNotEmpty) {
        targetClients.clear();
        targetClients.addAll(clients);
      }
      if (commandes.isNotEmpty) {
        targetCommandes.clear();
        targetCommandes.addAll(commandes);
      }
      if (tailleurs.isNotEmpty) {
        targetTailleurs.clear();
        targetTailleurs.addAll(tailleurs);
      }
      if (rdv.isNotEmpty) {
        targetRendezVous.clear();
        targetRendezVous.addAll(rdv);
      }
      debugPrint(
        "🔄 Synchronisation Firestore terminée : ${targetClients.length} clients, ${targetCommandes.length} commandes.",
      );
    } catch (e) {
      debugPrint("⚠️ Erreur lors de la synchronisation des données : $e");
    }
  }
}
