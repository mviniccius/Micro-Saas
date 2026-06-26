import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/pedido_model.dart';
import '../../data/services/pedido_service.dart';
import 'pedido_detalhe_screen.dart';

enum _FiltroPedido { todos, pendentes, entregues }

// Aba "Pedidos" — lista com filtro de status e busca por cliente
class PedidosTab extends StatefulWidget {
  const PedidosTab({super.key});

  @override
  State<PedidosTab> createState() => _PedidosTabState();
}

class _PedidosTabState extends State<PedidosTab> {
  final _pedidoService = PedidoService();
  List<PedidoPrestador> _pedidos = [];
  bool _carregando = true;
  Timer? _timer;

  final _clienteController = TextEditingController();
  String _busca = '';
  _FiltroPedido _filtro = _FiltroPedido.todos;
  bool _gerandoLista = false;

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
    _clienteController.dispose();
    super.dispose();
  }

  void _limparBusca() {
    _clienteController.clear();
    setState(() => _busca = '');
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

  Future<void> _gerarListaProducao() async {
    setState(() => _gerandoLista = true);
    try {
      final lista = await _pedidoService.gerarListaProducao();
      await _buscarPedidos(); // os P viraram A
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => _ListaProducaoDialog(lista: lista),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _gerandoLista = false);
    }
  }

  // Aplica filtro de status + busca por nome do cliente
  List<PedidoPrestador> get _pedidosFiltrados {
    return _pedidos.where((p) {
      final s = p.status.trim();
      final passaFiltro = switch (_filtro) {
        _FiltroPedido.todos => true,
        _FiltroPedido.pendentes => s != 'C' && s != 'X',
        _FiltroPedido.entregues => s == 'C',
      };
      final passaBusca = p.nomeCliente.toLowerCase().contains(_busca);
      return passaFiltro && passaBusca;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _pedidosFiltrados;
    // Nomes únicos dos clientes que têm pedidos, para o autocomplete
    final nomesClientes = _pedidos.map((p) => p.nomeCliente).toSet().toList()
      ..sort();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              DropdownMenu<String>(
                controller: _clienteController,
                expandedInsets: EdgeInsets.zero,
                enableFilter: true,
                requestFocusOnTap: true,
                leadingIcon: const Icon(Icons.search),
                hintText: 'Filtrar por cliente',
                trailingIcon: _busca.isEmpty
                    ? null // mostra a setinha padrão
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _limparBusca,
                      ),
                onSelected: (v) => setState(() => _busca = (v ?? '').toLowerCase()),
                dropdownMenuEntries: [
                  for (final nome in nomesClientes)
                    DropdownMenuEntry(value: nome, label: nome),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<_FiltroPedido>(
                  segments: const [
                    ButtonSegment(value: _FiltroPedido.todos, label: Text('Todos')),
                    ButtonSegment(
                        value: _FiltroPedido.pendentes, label: Text('Pendentes')),
                    ButtonSegment(
                        value: _FiltroPedido.entregues, label: Text('Entregues')),
                  ],
                  selected: {_filtro},
                  onSelectionChanged: (s) => setState(() => _filtro = s.first),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _gerandoLista ? null : _gerarListaProducao,
                  icon: _gerandoLista
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.factory_outlined),
                  label: const Text('Gerar Lista de Produção'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _carregando
              ? const Center(child: CircularProgressIndicator())
              : filtrados.isEmpty
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
                        itemCount: filtrados.length,
                        separatorBuilder: (context, i) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _PedidoCard(
                            pedido: filtrados[index],
                            onAtualizarStatus: _atualizarStatus,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PedidoDetalheScreen(pedido: filtrados[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
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

// Diálogo com o resultado da Lista de Produção (totais por produto)
class _ListaProducaoDialog extends StatelessWidget {
  final ListaProducao lista;
  const _ListaProducaoDialog({required this.lista});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Lista de Produção'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${lista.totalPedidos} pedido(s) movido(s) para produção',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const Divider(height: 20),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: lista.itens.length,
                separatorBuilder: (_, __) => const Divider(height: 12),
                itemBuilder: (context, index) {
                  final item = lista.itens[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(item.nomeProduto,
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      Text('${item.quantidade}',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: cs.primary)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
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
