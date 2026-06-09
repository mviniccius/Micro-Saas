class Cliente {
  final int idCliente;
  final String nome;
  final String telefone;
  final bool active;

  Cliente({
    required this.idCliente,
    required this.nome,
    required this.telefone,
    required this.active,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: json['id_cliente'],
      nome: json['nome'],
      telefone: json['telefone'],
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'telefone': telefone,
    };
  }
}
