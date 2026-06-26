import 'package:flutter/material.dart';
import '../../data/models/usuario_model.dart';
import 'home_screen.dart';
import 'pedidos_screen.dart';
import 'financeiro_clientes_screen.dart';
import 'login_screen.dart';

// Casca principal com menu inferior: Início / Pedidos / Financeiro
class MainShell extends StatefulWidget {
  final Usuario usuario;

  const MainShell({super.key, required this.usuario});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  late final List<Widget> _abas = [
    InicioTab(usuario: widget.usuario),
    const PedidosTab(),
    const FinanceiroTab(),
  ];

  static const _titulos = ['Painel do Prestador', 'Pedidos', 'Financeiro'];

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _abas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Financeiro',
          ),
        ],
      ),
    );
  }
}
