import 'package:flutter/material.dart';
import '../../data/models/cliente_model.dart';
import '../../data/models/produto_model.dart';
import '../../data/services/pedido_service.dart';

class CriarPedidoScreen extends StatefulWidget {
  final Cliente cliente;
  final List<Map<String, dynamic>> itens;

  const CriarPedidoScreen({
    super.key,
    required this.cliente,
    required this.itens,
  });

  @override
  State<CriarPedidoScreen> createState() => _CriarPedidoScreenState();
}

class _CriarPedidoScreenState extends State<CriarPedidoScreen> {
  final _pedidoService = PedidoService();
  bool _confirmando = false;

  double get _total {
    return widget.itens.fold(0, (soma, item) {
      final produto = item['produto'] as Produto;
      final quantidade = item['quantidade'] as int;
      return soma + (produto.preco * quantidade);
    });
  }

  Future<void> _confirmarPedido() async {
    setState(() => _confirmando = true);

    try {
      final itens = widget.itens.map((item) {
        final produto = item['produto'] as Produto;
        return {
          'id_produto': produto.idProduto,
          'quantidade': item['quantidade'] as int,
        };
      }).toList();

      await _pedidoService.criarPedido(
        idCliente: widget.cliente.idCliente,
        itens: itens,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao confirmar pedido: $e')),
      );
    } finally {
      setState(() => _confirmando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo do Pedido'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: widget.itens.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = widget.itens[index];
                final produto = item['produto'] as Produto;
                final quantidade = item['quantidade'] as int;
                final subtotal = produto.preco * quantidade;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    produto.nomeProduto,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'R\$ ${produto.preco.toStringAsFixed(2)} × $quantidade',
                  ),
                  trailing: Text(
                    'R\$ ${subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'R\$ ${_total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _confirmando ? null : _confirmarPedido,
                    child: _confirmando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Confirmar Pedido',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
