import 'package:flutter/material.dart';
import 'presentation/screens/welcome_screen.dart';
import 'theme.dart';

void main() {
  runApp(const AppCliente());
}

class AppCliente extends StatelessWidget {
  const AppCliente({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panificadora Efraim',
      debugShowCheckedModeBanner: false,
      theme: efraimTheme,
      home: const WelcomeScreen(),
    );
  }
}
