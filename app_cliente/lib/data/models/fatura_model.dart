class Pagamento {
  final int idPagamento;
  final int idFatura;
  final double valor;
  final String formaPagamento; // PIX, DINHEIRO, CREDITO
  final DateTime? dataPagamento;

  Pagamento({
    required this.idPagamento,
    required this.idFatura,
    required this.valor,
    required this.formaPagamento,
    this.dataPagamento,
  });

  factory Pagamento.fromJson(Map<String, dynamic> json) {
    return Pagamento(
      idPagamento: json['id_pagamento'],
      idFatura: json['id_fatura'] ?? 0,
      valor: double.parse((json['valor'] ?? 0).toString()),
      formaPagamento: json['forma_pagamento'] ?? '',
      dataPagamento: json['data_pagamento'] != null
          ? DateTime.tryParse(json['data_pagamento'].toString())
          : null,
    );
  }
}

class Fatura {
  final int idFatura;
  final DateTime? periodoInicio;
  final DateTime? periodoFim;
  final double valorTotal;
  final double valorPago;
  final double saldoDevedor;
  final String status; // ABERTA, PARCIALMENTE_PAGA, PAGA, VENCIDA
  final List<Pagamento> pagamentos;

  Fatura({
    required this.idFatura,
    required this.periodoInicio,
    required this.periodoFim,
    required this.valorTotal,
    required this.valorPago,
    required this.saldoDevedor,
    required this.status,
    required this.pagamentos,
  });

  bool get emAberto => status != 'PAGA';

  factory Fatura.fromJson(Map<String, dynamic> json) {
    return Fatura(
      idFatura: json['id_fatura'],
      periodoInicio: json['periodo_inicio'] != null
          ? DateTime.tryParse(json['periodo_inicio'].toString())
          : null,
      periodoFim: json['periodo_fim'] != null
          ? DateTime.tryParse(json['periodo_fim'].toString())
          : null,
      valorTotal: double.parse((json['valor_total'] ?? 0).toString()),
      valorPago: double.parse((json['valor_pago'] ?? 0).toString()),
      saldoDevedor: double.parse((json['saldo_devedor'] ?? 0).toString()),
      status: json['status'] ?? 'ABERTA',
      pagamentos: (json['pagamentos'] as List<dynamic>? ?? [])
          .map((p) => Pagamento.fromJson(p))
          .toList(),
    );
  }
}

// Payload completo da aba Financeira do cliente
class ResumoFinanceiro {
  final int idCliente;
  final String cicloFaturamento; // DIARIO, SEMANAL, MENSAL
  final double saldoCredito;
  final double totalEmAberto;
  final List<Fatura> faturas;

  ResumoFinanceiro({
    required this.idCliente,
    required this.cicloFaturamento,
    required this.saldoCredito,
    required this.totalEmAberto,
    required this.faturas,
  });

  // Histórico = todos os pagamentos de todas as faturas, mais recentes primeiro
  List<Pagamento> get historicoPagamentos {
    final todos = faturas.expand((f) => f.pagamentos).toList();
    todos.sort((a, b) => (b.dataPagamento ?? DateTime(0))
        .compareTo(a.dataPagamento ?? DateTime(0)));
    return todos;
  }

  factory ResumoFinanceiro.fromJson(Map<String, dynamic> json) {
    return ResumoFinanceiro(
      idCliente: json['id_cliente'],
      cicloFaturamento: json['ciclo_faturamento'] ?? 'MENSAL',
      saldoCredito: double.parse((json['saldo_credito'] ?? 0).toString()),
      totalEmAberto: double.parse((json['total_em_aberto'] ?? 0).toString()),
      faturas: (json['faturas'] as List<dynamic>? ?? [])
          .map((f) => Fatura.fromJson(f))
          .toList(),
    );
  }
}
