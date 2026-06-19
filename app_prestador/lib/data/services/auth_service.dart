import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario_model.dart';

class AuthService {
  static const _base = 'http://10.0.2.2:3000';

  Future<Usuario> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$_base/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Usuario.fromJson(data['usuario']);
    }

    final erro = jsonDecode(response.body)['erro'] ?? 'Erro ao fazer login';
    throw Exception(erro);
  }
}
