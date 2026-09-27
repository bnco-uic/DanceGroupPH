import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SayawPilipinasApp());
}

class SayawPilipinasApp extends StatelessWidget {
  const SayawPilipinasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sayaw Pilipinas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const DashboardScreen(),
    );
  }
}
