import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/pedido_model.dart';
import '../../data/models/usuario_model.dart';
import '../../data/services/pedido_service.dart';
import 'login_screen.dart';
import 'pedido_detalhe_screen.dart';

class PedidosScreen extends StatefulWidget {
  final Usuario usuario;

  const PedidosScreen({super.key, required this.usuario});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  final _pedidoService = PedidoService();
  List<PedidoPrestador> _pedidos = [];
  bool _carregando = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _buscarPedidos();
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
      final lista = await _pedidoService.listarPedidos();
      if (mounted) {
        setState(() {
          _pedidos = lista;
          _carregando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _atualizarStatus(PedidoPrestador pedido, String novoStatus) async {
    try {
      await _pedidoService.atualizarStatus(pedido.idPedido, novoStatus);
      _buscarPedidos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
        title: Text('Olá, ${widget.usuario.nome}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: () {
              setState(() => _carregando = true);
              _buscarPedidos();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
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
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
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
                    separatorBuilder: (context, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _PedidoCard(
                        pedido: _pedidos[index],
                        onAtualizarStatus: _atualizarStatus,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PedidoDetalheScreen(pedido: _pedidos[index]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  final PedidoPrestador pedido;
  final Future<void> Function(PedidoPrestador, String) onAtualizarStatus;
  final VoidCallback? onTap;

  const _PedidoCard({
    required this.pedido,
    required this.onAtualizarStatus,
    this.onTap,
  });

  static const _statusInfo = {
    'P': (label: 'Recebido',     color: Color(0xFFE65100)),
    'A': (label: 'Em Produção',  color: Color(0xFF1565C0)),
    'S': (label: 'Separado',     color: Color(0xFF6A1B9A)),
    'E': (label: 'Em Entrega',   color: Color(0xFF00695C)),
    'C': (label: 'Entregue',     color: Color(0xFF2E7D32)),
    'X': (label: 'Cancelado',    color: Color(0xFFC62828)),
  };

  @override
  Widget build(BuildContext context) {
    final info = _statusInfo[pedido.status.trim()] ??
        (label: 'Desconhecido', color: const Color(0xFF9E9E9E));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
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
              const SizedBox(height: 4),
              Text(
                pedido.nomeCliente,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'R\$ ${pedido.valorTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  _AcoesStatus(
                    status: pedido.status.trim(),
                    onAvancar: () {
                      final proximo = _proximoStatus(pedido.status.trim());
                      if (proximo != null) onAtualizarStatus(pedido, proximo);
                    },
                    onCancelar: pedido.status.trim() == 'P'
                        ? () => onAtualizarStatus(pedido, 'X')
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _proximoStatus(String atual) {
    const fluxo = {'P': 'A', 'A': 'S', 'S': 'E', 'E': 'C'};
    return fluxo[atual];
  }
}

class _AcoesStatus extends StatelessWidget {
  final String status;
  final VoidCallback onAvancar;
  final VoidCallback? onCancelar;

  const _AcoesStatus({
    required this.status,
    required this.onAvancar,
    this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    if (status == 'C' || status == 'X') {
      return const SizedBox.shrink();
    }

    final labels = {'P': 'Aceitar', 'A': 'Separar', 'S': 'Despachar', 'E': 'Confirmar Entrega'};

    return Row(
      children: [
        if (onCancelar != null)
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            onPressed: onCancelar,
            child: const Text('Cancelar'),
          ),
        if (onCancelar != null) const SizedBox(width: 8),
        FilledButton(
          onPressed: onAvancar,
          child: Text(labels[status] ?? 'Avançar'),
        ),
      ],
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
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
