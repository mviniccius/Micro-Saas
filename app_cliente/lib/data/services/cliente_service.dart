import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cliente_model.dart';

class ClienteService {
  final String _baseUrl = 'http://10.0.2.2:3000';

  Future<Cliente?> buscarPorTelefone(String telefone) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/clientes/telefone/$telefone'),
    );

    if (response.statusCode == 200) {
      return Cliente.fromJson(jsonDecode(response.body));
    }

    if (response.statusCode == 404) return null;

    throw Exception('Erro ao buscar cliente: ${response.statusCode}');
  }

  Future<Cliente> criarCliente(String nome, String telefone) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/clientes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nome': nome, 'telefone': telefone}),
    );

    if (response.statusCode == 201) {
      return Cliente.fromJson(jsonDecode(response.body));
    }

    throw Exception('Erro ao criar cliente: ${response.statusCode}');
  }
}
