import 'package:flutter_test/flutter_test.dart';
import 'package:couture/main.dart';

void main() {
  testWidgets('DigitSagnse smoke test - RoleSelectionScreen affiché', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ApplicationTailleur());

    // Vérifier que l'écran de sélection de rôle est bien affiché
    expect(find.text('Bienvenue !'), findsOneWidget);
    expect(find.text('Espace Tailleur'), findsOneWidget);
    expect(find.text('Espace Client'), findsOneWidget);
  });
}
