import 'package:flutter/material.dart';
import '../../data/models/pedido_model.dart';
import '../../data/services/pedido_service.dart';
import 'editar_itens_pedido_screen.dart';

class PedidoDetalheScreen extends StatefulWidget {
  final PedidoPrestador pedido;
  const PedidoDetalheScreen({super.key, required this.pedido});
  @override
  State<PedidoDetalheScreen> createState() => _PedidoDetalheScreenState();
}

class _PedidoDetalheScreenState extends State<PedidoDetalheScreen> {
  final _service = PedidoService();
  List<ItemPedido> _itens = [];
  bool _carregando = true;
  late PedidoPrestador _pedido;

  // Mapa de status
  static const _statusInfo = {
    'P': (label: 'Recebido',          cor: Color(0xFFE65100)),
    'A': (label: 'Em Produção',       cor: Color(0xFF1565C0)),
    'S': (label: 'Separado',          cor: Color(0xFF6A1B9A)),
    'E': (label: 'Em Entrega',        cor: Color(0xFF00695C)),
    'C': (label: 'Entregue',          cor: Color(0xFF2E7D32)),
    'X': (label: 'Cancelado',         cor: Color(0xFFC62828)),
  };

  static const _proximoStatus = {'P': 'A', 'A': 'S', 'S': 'E', 'E': 'C'};
  static const _labelAcao = {'P': 'Aceitar', 'A': 'Separar', 'S': 'Despachar', 'E': 'Confirmar Entrega'};

  @override
  void initState() {
    super.initState();
    _pedido = widget.pedido;
    _carregarItens();
  }

  Future<void> _carregarItens() async {
    try {
      final itens = await _service.listarItens(_pedido.idPedido);
      if (mounted) setState(() { _itens = itens; _carregando = false; });
    } catch (_) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _avancarStatus() async {
    final proximo = _proximoStatus[_pedido.status.trim()];
    if (proximo == null) return;
    try {
      await _service.atualizarStatus(_pedido.idPedido, proximo);
      if (!mounted) return;
      // Atualiza o pedido local com novo status
      setState(() {
        _pedido = PedidoPrestador(
          idPedido: _pedido.idPedido,
          idCliente: _pedido.idCliente,
          nomeCliente: _pedido.nomeCliente,
          valorTotal: _pedido.valorTotal,
          status: proximo,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status atualizado para ${_statusInfo[proximo]?.label ?? proximo}'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _cancelar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Pedido'),
        content: const Text('Tem certeza que deseja cancelar este pedido? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Voltar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancelar Pedido'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await _service.atualizarStatus(_pedido.idPedido, 'X');
      if (!mounted) return;
      setState(() {
        _pedido = PedidoPrestador(
          idPedido: _pedido.idPedido,
          idCliente: _pedido.idCliente,
          nomeCliente: _pedido.nomeCliente,
          valorTotal: _pedido.valorTotal,
          status: 'X',
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido cancelado'), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _pedido.status.trim();
    final info = _statusInfo[status] ?? (label: 'Desconhecido', cor: Colors.grey);
    final podeEditar = status == 'P' || status == 'A';
    final podeAvancar = _proximoStatus.containsKey(status);
    final podeCancelar = status == 'P';

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${_pedido.idPedido}'),
        actions: [
          if (podeEditar)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar Itens',
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => EditarItensPedidoScreen(pedido: _pedido, itens: _itens),
                ));
                _carregarItens();
              },
            ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // -- Header do pedido --
                Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_pedido.nomeCliente, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: info.cor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: info.cor.withValues(alpha: 0.4)),
                            ),
                            child: Text(info.label, style: TextStyle(color: info.cor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'R\$ ${_pedido.valorTotal.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // -- Lista de itens --
                Expanded(
                  child: _itens.isEmpty
                      ? const Center(child: Text('Nenhum item encontrado', style: TextStyle(color: Colors.grey)))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _itens.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final item = _itens[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.nomeProduto, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        Text('${item.quantidade} un x R\$ ${item.precoUnitario.toStringAsFixed(2)}',
                                            style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  Text('R\$ ${item.valorTotalItem.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                // -- Acoes de status --
                if (podeAvancar || podeCancelar)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          if (podeCancelar) ...[
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                                onPressed: _cancelar,
                                child: const Text('Cancelar Pedido'),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (podeAvancar)
                            Expanded(
                              child: FilledButton(
                                onPressed: _avancarStatus,
                                child: Text(_labelAcao[status] ?? 'Avancar'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
