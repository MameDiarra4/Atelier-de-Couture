/**
 * ================================================================
 * SCRIPT DE PEUPLEMENT FIRESTORE — DigitSagnse
 * ================================================================
 *
 * Ce script injecte les données de démonstration dans Firebase Firestore.
 * Il crée les collections : tailleurs, clients, commandes, rendezvous, paiements.
 *
 * PRÉREQUIS :
 *   1. Node.js installé (https://nodejs.org)
 *   2. Installer les dépendances :
 *        npm install firebase-admin
 *   3. Télécharger la clé de service Firebase :
 *        Firebase Console → Paramètres du projet → Comptes de service
 *        → Générer une nouvelle clé privée → Enregistrer sous "serviceAccountKey.json"
 *   4. Placer "serviceAccountKey.json" dans le même dossier que ce script
 *
 * EXÉCUTION :
 *        node seed_data.js
 * ================================================================
 */

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

// ── Initialisation Firebase Admin ──────────────────────────────
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// ================================================================
// DONNÉES DE DÉMONSTRATION
// ================================================================

// ── 1. TAILLEUR ────────────────────────────────────────────────
const TAILLEUR_ID = "tailleur_demo_001";

const tailleurDemo = {
  id: TAILLEUR_ID,
  nom: "Cheikh Diallo",
  maisonCouture: "DigitSagnse Couture",
  email: "cheikh@atelier.sn",
  telephone: "779876543",
  motDePasse: "atelier123",
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
};

// ── 2. CLIENTS ─────────────────────────────────────────────────
const CLIENT_1_ID = "client_awa_001";
const CLIENT_2_ID = "client_moussa_002";
const CLIENT_3_ID = "client_fatou_003";

