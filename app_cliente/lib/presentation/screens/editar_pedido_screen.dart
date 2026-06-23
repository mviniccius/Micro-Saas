import 'package:flutter/material.dart';
import '../../data/models/pedido_model.dart';
import '../../data/models/produto_model.dart';
import '../../data/services/pedido_service.dart';
import '../../data/services/produto_service.dart';

class EditarPedidoScreen extends StatefulWidget {
  final Pedido pedido;

  const EditarPedidoScreen({super.key, required this.pedido});

  @override
  State<EditarPedidoScreen> createState() => _EditarPedidoScreenState();
}

class _EditarPedidoScreenState extends State<EditarPedidoScreen> {
  final _pedidoService = PedidoService();
  final _produtoService = ProdutoService();
  List<ItemPedido> _itens = [];
  List<Produto> _catalogo = [];
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Busca itens do pedido e catálogo em paralelo
      final resultados = await Future.wait([
        _pedidoService.buscarItens(widget.pedido.idPedido),
        _produtoService.listarProdutos(),
      ]);
      if (mounted) {
        setState(() {
          _itens = resultados[0] as List<ItemPedido>;
          _catalogo = resultados[1] as List<Produto>;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  // Abre um seletor com os produtos do catálogo que ainda não estão no pedido
  Future<void> _adicionarProduto() async {
    final idsNoPedido = _itens.map((i) => i.idProduto).toSet();
    final disponiveis = _catalogo
        .where((p) => !idsNoPedido.contains(p.idProduto))
        .toList();

    if (disponiveis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos os produtos já estão no pedido.')),
      );
      return;
    }

    final escolhido = await showModalBottomSheet<Produto>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Adicionar produto',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          for (final p in disponiveis)
            ListTile(
              title: Text(p.nomeProduto),
              subtitle: Text('R\$ ${p.preco.toStringAsFixed(2)} un.'),
              trailing: const Icon(Icons.add_circle_outline),
              onTap: () => Navigator.pop(context, p),
            ),
        ],
      ),
    );

    if (escolhido == null) return;
    setState(() {
      _itens.add(ItemPedido(
        idProduto: escolhido.idProduto,
        nomeProduto: escolhido.nomeProduto,
        quantidade: 1,
        precoUnitario: escolhido.preco,
        valorTotalItem: escolhido.preco,
      ));
    });
  }

  void _alterarQuantidade(int index, int delta) {
    final novaQtd = _itens[index].quantidade + delta;
    if (novaQtd < 1) return;
    setState(() {
      _itens[index] = ItemPedido(
        idProduto: _itens[index].idProduto,
        nomeProduto: _itens[index].nomeProduto,
        quantidade: novaQtd,
        precoUnitario: _itens[index].precoUnitario,
        valorTotalItem: _itens[index].precoUnitario * novaQtd,
      );
    });
  }

  void _removerItem(int index) {
    if (_itens.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O pedido deve ter pelo menos 1 item.')),
      );
      return;
    }
    setState(() => _itens.removeAt(index));
  }

  double get _total => _itens.fold(0, (sum, i) => sum + i.valorTotalItem);

  Future<void> _salvar() async {
    setState(() => _salvando = true);
    try {
      await _pedidoService.atualizarItens(widget.pedido.idPedido, _itens);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido atualizado com sucesso!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Pedido #${widget.pedido.idPedido}'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _itens.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _itens[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        title: Text(
                          item.nomeProduto ?? 'Produto #${item.idProduto}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'R\$ ${item.precoUnitario.toStringAsFixed(2)} un.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _alterarQuantidade(index, -1),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(
                              width: 32,
                              child: Text(
                                '${item.quantidade}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => _alterarQuantidade(index, 1),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _removerItem(index),
                              color: Colors.red[400],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                        top: BorderSide(color: Colors.grey.withOpacity(0.2))),
                  ),
                  child: Column(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _adicionarProduto,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar produto'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total atualizado',
                              style: TextStyle(color: Colors.grey)),
                          Text(
                            'R\$ ${_total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _salvando ? null : _salvar,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: _salvando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Salvar alterações'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
