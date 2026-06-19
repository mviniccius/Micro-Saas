import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/produto_model.dart';

class ProdutoService {
  static const _base = 'http://10.0.2.2:3000';

  Future<List<Produto>> listarProdutos() async {
    final response = await http.get(Uri.parse('$_base/produtos'));
    if (response.statusCode == 200) {
      final List<dynamic> lista = jsonDecode(response.body);
      return lista.map((e) => Produto.fromJson(e)).toList();
    }
    throw Exception('Erro ao listar produtos: ${response.statusCode}');
  }
}
