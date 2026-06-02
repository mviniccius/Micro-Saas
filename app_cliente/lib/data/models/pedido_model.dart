class ItemPedido {
  final int idProduto;
  final int quantidade;
  final double precoUnitario;
  final double valorTotalItem;

  ItemPedido({
    required this.idProduto,
    required this.quantidade,
    required this.precoUnitario,
    required this.valorTotalItem,
  });

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    return ItemPedido(
      idProduto: json['id_produto'],
      quantidade: json['quantidade'],
      precoUnitario: double.parse(json['preco_unitario'].toString()),
      valorTotalItem: double.parse(json['valor_total_item'].toString()),
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
      idCliente: json['id_cliente'],
      valorTotal: double.parse(json['valor_total'].toString()),
      status: json['status'],
      itens: (json['itens'] as List<dynamic>? ?? [])
          .map((item) => ItemPedido.fromJson(item))
          .toList(),
    );
  }
}
