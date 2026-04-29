import 'package:flutter/material.dart';
import 'screens/fitness_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

/// Aplicación principal de seguimiento de actividad física
/// Utiliza StreamControllers de Dart para actualizar datos en tiempo real
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitStream - Seguimiento Fitness',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00E676),
          secondary: const Color(0xFF00BCD4),
          surface: const Color(0xFF1A1A2E),
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F23),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const FitnessDashboardScreen(),
    );
  }
}
