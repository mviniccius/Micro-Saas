import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/produto_model.dart';

class ProdutoService {
  final String _baseUrl = 'http://localhost:3000';

  Future<List<Produto>> listarProdutos() async {
    final response = await http.get(Uri.parse('$_baseUrl/produtos'));

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((item) => Produto.fromJson(item)).toList();
    }

    throw Exception('Erro ao buscar produtos: ${response.statusCode}');
  }
}
