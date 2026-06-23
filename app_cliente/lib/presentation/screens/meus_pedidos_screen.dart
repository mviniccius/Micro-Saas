import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/cliente_model.dart';
import '../../data/models/pedido_model.dart';
import '../../data/services/pedido_service.dart';
import 'pedido_detalhe_screen.dart';

class MeusPedidosScreen extends StatefulWidget {
  final Cliente cliente;

  const MeusPedidosScreen({super.key, required this.cliente});

  @override
  State<MeusPedidosScreen> createState() => _MeusPedidosScreenState();
}

class _MeusPedidosScreenState extends State<MeusPedidosScreen> {
  final _pedidoService = PedidoService();
  List<Pedido> _pedidos = [];
  bool _carregando = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _buscarPedidos();
    // Polling a cada 10 segundos — atualização assíncrona de estado
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _buscarPedidos(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _buscarPedidos() async {
    try {
      final pedidos = await _pedidoService.buscarPedidosPorTelefone(
        widget.cliente.telefone,
      );
      if (mounted) {
        setState(() {
          _pedidos = pedidos;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: () {
              setState(() => _carregando = true);
              _buscarPedidos();
            },
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _pedidos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Nenhum pedido encontrado',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _buscarPedidos,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pedidos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final pedido = _pedidos[index];
                      return _PedidoCard(
                        pedido: pedido,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PedidoDetalheScreen(pedido: pedido),
                            ),
                          );
                          _buscarPedidos();
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback? onTap;

  const _PedidoCard({required this.pedido, this.onTap});

  static const _statusInfo = {
    'P': (label: 'Pendente',     color: Colors.orange),
    'A': (label: 'Em Produção',  color: Colors.blue),
    'C': (label: 'Concluído',    color: Colors.green),
    'X': (label: 'Cancelado',    color: Colors.red),
  };

  @override
  Widget build(BuildContext context) {
    final info = _statusInfo[pedido.status.trim()] ??
        (label: 'Desconhecido', color: Colors.grey);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #${pedido.idPedido}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                _StatusBadge(label: info.label, color: info.color),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(color: Colors.grey)),
                Text(
                  'R\$ ${double.parse(pedido.valorTotal.toString()).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
