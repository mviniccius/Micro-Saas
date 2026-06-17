import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/cliente_model.dart';
import '../../data/models/produto_model.dart';
import '../../data/services/pedido_service.dart';

const _primary = Color(0xFF173426);
const _secondary = Color(0xFF79591D);
const _onSurfaceVariant = Color(0xFF424844);
const _surfaceContainer = Color(0xFFF0EDED);
const _surfaceContainerLow = Color(0xFFF6F3F2);
const _outlineVariant = Color(0xFFC2C8C2);
const _secondaryFixed = Color(0xFFFFDEAC);
const _background = Color(0xFFFCF9F8);

class CriarPedidoScreen extends StatefulWidget {
  final Cliente cliente;
  final List<Map<String, dynamic>> itens;

  const CriarPedidoScreen({
    super.key,
    required this.cliente,
    required this.itens,
  });

  @override
  State<CriarPedidoScreen> createState() => _CriarPedidoScreenState();
}

class _CriarPedidoScreenState extends State<CriarPedidoScreen> {
  final _pedidoService = PedidoService();
  final _observacoesController = TextEditingController();
  late List<Map<String, dynamic>> _itens;
  bool _confirmando = false;
  int _janelaHorario = 0;

  static const _janelas = [
    '06:00 – 07:30 (Primeira Entrega)',
    '08:00 – 09:30 (Café da Manhã)',
    '13:00 – 14:30 (Reposição Tarde)',
    '16:00 – 17:30 (Fechamento)',
  ];

  @override
  void initState() {
    super.initState();
    _itens = List<Map<String, dynamic>>.from(widget.itens);
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    super.dispose();
  }

  double get _subtotal => _itens.fold(0.0, (soma, item) {
        final produto = item['produto'] as Produto;
        final quantidade = item['quantidade'] as int;
        return soma + produto.preco * quantidade;
      });

  double get _total => _subtotal;

  void _alterarQuantidade(int index, int delta) {
    setState(() {
      final qtdAtual = _itens[index]['quantidade'] as int;
      final nova = qtdAtual + delta;
      if (nova <= 0) {
        _itens.removeAt(index);
      } else {
        _itens[index] = {..._itens[index], 'quantidade': nova};
      }
    });
  }

  void _removerItem(int index) {
    setState(() => _itens.removeAt(index));
  }

