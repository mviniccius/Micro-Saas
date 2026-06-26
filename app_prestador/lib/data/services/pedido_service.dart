import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pedido_model.dart';

class PedidoService {
  static const _base = 'http://localhost:3000';

  Future<List<PedidoPrestador>> listarPedidos() async {
    final response = await http.get(Uri.parse('$_base/pedidos'));
    if (response.statusCode == 200) {
      final List<dynamic> lista = jsonDecode(response.body);
      return lista.map((e) => PedidoPrestador.fromJson(e)).toList();
    }
    throw Exception('Erro ao listar pedidos: ${response.statusCode}');
  }

  Future<List<ItemPedido>> listarItens(int idPedido) async {
    final response = await http.get(Uri.parse('$_base/pedidos/$idPedido/itens'));
    if (response.statusCode == 200) {
      final List<dynamic> lista = jsonDecode(response.body);
      return lista.map((e) => ItemPedido.fromJson(e)).toList();
    }
    throw Exception('Erro ao listar itens: ${response.statusCode}');
  }

  Future<void> atualizarStatus(int idPedido, String novoStatus) async {
    final response = await http.patch(
      Uri.parse('$_base/pedidos/$idPedido/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': novoStatus}),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Erro ao atualizar status: ${response.statusCode}');
    }
  }

  // Gera a lista de produção: move todos os Recebidos (P) para Em Produção (A)
  // e devolve o total a produzir por produto.
  Future<ListaProducao> gerarListaProducao() async {
    final response = await http.post(
      Uri.parse('$_base/pedidos/gerar-lista-producao'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 201) {
      return ListaProducao.fromJson(jsonDecode(response.body));
    }
    final body = jsonDecode(response.body);
    throw Exception(body['error'] ?? 'Erro ao gerar lista: ${response.statusCode}');
  }

  Future<void> atualizarItens(int idPedido, List<Map<String, dynamic>> itens) async {
    final response = await http.put(
      Uri.parse('$_base/pedidos/$idPedido/itens'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'itens': itens}),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Erro ao atualizar itens: ${response.statusCode}');
    }
  }
}
