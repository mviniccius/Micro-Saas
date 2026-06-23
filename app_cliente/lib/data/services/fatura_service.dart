import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fatura_model.dart';

class FaturaService {
  final String _baseUrl = 'http://localhost:3000';

  Future<ResumoFinanceiro> buscarResumo(int idCliente) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/faturas/cliente/$idCliente'),
    );

    if (response.statusCode == 200) {
      return ResumoFinanceiro.fromJson(jsonDecode(response.body));
    }

    throw Exception('Erro ao buscar faturas: ${response.statusCode}');
  }
}
