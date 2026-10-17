import 'package:flutter/material.dart';
import 'app.dart';
export 'app.dart';
import 'data/app_state.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirestoreService.initialize();
  await FirestoreService.instance.synchroniserDonnees(
    targetClients: globalClients,
    targetCommandes: globalCommandes,
    targetTailleurs: globalTailleurs,
    targetRendezVous: globalRendezVous,
  );
  runApp(const ApplicationTailleur());
}
