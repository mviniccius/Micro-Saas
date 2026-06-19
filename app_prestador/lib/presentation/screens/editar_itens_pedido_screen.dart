import 'package:flutter/material.dart';
import '../../data/models/pedido_model.dart';
import '../../data/models/produto_model.dart';
import '../../data/services/pedido_service.dart';
import '../../data/services/produto_service.dart';

class EditarItensPedidoScreen extends StatefulWidget {
  final PedidoPrestador pedido;
  final List<ItemPedido> itens;
  const EditarItensPedidoScreen({super.key, required this.pedido, required this.itens});
  @override
  State<EditarItensPedidoScreen> createState() => _EditarItensPedidoScreenState();
}

class _EditarItensPedidoScreenState extends State<EditarItensPedidoScreen> {
  final _pedidoService = PedidoService();
  final _produtoService = ProdutoService();

  // working copy: {id_produto: int, quantidade: int, nome: string}
  late List<Map<String, dynamic>> _itens;
  List<Produto> _produtos = [];
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _itens = widget.itens.map((i) => {
      'id_produto': i.idProduto,
      'quantidade': i.quantidade,
      'nome': i.nomeProduto,
      'preco': i.precoUnitario,
    }).toList();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    try {
      final produtos = await _produtoService.listarProdutos();
      if (mounted) setState(() { _produtos = produtos; _carregando = false; });
    } catch (_) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _incrementar(int index) => setState(() => _itens[index]['quantidade']++);

  void _decrementar(int index) {
    if (_itens[index]['quantidade'] <= 1) return;
    setState(() => _itens[index]['quantidade']--);
  }

  void _remover(int index) {
    if (_itens.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O pedido deve ter pelo menos 1 item. Para cancelar, use "Cancelar Pedido".'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _itens.removeAt(index));
  }

  void _adicionarProduto(Produto produto) {
    final existe = _itens.indexWhere((i) => i['id_produto'] == produto.idProduto);
    if (existe >= 0) {
      setState(() => _itens[existe]['quantidade']++);
    } else {
      setState(() => _itens.add({'id_produto': produto.idProduto, 'quantidade': 1, 'nome': produto.nomeProduto, 'preco': produto.preco}));
    }
  }

  Future<void> _salvar() async {
    setState(() => _salvando = true);
    try {
      final payload = _itens.map((i) => {'id_produto': i['id_produto'], 'quantidade': i['quantidade']}).toList();
      await _pedidoService.atualizarItens(widget.pedido.idPedido, payload.cast<Map<String, dynamic>>());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Itens atualizados com sucesso'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Itens -- #${widget.pedido.idPedido}')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // -- Itens atuais --
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text('Itens do Pedido', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ..._itens.asMap().entries.map((entry) {
                        final i = entry.key;
                        final item = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['nome'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text('R\$ ${(item['preco'] as double).toStringAsFixed(2)} / un', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => _decrementar(i), iconSize: 20),
                                    SizedBox(
                                      width: 32,
                                      child: Text('${item['quantidade']}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _incrementar(i), iconSize: 20),
                                    IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _remover(i), iconSize: 20),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      // -- Adicionar produto --
                      Text('Adicionar Produto', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      if (_produtos.isEmpty)
                        const Text('Nenhum produto disponivel', style: TextStyle(color: Colors.grey))
                      else
                        ..._produtos.map((produto) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(produto.nomeProduto),
                          subtitle: Text('R\$ ${produto.preco.toStringAsFixed(2)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: () => _adicionarProduto(produto),
                          ),
                        )),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _salvando ? null : _salvar,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: _salvando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_outlined),
        label: const Text('Salvar Alteracoes'),
      ),
    );
  }
}
