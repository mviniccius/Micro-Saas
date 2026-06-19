import 'package:flutter/material.dart';
import 'theme.dart';
import 'presentation/screens/login_screen.dart';

void main() {
  runApp(const AppPrestador());
}

class AppPrestador extends StatelessWidget {
  const AppPrestador({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Painel do Prestador — Efraim',
      debugShowCheckedModeBanner: false,
      theme: efraimTheme,
      home: const LoginScreen(),
    );
  }
}
