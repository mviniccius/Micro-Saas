import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cliente_model.dart';

class ClienteService {
  static const _base = 'http://localhost:3000';

  Future<List<Cliente>> listarClientes() async {
    final response = await http.get(Uri.parse('$_base/clientes'));

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => Cliente.fromJson(e)).toList();
    }

    throw Exception('Erro ao buscar clientes: ${response.statusCode}');
  }
}