  Future<void> _confirmarPedido() async {
    if (_itens.isEmpty) return;
    setState(() => _confirmando = true);

    try {
      final itens = _itens.map((item) {
        final produto = item['produto'] as Produto;
        return {'id_produto': produto.idProduto, 'quantidade': item['quantidade'] as int};
      }).toList();

      await _pedidoService.criarPedido(idCliente: widget.cliente.idCliente, itens: itens);

      if (!mounted) return;
      _mostrarSucesso();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao confirmar pedido: $e'), backgroundColor: const Color(0xFFBA1A1A)),
      );
    } finally {
      if (mounted) setState(() => _confirmando = false);
    }
  }

  void _mostrarSucesso() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _primary,
        content: Row(children: [
          const Icon(Icons.check_circle, color: _secondaryFixed),
          const SizedBox(width: 12),
          Text('Pedido realizado com sucesso!',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white)),
        ]),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Panificadora Efraim',
            style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w600, color: _primary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: _primary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: _outlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      body: _itens.isEmpty
          ? _CarrinhoVazio(onVoltar: () => Navigator.pop(context))
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Itens ──────────────────────────────────
                      Row(children: [
                        const Icon(Icons.shopping_basket, color: _primary, size: 22),
                        const SizedBox(width: 10),
                        Text('Seus Itens Selecionados',
                            style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w500, color: _primary)),
                      ]),
                      const SizedBox(height: 16),

                      ..._itens.asMap().entries.map((entry) {
                        final i = entry.key;
                        final item = entry.value;
                        final produto = item['produto'] as Produto;
                        final quantidade = item['quantidade'] as int;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ItemCard(
                            produto: produto,
                            quantidade: quantidade,
                            onIncrement: () => _alterarQuantidade(i, 1),
                            onDecrement: () => _alterarQuantidade(i, -1),
                            onRemover: () => _removerItem(i),
                          ),
                        );
                      }),

                      const SizedBox(height: 24),

                      // ── Agendamento ────────────────────────────
                      _SecaoAgendamento(
                        janelaAtiva: _janelaHorario,
                        janelas: _janelas,
                        onJanelaChanged: (i) => setState(() => _janelaHorario = i),
                      ),
                      const SizedBox(height: 24),

                      // ── Observações ───────────────────────────
                      Row(children: [
                        const Icon(Icons.notes, color: _primary, size: 22),
                        const SizedBox(width: 10),
                        Text('Instruções e Observações',
                            style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w500, color: _primary)),
                      ]),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: _surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _outlineVariant.withValues(alpha: 0.3)),
                        ),
                        child: TextField(
                          controller: _observacoesController,
                          maxLines: 3,
                          style: GoogleFonts.montserrat(fontSize: 14, color: _primary),
                          decoration: InputDecoration(
                            hintText: 'Ex: Entregar na recepção secundária, faturar para o centro de custo X...',
                            hintStyle: GoogleFonts.montserrat(fontSize: 13, color: _outlineVariant),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Resumo ────────────────────────────────
                      _ResumoCard(
                        subtotal: _subtotal,
                        total: _total,
                        confirmando: _confirmando,
                        onConfirmar: _confirmarPedido,
                      ),
                      const SizedBox(height: 16),

                      // ── Badge segurança ────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _outlineVariant.withValues(alpha: 0.3)),
                        ),
                        child: Row(children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: _primary.withValues(alpha: 0.1), shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.security, color: _primary, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Checkout Seguro',
                                  style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: _primary)),
                              Text('Dados protegidos por criptografia Panificadora Efraim.',
                                  style: GoogleFonts.montserrat(fontSize: 11, color: _onSurfaceVariant)),
                            ]),
                          ),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Card de item ──────────────────────────────────────────────────────────────
class _ItemCard extends StatelessWidget {
  final Produto produto;
  final int quantidade;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemover;

  const _ItemCard({
    required this.produto, required this.quantidade,
    required this.onIncrement, required this.onDecrement, required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = produto.preco * quantidade;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder imagem
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: _surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.bakery_dining, color: _primary.withValues(alpha: 0.35), size: 36),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(produto.nomeProduto,
                            style: GoogleFonts.cinzel(fontSize: 15, fontWeight: FontWeight.w500, color: _primary, height: 1.2)),
                        const SizedBox(height: 2),
                        Text('R\$ ${produto.preco.toStringAsFixed(2)} / un',
                            style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600,
                                color: _onSurfaceVariant, letterSpacing: 0.5)),
                      ]),
                    ),
                    GestureDetector(
                      onTap: onRemover,
                      child: Icon(Icons.delete_outline, color: _outlineVariant.withValues(alpha: 0.8), size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Controle de quantidade
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        border: Border.all(color: _outlineVariant.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        _QtyButton(icon: Icons.remove, onTap: onDecrement),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            quantidade.toString().padLeft(2, '0'),
                            style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: _primary),
                          ),
                        ),
                        _QtyButton(icon: Icons.add, onTap: onIncrement),
                      ]),
                    ),
                    // Subtotal
                    Text('R\$ ${subtotal.toStringAsFixed(2)}',
                        style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w500, color: _secondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: _primary),
      ),
    );
  }
}

// ── Agendamento de entrega ─────────────────────────────────────────────────────
class _SecaoAgendamento extends StatelessWidget {
  final int janelaAtiva;
  final List<String> janelas;
  final void Function(int) onJanelaChanged;

