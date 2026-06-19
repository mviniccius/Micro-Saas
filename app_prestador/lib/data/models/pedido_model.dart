class PedidoPrestador {
  final int idPedido;
  final int idCliente;
  final String nomeCliente;
  final double valorTotal;
  final String status;

  const PedidoPrestador({
    required this.idPedido,
    required this.idCliente,
    required this.nomeCliente,
    required this.valorTotal,
    required this.status,
  });

  factory PedidoPrestador.fromJson(Map<String, dynamic> json) =>
      PedidoPrestador(
        idPedido: json['id_pedido'],
        idCliente: json['id_cliente'] ?? 0,
        nomeCliente: json['cliente'] ?? json['nome_cliente'] ?? 'Cliente',
        valorTotal: double.parse(
            (json['valor_total'] ?? json['total'] ?? 0).toString()),
        status: json['status'] ?? 'P',
      );
}

class ItemPedido {
  final int idItensPedido;
  final int idProduto;
  final String nomeProduto;
  final int quantidade;
  final double precoUnitario;
  final double valorTotalItem;

  const ItemPedido({
    required this.idItensPedido,
    required this.idProduto,
    required this.nomeProduto,
    required this.quantidade,
    required this.precoUnitario,
    required this.valorTotalItem,
  });

  factory ItemPedido.fromJson(Map<String, dynamic> json) => ItemPedido(
    idItensPedido: json['id_itens_pedido'] ?? 0,
    idProduto: json['id_produto'] ?? 0,
    nomeProduto: json['nome_produto'] ?? '',
    quantidade: json['quantidade'] ?? 0,
    precoUnitario: double.parse((json['preco_unitario'] ?? 0).toString()),
    valorTotalItem: double.parse((json['valor_total_item'] ?? 0).toString()),
  );

  Map<String, dynamic> toJson() => {
    'id_produto': idProduto,
    'quantidade': quantidade,
  };
}
