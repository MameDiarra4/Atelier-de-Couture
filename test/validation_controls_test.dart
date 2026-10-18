import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:couture/data/app_state.dart';
import 'package:couture/models/models.dart';
import 'package:couture/screens/auth/tailleur_signup_screen.dart';
import 'package:couture/screens/auth/tailleur_login_screen.dart';
import 'package:couture/screens/clients/add_client_screen.dart';
import 'package:couture/screens/commandes/add_commande_screen.dart';
import 'package:couture/screens/auth/client_login_screen.dart';

void main() {
  setUp(() {
    // Reset test data
    globalTailleurs = [
      Tailleur(
        id: 't1',
        nom: 'Cheikh Lo',
        maisonCouture: 'DigitSagnse Couture',
        email: 'cheikh@atelier.sn',
        telephone: '770000000',
        motDePasse: 'atelier123',
      ),
    ];

    globalClients = [
      Client(
        id: 'c1',
        tailleurId: 't1',
        nom: 'Awa Ndiaye',
        telephone: '771234567',
        adresse: 'Dakar',
        genre: 'Femme',
        mesures: {'poitrine': 90, 'taille': 75},
      ),
    ];
  });

  group('1. Inscription Tailleur - Contrôles de Saisie', () {
    testWidgets('Validation étape 1 : champs vides ou invalides rejetés', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TailleurSignupScreen()));

      // Cliquer sur continuer directement sans rien saisir
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();

      expect(find.text('Le nom est requis'), findsOneWidget);
      expect(find.text("Le nom de l'atelier est requis"), findsOneWidget);
      expect(find.text('Email invalide'), findsOneWidget);
      expect(find.text('Numéro de téléphone invalide'), findsOneWidget);

      // Email sans @ rejeté
      await tester.enterText(find.widgetWithText(TextFormField, 'votre@email.com'), 'nawalatelier.sn');
      // Téléphone avec lettres rejeté
      await tester.enterText(find.widgetWithText(TextFormField, 'Numéro de téléphone'), 'abc1234');
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();

      expect(find.text('Email invalide'), findsOneWidget);
      expect(find.text('Numéro de téléphone invalide'), findsOneWidget);

      // Remplir correctement
      await tester.enterText(find.widgetWithText(TextFormField, 'Ex: Cheikh Lo'), 'Nawal Lo');
      await tester.enterText(find.widgetWithText(TextFormField, 'Nom de votre atelier'), 'Atelier Nawal');
      await tester.enterText(find.widgetWithText(TextFormField, 'votre@email.com'), 'nawal@atelier.sn');
      await tester.enterText(find.widgetWithText(TextFormField, 'Numéro de téléphone'), '772345678');
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();

      // Passe à l'étape 2
      expect(find.text('Étape 2 sur 2'), findsOneWidget);

      // Étape 2 : Mot de passe court et confirmation non concordante
      await tester.enterText(find.widgetWithText(TextFormField, 'Minimum 6 caractères'), '12');
      await tester.enterText(find.widgetWithText(TextFormField, 'Répétez le mot de passe'), '34');
      await tester.tap(find.text('Créer mon compte'));
      await tester.pumpAndSettle();

      expect(find.text('Mot de passe trop court (min. 6 caractères)'), findsOneWidget);
      expect(find.text('Les mots de passe ne correspondent pas'), findsOneWidget);
    });
  });

  group('2. Connexion et Mot de passe oublié', () {
    testWidgets('Login tailleur validation champs invalides', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TailleurLoginScreen()));

      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('Email invalide'), findsOneWidget);
      expect(find.text('Mot de passe requis'), findsOneWidget);
    });

    testWidgets('Mot de passe oublié : email inconnu et validation des mots de passe', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TailleurLoginScreen()));

      await tester.tap(find.text('Mot de passe oublié?'));
      await tester.pumpAndSettle();

      // Email inconnu
      await tester.enterText(find.widgetWithText(TextFormField, 'Votre email'), 'inconnu@atelier.sn');
      await tester.tap(find.text('Vérifier'));
      await tester.pumpAndSettle();

      expect(find.text('Aucun compte trouvé pour cet email'), findsOneWidget);

      // Email existant
      await tester.enterText(find.widgetWithText(TextFormField, 'Votre email'), 'cheikh@atelier.sn');
      await tester.tap(find.text('Vérifier'));
      await tester.pumpAndSettle();

      expect(find.text('Compte trouvé : Cheikh Lo'), findsOneWidget);

      // Nouveau mot de passe trop court
      await tester.enterText(find.widgetWithText(TextFormField, 'Nouveau mot de passe'), '12');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirmer le mot de passe'), '12');
      await tester.tap(find.text('Réinitialiser'));
      await tester.pumpAndSettle();

      expect(find.text('Le mot de passe doit contenir au moins 4 caractères'), findsOneWidget);

      // Mots de passe différents
      await tester.enterText(find.widgetWithText(TextFormField, 'Nouveau mot de passe'), 'pass1234');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirmer le mot de passe'), 'different');
      await tester.tap(find.text('Réinitialiser'));
      await tester.pumpAndSettle();

      expect(find.text('Les mots de passe ne correspondent pas'), findsOneWidget);

      // Succès
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirmer le mot de passe'), 'pass1234');
      await tester.tap(find.text('Réinitialiser'));
      await tester.pumpAndSettle();

      expect(globalTailleurs.first.motDePasse, 'pass1234');
    });
  });

  group('3. Fiche Client (AddClientScreen) - Contrôles et Unicité Téléphone', () {
    testWidgets('Validation fiche client et rejet doublon téléphone', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddClientScreen(tailleurId: 't1')));

      // Soumission vide
      await tester.tap(find.text('Enregistrer le Client'));
      await tester.pumpAndSettle();

      expect(find.text('Le nom du client est requis'), findsOneWidget);
      expect(find.text('Numéro de téléphone invalide'), findsOneWidget);
      expect(find.text("L'adresse est requise"), findsOneWidget);
      expect(find.text('Veuillez choisir un genre'), findsOneWidget);

      // Téléphone trop court (77 123)
      await tester.enterText(find.widgetWithText(TextFormField, 'Nom Complet'), 'Fatou Faye');
      await tester.enterText(find.widgetWithText(TextFormField, 'Téléphone'), '77 123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Adresse'), 'Medina');
      await tester.tap(find.text('Femme'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enregistrer le Client'));
      await tester.pumpAndSettle();
      expect(find.text('Numéro de téléphone invalide'), findsOneWidget);

      // Test UNICITÉ DU NUMÉRO DE TÉLÉPHONE (c1 a déjà 771234567)
      await tester.enterText(find.widgetWithText(TextFormField, 'Téléphone'), '771234567');
      await tester.tap(find.text('Enregistrer le Client'));
      await tester.pumpAndSettle();
      expect(find.text('Ce numéro de téléphone est déjà associé à un autre client'), findsOneWidget);

      // Test des mesures invalides (négatif ou texte)
      await tester.enterText(find.widgetWithText(TextFormField, 'Poitrine'), '-10');
      await tester.enterText(find.widgetWithText(TextFormField, 'Épaule'), 'abc');
      await tester.tap(find.text('Enregistrer le Client'));
      await tester.pumpAndSettle();

      expect(find.text('Mesure invalide'), findsNWidgets(2));

      // Mesures valides
      await tester.enterText(find.widgetWithText(TextFormField, 'Téléphone'), '779876543');
      await tester.enterText(find.widgetWithText(TextFormField, 'Poitrine'), '95');
      await tester.enterText(find.widgetWithText(TextFormField, 'Épaule'), '42');
      await tester.tap(find.text('Enregistrer le Client'));
      await tester.pumpAndSettle();

      expect(find.text('Mesure invalide'), findsNothing);
      expect(find.text('Ce numéro de téléphone est déjà associé à un autre client'), findsNothing);
    });
  });

  group('4. Commande (AddCommandeScreen) - Contrôles de Saisie', () {
    testWidgets('Validation modèle, tissu, montant et acompte', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: AddCommandeScreen(clientId: 'c1', clientNom: 'Awa Ndiaye'),
      ));

      // Soumission vide
      await tester.tap(find.text('Enregistrer la Commande'));
      await tester.pumpAndSettle();

      expect(find.text('Le modèle est requis'), findsOneWidget);
      expect(find.text('Le tissu est requis'), findsOneWidget);
      expect(find.text('La date doit être dans le futur'), findsOneWidget);
      expect(find.text('Montant invalide'), findsOneWidget);

      // Montant total = 0 ou négatif
      await tester.enterText(find.widgetWithText(TextFormField, 'Modèle'), 'Robe');
      await tester.enterText(find.widgetWithText(TextFormField, 'Tissu'), 'Soie');
      await tester.enterText(find.widgetWithText(TextFormField, 'Montant Total'), '0');
      await tester.tap(find.text('Enregistrer la Commande'));
      await tester.pumpAndSettle();
      expect(find.text('Montant invalide'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextFormField, 'Montant Total'), '-5000');
      await tester.tap(find.text('Enregistrer la Commande'));
      await tester.pumpAndSettle();
      expect(find.text('Montant invalide'), findsOneWidget);

      // Acompte supérieur au montant total
      await tester.enterText(find.widgetWithText(TextFormField, 'Montant Total'), '30000');
      await tester.enterText(find.widgetWithText(TextFormField, 'Acompte'), '50000');
      await tester.tap(find.text('Enregistrer la Commande'));
      await tester.pumpAndSettle();
      expect(find.text("L'acompte ne peut pas dépasser le montant total"), findsOneWidget);
    });
  });

  group('5. Client Login - Contrôles Téléphone', () {
    testWidgets('Numéro invalide et client inexistant', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ClientLoginScreen()));

      // Vide
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();
      expect(find.text('Numéro de téléphone invalide'), findsOneWidget);

      // Lettres
      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();
      expect(find.text('Numéro de téléphone invalide'), findsOneWidget);

      // Inexistant
      await tester.enterText(find.byType(TextFormField), '779999999');
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();
      expect(find.text('Aucun compte trouvé. Demandez à votre tailleur de créer votre fiche.'), findsOneWidget);
    });
  });
}
