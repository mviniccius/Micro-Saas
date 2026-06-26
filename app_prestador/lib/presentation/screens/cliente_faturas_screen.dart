import 'package:flutter/material.dart';
import '../../data/models/cliente_model.dart';
import '../../data/models/fatura_model.dart';
import '../../data/services/fatura_service.dart';

class ClienteFaturasScreen extends StatefulWidget {
  final Cliente cliente;

  const ClienteFaturasScreen({super.key, required this.cliente});

  @override
  State<ClienteFaturasScreen> createState() => _ClienteFaturasScreenState();
}

class _ClienteFaturasScreenState extends State<ClienteFaturasScreen> {
  final _faturaService = FaturaService();
  late Future<ResumoFinanceiro> _future;
  bool _processando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    _future = _faturaService.buscarResumo(widget.cliente.idCliente);
  }

  Future<void> _recarregar() async {
    setState(_carregar);
    await _future;
  }

  void _avisar(String msg, {bool erro = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: erro ? Colors.red : null,
      ),
    );
  }

  Future<void> _fecharFatura() async {
    setState(() => _processando = true);
    try {
      await _faturaService.fecharFatura(widget.cliente.idCliente);
      _avisar('Fatura fechada com sucesso!');
      await _recarregar();
    } catch (e) {
      _avisar(e.toString().replaceFirst('Exception: ', ''), erro: true);
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  Future<void> _registrarPagamento(Fatura fatura) async {
    final resultado = await showModalBottomSheet<({double valor, String forma})>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PagamentoSheet(saldoDevedor: fatura.saldoDevedor),
    );
    if (resultado == null) return;

    setState(() => _processando = true);
    try {
      await _faturaService.registrarPagamento(
          fatura.idFatura, resultado.valor, resultado.forma);
      _avisar('Pagamento registrado!');
      await _recarregar();
    } catch (e) {
      _avisar(e.toString().replaceFirst('Exception: ', ''), erro: true);
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cliente.nome)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _processando ? null : _fecharFatura,
        icon: const Icon(Icons.receipt_long),
        label: const Text('Fechar fatura'),
      ),
      body: FutureBuilder<ResumoFinanceiro>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _Erro(
              mensagem: snapshot.error
                  .toString()
                  .replaceFirst('Exception: ', ''),
              onTentar: _recarregar,
            );
          }
          final resumo = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _recarregar,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                _ResumoHeader(resumo: resumo),
                const SizedBox(height: 16),
                if (resumo.faturas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Center(
                      child: Text(
                        'Nenhuma fatura ainda.\nUse "Fechar fatura" para agrupar os pedidos entregues.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...resumo.faturas.map((f) => _FaturaCard(
                        fatura: f,
                        onPagar: _processando ? null : () => _registrarPagamento(f),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ResumoHeader extends StatelessWidget {
  final ResumoFinanceiro resumo;
  const _ResumoHeader({required this.resumo});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_repeat, size: 18, color: cs.secondary),
                const SizedBox(width: 8),
                Text('Ciclo: ${resumo.cicloFaturamento}',
                    style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _Indicador(
                    rotulo: 'Total em aberto',
                    valor: resumo.totalEmAberto,
                    cor: resumo.totalEmAberto > 0 ? cs.error : cs.primary,
                  ),
                ),
                if (resumo.saldoCredito > 0)
                  Expanded(
                    child: _Indicador(
                      rotulo: 'Crédito do cliente',
                      valor: resumo.saldoCredito,
                      cor: cs.secondary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Indicador extends StatelessWidget {
  final String rotulo;
  final double valor;
  final Color cor;
  const _Indicador({required this.rotulo, required this.valor, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text('R\$ ${valor.toStringAsFixed(2)}',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: cor)),
      ],
    );
  }
}

class _FaturaCard extends StatelessWidget {
  final Fatura fatura;
  final VoidCallback? onPagar;
  const _FaturaCard({required this.fatura, this.onPagar});

  static const _statusInfo = {
    'ABERTA': (label: 'Aberta', color: Color(0xFFE65100)),
    'PARCIALMENTE_PAGA': (label: 'Parcial', color: Color(0xFF1565C0)),
    'PAGA': (label: 'Paga', color: Color(0xFF2E7D32)),
    'VENCIDA': (label: 'Vencida', color: Color(0xFFC62828)),
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final info = _statusInfo[fatura.status] ??
        (label: fatura.status, color: const Color(0xFF9E9E9E));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Fatura #${fatura.idFatura.toString().padLeft(5, '0')}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                _Badge(label: info.label, color: info.color),
              ],
            ),
            const SizedBox(height: 12),
            _linha('Valor total', 'R\$ ${fatura.valorTotal.toStringAsFixed(2)}'),
            _linha('Pago', 'R\$ ${fatura.valorPago.toStringAsFixed(2)}'),
            _linha(
              'Saldo devedor',
              'R\$ ${fatura.saldoDevedor.toStringAsFixed(2)}',
              destaque: true,
              cor: fatura.saldoDevedor > 0 ? cs.error : cs.primary,
            ),
            if (fatura.pagamentos.isNotEmpty) ...[
              const Divider(height: 24),
              Text('Pagamentos',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              ...fatura.pagamentos.map((p) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(p.formaPagamento,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey)),
                        Text('R\$ ${p.valor.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  )),
            ],
            if (fatura.emAberto) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onPagar,
                  icon: const Icon(Icons.payments),
                  label: const Text('Registrar pagamento'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _linha(String rotulo, String valor,
      {bool destaque = false, Color? cor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rotulo, style: const TextStyle(color: Colors.grey)),
          Text(valor,
              style: TextStyle(
                fontWeight: destaque ? FontWeight.bold : FontWeight.w500,
                color: cor,
              )),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

// Bottom sheet de registro de pagamento — devolve (valor, forma)
class _PagamentoSheet extends StatefulWidget {
  final double saldoDevedor;
  const _PagamentoSheet({required this.saldoDevedor});

  @override
  State<_PagamentoSheet> createState() => _PagamentoSheetState();
}

class _PagamentoSheetState extends State<_PagamentoSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _valorController;
  String _forma = 'PIX';

  @override
  void initState() {
    super.initState();
    _valorController = TextEditingController(
        text: widget.saldoDevedor.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) return;
    final valor = double.parse(_valorController.text.replaceAll(',', '.'));
    Navigator.pop(context, (valor: valor, forma: _forma));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Registrar pagamento',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Saldo devedor: R\$ ${widget.saldoDevedor.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _valorController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor recebido',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Informe o valor';
                final n = double.tryParse(v.replaceAll(',', '.'));
                if (n == null || n <= 0) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'PIX', label: Text('PIX'), icon: Icon(Icons.pix)),
                ButtonSegment(
                    value: 'DINHEIRO',
                    label: Text('Dinheiro'),
                    icon: Icon(Icons.payments)),
              ],
              selected: {_forma},
              onSelectionChanged: (s) => setState(() => _forma = s.first),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _confirmar,
              child: const Text('Confirmar pagamento'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Erro extends StatelessWidget {
  final String mensagem;
  final Future<void> Function() onTentar;
  const _Erro({required this.mensagem, required this.onTentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(mensagem,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onTentar, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}
