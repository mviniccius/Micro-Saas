import 'package:flutter/material.dart';
import '../../data/models/pedido_model.dart';
import '../../data/models/usuario_model.dart';
import '../../data/services/pedido_service.dart';

// Aba "Início" — saudação + resumo do dia (contadores reais de pedidos)
class InicioTab extends StatefulWidget {
  final Usuario usuario;

  const InicioTab({super.key, required this.usuario});

  @override
  State<InicioTab> createState() => _InicioTabState();
}

class _InicioTabState extends State<InicioTab> {
  final _pedidoService = PedidoService();
  late Future<List<PedidoPrestador>> _future;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    _future = _pedidoService.listarPedidos();
  }

  Future<void> _recarregar() async {
    setState(_carregar);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _recarregar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Saudacao(usuario: widget.usuario),
          const SizedBox(height: 24),
          Text('Resumo de hoje', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          _ResumoPedidos(future: _future),
        ],
      ),
    );
  }
}

class _Saudacao extends StatelessWidget {
  final Usuario usuario;
  const _Saudacao({required this.usuario});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: cs.primary,
          child: Text(
            usuario.nome.isNotEmpty ? usuario.nome[0].toUpperCase() : '?',
            style: TextStyle(
                color: cs.secondary, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Olá, ${usuario.nome}',
                  style: Theme.of(context).textTheme.headlineSmall),
              Text(usuario.perfil,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResumoPedidos extends StatelessWidget {
  final Future<List<PedidoPrestador>> future;
  const _ResumoPedidos({required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PedidoPrestador>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 90,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Não foi possível carregar os pedidos.',
                  style: TextStyle(color: Colors.grey)),
            ),
          );
        }
        final pedidos = snapshot.data ?? [];
        int conta(List<String> status) =>
            pedidos.where((p) => status.contains(p.status.trim())).length;

        final tiles = [
          (rotulo: 'Novos', qtd: conta(['P']), cor: const Color(0xFFE65100)),
          (rotulo: 'Em produção', qtd: conta(['A', 'S']), cor: const Color(0xFF1565C0)),
          (rotulo: 'Em entrega', qtd: conta(['E']), cor: const Color(0xFF00695C)),
          (rotulo: 'Entregues', qtd: conta(['C']), cor: const Color(0xFF2E7D32)),
        ];

        return Row(
          children: [
            for (final t in tiles) ...[
              Expanded(
                child: _StatTile(rotulo: t.rotulo, qtd: t.qtd, cor: t.cor),
              ),
              if (t != tiles.last) const SizedBox(width: 8),
            ],
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String rotulo;
  final int qtd;
  final Color cor;
  const _StatTile({required this.rotulo, required this.qtd, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text('$qtd',
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold, color: cor)),
            const SizedBox(height: 4),
            Text(rotulo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