const clientsDemo = [
  {
    id: CLIENT_1_ID,
    tailleurId: TAILLEUR_ID,
    nom: "Awa Ndiaye",
    telephone: "771234567",
    adresse: "Sicap Liberté 3, Dakar",
    genre: "Femme",
    mesures: {
      poitrine: 92.0,
      epaule: 38.0,
      taille: 74.0,
      fesses: 98.0,
      blouse: 58.0,
      robe_jupe: 100.0,
      boubou: 150.0,
    },
    motDePasse: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: CLIENT_2_ID,
    tailleurId: TAILLEUR_ID,
    nom: "Moussa Ba",
    telephone: "781122334",
    adresse: "Parcelles Assainies, Dakar",
    genre: "Homme",
    mesures: {
      poitrine: 102.0,
      epaule: 46.0,
      fesses: 105.0,
      col: 41.0,
      boubou: 160.0,
      pantalon: 100.0,
      manche: 62.0,
      ceinture: 88.0,
    },
    motDePasse: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: CLIENT_3_ID,
    tailleurId: TAILLEUR_ID,
    nom: "Fatou Sow",
    telephone: "706655443",
    adresse: "Yoff, Dakar",
    genre: "Femme",
    mesures: {
      poitrine: 88.0,
      epaule: 36.0,
      taille: 70.0,
      fesses: 94.0,
      blouse: 55.0,
      robe_jupe: 95.0,
      boubou: 145.0,
    },
    motDePasse: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

// ── 3. COMMANDES ───────────────────────────────────────────────
const COMMANDE_1_ID = "commande_001";
const COMMANDE_2_ID = "commande_002";
const COMMANDE_3_ID = "commande_003";

const now = new Date();
const in7Days  = new Date(now.getTime() + 7  * 24 * 60 * 60 * 1000);
const in14Days = new Date(now.getTime() + 14 * 24 * 60 * 60 * 1000);
const in3Days  = new Date(now.getTime() + 3  * 24 * 60 * 60 * 1000);

const commandesDemo = [
  {
    id: COMMANDE_1_ID,
    clientId: CLIENT_1_ID,
    tailleurId: TAILLEUR_ID,
    modele: "Robe soirée wax imprimé",
    tissu: "Wax hollandais",
    dateLivraison: in14Days.toISOString(),
    statut: "Coupe",
    montantTotal: 45000.0,
    acompte: 20000.0,
    resteAPayer: 25000.0,
    photoBase64: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: COMMANDE_2_ID,
    clientId: CLIENT_2_ID,
    tailleurId: TAILLEUR_ID,
    modele: "Grand boubou bazin brodé",
    tissu: "Bazin riche blanc",
    dateLivraison: in7Days.toISOString(),
    statut: "Essayage",
    montantTotal: 65000.0,
    acompte: 40000.0,
    resteAPayer: 25000.0,
    photoBase64: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: COMMANDE_3_ID,
    clientId: CLIENT_3_ID,
    tailleurId: TAILLEUR_ID,
    modele: "Ensemble tailleur ankara",
    tissu: "Ankara (coton imprimé)",
    dateLivraison: in3Days.toISOString(),
    statut: "Finition",
    montantTotal: 35000.0,
    acompte: 35000.0,
    resteAPayer: 0.0,
    photoBase64: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

// ── 4. RENDEZ-VOUS ─────────────────────────────────────────────
const tomorrow = new Date(now.getTime() + 1 * 24 * 60 * 60 * 1000);
tomorrow.setHours(10, 30, 0, 0);

const rdvDemo = [
  {
    id: "rdv_001",
    commandeId: COMMANDE_2_ID,
    clientId: CLIENT_2_ID,
    type: "Essayage",
    dateHeure: tomorrow.toISOString(),
    note: "Vérifier la longueur des manches",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "rdv_002",
    commandeId: COMMANDE_1_ID,
    clientId: CLIENT_1_ID,
    type: "Essayage",
    dateHeure: in7Days.toISOString(),
    note: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "rdv_003",
    commandeId: COMMANDE_3_ID,
    clientId: CLIENT_3_ID,
    type: "Retrait",
    dateHeure: in3Days.toISOString(),
    note: "Livraison à domicile possible",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

// ── 5. PAIEMENTS ───────────────────────────────────────────────
const yesterday = new Date(now.getTime() - 1 * 24 * 60 * 60 * 1000);
const lastWeek  = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

const paiementsDemo = [
  {
    id: "paiement_001",
    commandeId: COMMANDE_1_ID,
    clientId: CLIENT_1_ID,
    tailleurId: TAILLEUR_ID,
    montant: 20000.0,
    date: lastWeek.toISOString(),
    mode: "Wave",
    note: "Acompte initial",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "paiement_002",
    commandeId: COMMANDE_2_ID,
    clientId: CLIENT_2_ID,
    tailleurId: TAILLEUR_ID,
    montant: 30000.0,
    date: lastWeek.toISOString(),
    mode: "Espèces",
    note: "Acompte initial",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "paiement_003",
    commandeId: COMMANDE_2_ID,
    clientId: CLIENT_2_ID,
    tailleurId: TAILLEUR_ID,
    montant: 10000.0,
    date: yesterday.toISOString(),
    mode: "Orange Money",
    note: "Deuxième versement",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "paiement_004",
    commandeId: COMMANDE_3_ID,
    clientId: CLIENT_3_ID,
    tailleurId: TAILLEUR_ID,
    montant: 35000.0,
    date: lastWeek.toISOString(),
    mode: "Espèces",
    note: "Paiement complet",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

// ================================================================
// FONCTION D'INJECTION DANS FIRESTORE
// ================================================================
async function seedFirestore() {
  console.log("🚀 Démarrage du peuplement de Firestore — DigitSagnse...\n");

  try {
    // ── Tailleur ──
    console.log("📌 Insertion du tailleur de démo...");
    await db.collection("tailleurs").doc(TAILLEUR_ID).set(tailleurDemo);
    console.log(`   ✅ Tailleur "${tailleurDemo.nom}" inséré (ID: ${TAILLEUR_ID})`);

    // ── Clients ──
    console.log("\n📌 Insertion des clients...");
    for (const client of clientsDemo) {
      await db.collection("clients").doc(client.id).set(client);
      console.log(`   ✅ Client "${client.nom}" inséré (ID: ${client.id})`);
    }

    // ── Commandes ──
    console.log("\n📌 Insertion des commandes...");
    for (const commande of commandesDemo) {
      await db.collection("commandes").doc(commande.id).set(commande);
      console.log(`   ✅ Commande "${commande.modele}" insérée (statut: ${commande.statut})`);
    }

    // ── Rendez-vous ──
    console.log("\n📌 Insertion des rendez-vous...");
    for (const rdv of rdvDemo) {
      await db.collection("rendezvous").doc(rdv.id).set(rdv);
      console.log(`   ✅ RDV ${rdv.type} inséré (ID: ${rdv.id})`);
    }

    // ── Paiements ──
    console.log("\n📌 Insertion des paiements...");
    for (const paiement of paiementsDemo) {
      await db.collection("paiements").doc(paiement.id).set(paiement);
      console.log(`   ✅ Paiement de ${paiement.montant} FCFA inséré (mode: ${paiement.mode})`);
    }

    console.log("\n════════════════════════════════════════════");
    console.log("✅ Peuplement Firestore terminé avec succès !");
    console.log("════════════════════════════════════════════");
    console.log("\n🔑 Compte Tailleur démo :");
    console.log("   Email      : cheikh@atelier.sn");
    console.log("   Mot de passe : atelier123");
    console.log("\n📱 Compte Client démo :");
    console.log("   Téléphone  : 771234567 (Awa Ndiaye)");

  } catch (error) {
    console.error("❌ Erreur lors du peuplement :", error);
  } finally {
    process.exit(0);
  }
}

// Lancer le script
seedFirestore();
