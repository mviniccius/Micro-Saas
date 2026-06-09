class Usuario {
  final int idUsuario;
  final String nome;
  final String email;
  final String perfil;

  const Usuario({
    required this.idUsuario,
    required this.nome,
    required this.email,
    required this.perfil,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        idUsuario: json['id_usuario'],
        nome: json['nome'],
        email: json['email'],
        perfil: json['perfil'],
      );
}
