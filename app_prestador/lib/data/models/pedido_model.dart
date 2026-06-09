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
