import 'package:flutter/material.dart';
import 'presentation/screens/login_screen.dart';

void main() {
  runApp(const AppPrestador());
}

class AppPrestador extends StatelessWidget {
  const AppPrestador({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Painel do Prestador',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
