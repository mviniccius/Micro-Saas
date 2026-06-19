class Produto {
  final int idProduto;
  final String nomeProduto;
  final double preco;

  const Produto({
    required this.idProduto,
    required this.nomeProduto,
    required this.preco,
  });

  factory Produto.fromJson(Map<String, dynamic> json) => Produto(
    idProduto: json['id_produto'] ?? 0,
    nomeProduto: json['nome_produto'] ?? '',
    preco: double.parse((json['preco'] ?? 0).toString()),
  );
}
