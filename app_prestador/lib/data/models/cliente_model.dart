class Cliente {
  final int idCliente;
  final String nome;
  final String? telefone;
  final String cicloFaturamento; // DIARIO, SEMANAL, MENSAL

  const Cliente({
    required this.idCliente,
    required this.nome,
    this.telefone,
    required this.cicloFaturamento,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
        idCliente: json['id_cliente'],
        nome: json['nome'] ?? '',
        telefone: json['telefone'],
        cicloFaturamento: json['ciclo_faturamento'] ?? 'MENSAL',
      );
}
