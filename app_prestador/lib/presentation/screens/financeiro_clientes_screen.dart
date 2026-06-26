import 'package:flutter/material.dart';
import '../../data/models/cliente_model.dart';
import '../../data/services/cliente_service.dart';
import 'cliente_faturas_screen.dart';

// Aba "Financeiro" — lista de clientes com busca → entra nas faturas de cada um
class FinanceiroTab extends StatefulWidget {
  const FinanceiroTab({super.key});

  @override
  State<FinanceiroTab> createState() => _FinanceiroTabState();
}

class _FinanceiroTabState extends State<FinanceiroTab> {
  final _clienteService = ClienteService();
  late Future<List<Cliente>> _future;
  String _busca = '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    _future = _clienteService.listarClientes();
  }

  Future<void> _recarregar() async {
    setState(_carregar);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar cliente...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _busca = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Cliente>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }
                final clientes = snapshot.data!
                    .where((c) => c.nome.toLowerCase().contains(_busca))
                    .toList();

                if (clientes.isEmpty) {
                  return const Center(
                    child: Text('Nenhum cliente encontrado',
                        style: TextStyle(color: Colors.grey)),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _recarregar,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: clientes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final c = clientes[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.1),
                            child: Text(
                              c.nome.isNotEmpty ? c.nome[0].toUpperCase() : '?',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(c.nome,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Ciclo: ${c.cicloFaturamento}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClienteFaturasScreen(cliente: c),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
    );
  }
}
