import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/role_selection_screen.dart';

class ApplicationTailleur extends StatelessWidget {
  const ApplicationTailleur({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DigitSagnse',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const RoleSelectionScreen(),
    );
  }
}
