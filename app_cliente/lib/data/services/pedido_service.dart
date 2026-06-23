import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pedido_model.dart';

class PedidoService {
  final String _baseUrl = 'http://localhost:3000';

  Future<List<Pedido>> listarPedidos() async {
    final response = await http.get(Uri.parse('$_baseUrl/pedidos'));

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((item) => Pedido.fromJson(item)).toList();
    }

    throw Exception('Erro ao buscar pedidos: ${response.statusCode}');
  }

  Future<List<Pedido>> buscarPedidosPorTelefone(String telefone) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/pedidos/telefone/$telefone'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((item) => Pedido.fromJson(item)).toList();
    }

    throw Exception('Erro ao buscar pedidos: ${response.statusCode}');
  }

  Future<void> criarPedido({
    required int idCliente,
    required List<Map<String, dynamic>> itens,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/pedidos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_cliente': idCliente,
        'itens': itens,
      }),
    );

    if (response.statusCode == 201) return;

    throw Exception('Erro ao criar pedido: ${response.statusCode}');
  }

  Future<List<ItemPedido>> buscarItens(int idPedido) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/pedidos/$idPedido/itens'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((item) => ItemPedido.fromJson(item)).toList();
    }

    throw Exception('Erro ao buscar itens: ${response.statusCode}');
  }

  Future<void> atualizarItens(int idPedido, List<ItemPedido> itens) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/pedidos/$idPedido/itens'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'itens': itens.map((i) => {'id_produto': i.idProduto, 'quantidade': i.quantidade}).toList(),
      }),
    );

    if (response.statusCode == 200) return;

    final erro = jsonDecode(response.body)['erro'] ?? 'Erro ao atualizar itens';
    throw Exception(erro);
  }
}
