import 'package:flutter/material.dart';
import '../../data/models/cliente_model.dart';
import '../../data/models/produto_model.dart';
import '../../data/services/produto_service.dart';
import 'criar_pedido_screen.dart';
import 'meus_pedidos_screen.dart';

class HomeScreen extends StatefulWidget {
  final Cliente cliente;

  const HomeScreen({super.key, required this.cliente});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _produtoService = ProdutoService();
  late Future<List<Produto>> _produtosFuture;
  final Map<int, int> _quantidades = {};
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _produtosFuture = _produtoService.listarProdutos();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(int idProduto) {
    return _controllers.putIfAbsent(
      idProduto,
      () => TextEditingController(text: '0'),
    );
  }

  void _setQuantidade(int idProduto, int valor, {bool atualizarController = true}) {
    final qtd = valor < 0 ? 0 : valor;
    setState(() {
      if (qtd == 0) {
        _quantidades.remove(idProduto);
      } else {
        _quantidades[idProduto] = qtd;
      }
      if (atualizarController) {
        _controllerFor(idProduto).text = '$qtd';
      }
    });
  }

  int get _totalItens =>
      _quantidades.values.fold(0, (soma, qtd) => soma + qtd);

  void _irParaPedido(List<Produto> produtos) {
    final itensSelecionados = _quantidades.entries.map((e) {
      final produto = produtos.firstWhere((p) => p.idProduto == e.key);
      return {'produto': produto, 'quantidade': e.value};
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CriarPedidoScreen(
          cliente: widget.cliente,
          itens: itensSelecionados,
        ),
      ),
    ).then((_) {
      setState(() {
        _quantidades.clear();
        for (final c in _controllers.values) {
          c.text = '0';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${widget.cliente.nome}!'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Meus pedidos',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MeusPedidosScreen(cliente: widget.cliente),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Produto>>(
        future: _produtosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final produtos = snapshot.data!;

          if (produtos.isEmpty) {
            return const Center(child: Text('Nenhum produto disponível'));
          }

          return Stack(
            children: [
              ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: produtos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final produto = produtos[index];
                  return _ProdutoCard(
                    produto: produto,
                    controller: _controllerFor(produto.idProduto),
                    quantidade: _quantidades[produto.idProduto] ?? 0,
                    onAlterarQuantidade: (delta) => _setQuantidade(
                      produto.idProduto,
                      (_quantidades[produto.idProduto] ?? 0) + delta,
                    ),
                    onDigitar: (valor) => _setQuantidade(
                      produto.idProduto,
                      int.tryParse(valor) ?? 0,
                      atualizarController: false,
                    ),
                  );
                },
              ),
              if (_totalItens > 0)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.shopping_bag),
                    label: Text('Ver pedido ($_totalItens itens)'),
                    onPressed: () => _irParaPedido(produtos),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ProdutoCard extends StatelessWidget {
  final Produto produto;
  final int quantidade;
  final TextEditingController controller;
  final void Function(int delta) onAlterarQuantidade;
  final void Function(String valor) onDigitar;

  const _ProdutoCard({
    required this.produto,
    required this.quantidade,
    required this.controller,
    required this.onAlterarQuantidade,
    required this.onDigitar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produto.nomeProduto,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${produto.preco.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green, fontSize: 14),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: quantidade > 0
                      ? () => onAlterarQuantidade(-1)
                      : null,
                ),
                SizedBox(
                  width: 48,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: onDigitar,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => onAlterarQuantidade(1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
