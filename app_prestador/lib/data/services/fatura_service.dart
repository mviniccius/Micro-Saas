import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fatura_model.dart';

class FaturaService {
  static const _base = 'http://localhost:3000';

  Future<ResumoFinanceiro> buscarResumo(int idCliente) async {
    final response =
        await http.get(Uri.parse('$_base/faturas/cliente/$idCliente'));

    if (response.statusCode == 200) {
      return ResumoFinanceiro.fromJson(jsonDecode(response.body));
    }
    throw Exception(_erro(response));
  }

  // Agrupa os pedidos entregues não faturados do cliente numa nova fatura
  Future<void> fecharFatura(int idCliente) async {
    final response = await http.post(
      Uri.parse('$_base/faturas/fechar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_cliente': idCliente}),
    );
    if (response.statusCode != 201) throw Exception(_erro(response));
  }

  // Registra um pagamento (PIX ou DINHEIRO) numa fatura
  Future<void> registrarPagamento(
      int idFatura, double valor, String formaPagamento) async {
    final response = await http.post(
      Uri.parse('$_base/faturas/$idFatura/pagamento'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'valor': valor, 'forma_pagamento': formaPagamento}),
    );
    if (response.statusCode != 201) throw Exception(_erro(response));
  }

  // O backend devolve a mensagem em 'error' ou 'message'
  String _erro(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['error'] ?? body['message'] ?? 'Erro ${response.statusCode}';
    } catch (_) {
      return 'Erro ${response.statusCode}';
    }
  }
}
