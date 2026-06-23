class ItemPedido {
  final int idProduto;
  final String? nomeProduto;
  final int quantidade;
  final double precoUnitario;
  final double valorTotalItem;

  ItemPedido({
    required this.idProduto,
    this.nomeProduto,
    required this.quantidade,
    required this.precoUnitario,
    required this.valorTotalItem,
  });

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    return ItemPedido(
      idProduto: json['id_produto'],
      nomeProduto: json['nome_produto'],
      quantidade: json['quantidade'],
      precoUnitario: double.parse((json['preco_unitario'] ?? 0).toString()),
      valorTotalItem: double.parse((json['valor_total_item'] ?? 0).toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_produto': idProduto,
      'quantidade': quantidade,
    };
  }
}

class Pedido {
  final int idPedido;
  final int idCliente;
  final double valorTotal;
  final String status;
  final List<ItemPedido> itens;

  Pedido({
    required this.idPedido,
    required this.idCliente,
    required this.valorTotal,
    required this.status,
    required this.itens,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      idPedido: json['id_pedido'],
      idCliente: json['id_cliente'] ?? 0,
      valorTotal: double.parse((json['valor_total'] ?? json['total'] ?? 0).toString()),
      status: json['status'] ?? 'P',
      itens: (json['itens'] as List<dynamic>? ?? [])
          .map((item) => ItemPedido.fromJson(item))
          .toList(),
    );
  }
}