  const _SecaoAgendamento({
    required this.janelaAtiva, required this.janelas, required this.onJanelaChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.schedule, color: _primary, size: 22),
            const SizedBox(width: 10),
            Text('Agendamento de Entrega',
                style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w500, color: _primary)),
          ]),
          const SizedBox(height: 4),
          Text('Nossa prioridade é a pontualidade para seu negócio.',
              style: GoogleFonts.montserrat(fontSize: 13, color: _onSurfaceVariant)),
          const SizedBox(height: 20),

          Text('JANELA DE HORÁRIO',
              style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, color: _primary, letterSpacing: 1)),
          const SizedBox(height: 10),
          ...janelas.asMap().entries.map((e) {
            final ativo = e.key == janelaAtiva;
            return GestureDetector(
              onTap: () => onJanelaChanged(e.key),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: ativo ? _primary : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ativo ? _primary : _outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(ativo ? Icons.radio_button_checked : Icons.radio_button_off,
                        size: 18, color: ativo ? _secondaryFixed : _outlineVariant),
                    const SizedBox(width: 10),
                    Text(e.value,
                        style: GoogleFonts.montserrat(
                          fontSize: 13, fontWeight: FontWeight.w500,
                          color: ativo ? Colors.white : _primary,
                        )),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _secondary.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified, color: _secondary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Garantia Efraim: Compromisso de entrega em até 15 minutos de margem do horário selecionado para parceiros.',
                    style: GoogleFonts.montserrat(fontSize: 12, color: _secondary, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card de resumo ─────────────────────────────────────────────────────────────
class _ResumoCard extends StatelessWidget {
  final double subtotal;
  final double total;
  final bool confirmando;
  final VoidCallback onConfirmar;

  const _ResumoCard({
    required this.subtotal, required this.total,
    required this.confirmando, required this.onConfirmar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: _primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumo do Pedido',
              style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 4),
          Divider(color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 12),

          _ResumoLinha('Subtotal de Itens', 'R\$ ${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _ResumoLinha('Taxa de Entrega', 'R\$ 0,00'),
          const SizedBox(height: 16),

          Divider(color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Valor Total',
                  style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(
                  'R\$ ${total.toStringAsFixed(2)}',
                  style: GoogleFonts.cinzel(fontSize: 32, fontWeight: FontWeight.w700, color: _secondaryFixed),
                ),
                Text('via boleto ou pix',
                    style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white.withValues(alpha: 0.5),
                        letterSpacing: 1)),
              ]),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: confirmando ? null : onConfirmar,
              style: ElevatedButton.styleFrom(
                backgroundColor: _secondary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: confirmando
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('CONFIRMAR PEDIDO',
                          style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ]),
            ),
          ),

          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.payments_outlined, color: Colors.white.withValues(alpha: 0.4), size: 20),
            const SizedBox(width: 16),
            Icon(Icons.credit_card_outlined, color: Colors.white.withValues(alpha: 0.4), size: 20),
            const SizedBox(width: 16),
            Icon(Icons.account_balance_outlined, color: Colors.white.withValues(alpha: 0.4), size: 20),
          ]),
        ],
      ),
    );
  }
}

class _ResumoLinha extends StatelessWidget {
  final String label;
  final String valor;
  const _ResumoLinha(this.label, this.valor);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
        Text(valor, style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
      ],
    );
  }
}

// ── Carrinho vazio ─────────────────────────────────────────────────────────────
class _CarrinhoVazio extends StatelessWidget {
  final VoidCallback onVoltar;
  const _CarrinhoVazio({required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.shopping_basket_outlined, size: 72, color: _primary.withValues(alpha: 0.2)),
        const SizedBox(height: 20),
        Text('Carrinho vazio',
            style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.w500, color: _onSurfaceVariant)),
        const SizedBox(height: 8),
        Text('Adicione itens no catálogo para continuar.',
            style: GoogleFonts.montserrat(fontSize: 14, color: _onSurfaceVariant)),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: onVoltar,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
          child: Text('Voltar ao Catálogo',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}
