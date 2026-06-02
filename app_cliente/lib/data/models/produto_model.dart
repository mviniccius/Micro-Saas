class Produto {
  final int idProduto;
  final String nomeProduto;
  final double preco;

  Produto({
    required this.idProduto,
    required this.nomeProduto,
    required this.preco,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      idProduto: json['id_produto'],
      nomeProduto: json['nome_produto'],
      preco: double.parse(json['preco'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_produto': idProduto,
      'nome_produto': nomeProduto,
      'preco': preco,
    };
  }
}
