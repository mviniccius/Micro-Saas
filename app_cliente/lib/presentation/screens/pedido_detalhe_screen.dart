import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/pedido_model.dart';

const _primary = Color(0xFF173426);
const _secondary = Color(0xFF79591D);
const _onSurfaceVariant = Color(0xFF424844);
const _surfaceContainer = Color(0xFFF0EDED);
const _surfaceContainerLow = Color(0xFFF6F3F2);
const _outlineVariant = Color(0xFFC2C8C2);
const _secondaryFixed = Color(0xFFFFDEAC);
const _background = Color(0xFFFCF9F8);
const _error = Color(0xFFBA1A1A);

// Mapeamento status código → índice do passo (0..4)
// P=Pendente(Recebido), A=Em Produção, S=Separado, E=Em Entrega, C=Concluído, X=Cancelado
const _statusStep = {'P': 0, 'A': 1, 'S': 2, 'E': 3, 'C': 4, 'X': -1};

const _passos = [
  (label: 'Recebido',   icon: Icons.check_circle_outline),
  (label: 'Produção',   icon: Icons.bakery_dining),
  (label: 'Separado',   icon: Icons.inventory_2_outlined),
  (label: 'Em Entrega', icon: Icons.local_shipping_outlined),
  (label: 'Entregue',   icon: Icons.home_outlined),
];

const _statusLabel = {
  'P': 'RECEBIDO',
  'A': 'EM PRODUÇÃO',
  'S': 'SEPARADO',
  'E': 'EM ENTREGA',
  'C': 'ENTREGUE',
  'X': 'CANCELADO',
};

const _logMensagem = {
  'P': 'Pedido recebido e aguardando processamento.',
  'A': 'Equipe de produção iniciou o preparo dos itens.',
  'S': 'Pedido separado e pronto para despacho.',
  'E': 'Motorista iniciou o trajeto para entrega.',
  'C': 'Pedido entregue com sucesso.',
  'X': 'Pedido cancelado. Entre em contato para mais informações.',
};

class PedidoDetalheScreen extends StatelessWidget {
  final Pedido pedido;

  const PedidoDetalheScreen({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    final statusCode = pedido.status.trim().toUpperCase();
    final stepAtivo = _statusStep[statusCode] ?? 0;
    final cancelado = statusCode == 'X';

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
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Header ───────────────────────────────────────────
                _HeaderSection(pedido: pedido, statusLabel: _statusLabel[statusCode] ?? 'PROCESSANDO'),
                const SizedBox(height: 24),

                // ── Tracker ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Status do Processamento',
                              style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w500, color: _primary)),
                          if (!cancelado)
                            Row(children: [
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                  color: _secondary, shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(_statusLabel[statusCode] ?? '',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 10, fontWeight: FontWeight.w700,
                                      color: _secondary, letterSpacing: 1)),
                            ])
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('CANCELADO',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 10, fontWeight: FontWeight.w700, color: _error)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      if (!cancelado) ...[
                        _ProgressTracker(stepAtivo: stepAtivo),
                        const SizedBox(height: 28),
                        Divider(color: _outlineVariant.withValues(alpha: 0.3)),
                        const SizedBox(height: 20),
                        _LogItem(mensagem: _logMensagem[statusCode] ?? ''),
                      ] else ...[
                        Center(
                          child: Column(children: [
                            Icon(Icons.cancel_outlined, color: _error.withValues(alpha: 0.4), size: 56),
                            const SizedBox(height: 12),
                            Text('Pedido cancelado',
                                style: GoogleFonts.cinzel(fontSize: 16, color: _error)),
                            const SizedBox(height: 6),
                            Text(_logMensagem['X'] ?? '',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(fontSize: 13, color: _onSurfaceVariant)),
                          ]),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Placeholder "mapa" ────────────────────────────────
                if (!cancelado) ...[
                  _MapaPlaceholder(statusCode: statusCode),
                  const SizedBox(height: 24),
                ],

                // ── Resumo do pedido ──────────────────────────────────
                _ResumoCard(pedido: pedido),
                const SizedBox(height: 16),

                // ── Garantia Efraim ───────────────────────────────────
                _GarantiaCard(),
                const SizedBox(height: 16),

                // ── Endereço ──────────────────────────────────────────
                _EnderecoCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _HeaderSection extends StatelessWidget {
  final Pedido pedido;
  final String statusLabel;
  const _HeaderSection({required this.pedido, required this.statusLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Pedido #${pedido.idPedido.toString().padLeft(5, '0')}',
              style: GoogleFonts.montserrat(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: _secondary, letterSpacing: 2)),
          const SizedBox(height: 4),
          Text('Acompanhe seu Pedido',
              style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.w600, color: _primary)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _outlineVariant.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_today, color: _secondary, size: 16),
            const SizedBox(width: 8),
            Text('Hoje, 09:30',
                style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, color: _primary)),
          ]),
        ),
      ],
    );
  }
}

// ── Progress tracker ──────────────────────────────────────────────────────────
class _ProgressTracker extends StatelessWidget {
  final int stepAtivo;
  const _ProgressTracker({required this.stepAtivo});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final totalWidth = constraints.maxWidth;
      final fillFraction = stepAtivo / (_passos.length - 1);

      return Column(children: [
        Stack(children: [
          // Linha de fundo
          Positioned(
            top: 20, left: 0, right: 0,
            child: Container(height: 3, color: _outlineVariant.withValues(alpha: 0.3)),
          ),
          // Linha de progresso
          Positioned(
            top: 20, left: 0,
            child: Container(
              height: 3,
              width: totalWidth * fillFraction,
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Bolinhas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _passos.asMap().entries.map((e) {
              final i = e.key;
              final passo = e.value;
              final done = i <= stepAtivo;
              final isActive = i == stepAtivo;

              return Column(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: done ? _primary : _surfaceContainer,
                    shape: BoxShape.circle,
                    border: isActive
                        ? Border.all(color: _secondary.withValues(alpha: 0.4), width: 3)
                        : Border.all(color: done ? _primary : _outlineVariant.withValues(alpha: 0.4)),
                  ),
                  child: Icon(
                    done ? Icons.check : passo.icon,
                    size: 18,
                    color: done ? Colors.white : _outlineVariant,
                  ),
                ),
              ]);
            }).toList(),
          ),
        ]),
        const SizedBox(height: 10),
        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _passos.asMap().entries.map((e) {
            final i = e.key;
            final done = i <= stepAtivo;
            final isActive = i == stepAtivo;
            return SizedBox(
              width: 56,
              child: Text(e.value.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: done
                        ? (isActive ? _primary : _primary.withValues(alpha: 0.7))
                        : _outlineVariant,
                    letterSpacing: 0.3,
                  )),
            );
          }).toList(),
        ),
      ]);
    });
  }
}

// ── Log item ──────────────────────────────────────────────────────────────────
class _LogItem extends StatelessWidget {
  final String mensagem;
  const _LogItem({required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.history, color: _primary.withValues(alpha: 0.4), size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(mensagem,
                style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: _primary)),
            const SizedBox(height: 2),
            Text('Atualização automática',
                style: GoogleFonts.montserrat(fontSize: 11, color: _onSurfaceVariant)),
          ]),
        ),
      ],
    );
  }
}

// ── Mapa placeholder ──────────────────────────────────────────────────────────
class _MapaPlaceholder extends StatelessWidget {
  final String statusCode;
  const _MapaPlaceholder({required this.statusCode});

  @override
  Widget build(BuildContext context) {
    final emEntrega = statusCode == 'E';

    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.2)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF3EF), Color(0xFFF6F0E8)],
        ),
      ),
      child: Stack(children: [
        // Grid decorativo imitando mapa topográfico
        CustomPaint(painter: _MapGridPainter(), child: const SizedBox.expand()),

        // Card do motorista (só se em entrega)
        Positioned(
          bottom: 16, left: 16, right: 16,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _outlineVariant.withValues(alpha: 0.2)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  emEntrega ? Icons.local_shipping : Icons.location_on,
                  color: _primary, size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(emEntrega ? 'Em Trânsito' : 'Aguardando Despacho',
                      style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.w700,
                          color: _secondary, letterSpacing: 1)),
                  Text(emEntrega ? 'Motorista a caminho' : 'Centro de Distribuição Sul',
                      style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.w500, color: _primary)),
                  Text(emEntrega ? 'Previsão: 09:30' : 'Panificadora Efraim',
                      style: GoogleFonts.montserrat(fontSize: 11, color: _onSurfaceVariant)),
                ]),
              ),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.call, color: Colors.white, size: 18),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// Pintor do grid decorativo (simula mapa topográfico)
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF173426).withValues(alpha: 0.06)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Linhas horizontais curvas (topográficas)
    for (var i = 1; i < 6; i++) {
      final y = size.height * i / 6;
      final path = Path()
        ..moveTo(0, y)
        ..cubicTo(size.width * 0.25, y - 12, size.width * 0.75, y + 12, size.width, y);
      canvas.drawPath(path, paint);
    }

    // Linhas verticais
    for (var i = 1; i < 8; i++) {
      final x = size.width * i / 8;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Marcador de posição
    final markerPaint = Paint()..color = const Color(0xFF79591D).withValues(alpha: 0.5)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.35), 8, markerPaint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.35), 14,
        markerPaint..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Resumo do pedido ──────────────────────────────────────────────────────────
class _ResumoCard extends StatelessWidget {
  final Pedido pedido;
  const _ResumoCard({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumo do Pedido',
              style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w500, color: _primary)),
          const SizedBox(height: 16),
          Divider(color: _outlineVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 12),

          ...pedido.itens.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Produto #${item.idProduto}  ×  ${item.quantidade} un.',
                    style: GoogleFonts.montserrat(fontSize: 13, color: _onSurfaceVariant),
                  ),
                ),
                Text('R\$ ${item.valorTotalItem.toStringAsFixed(2)}',
                    style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: _primary)),
              ],
            ),
          )),

          const SizedBox(height: 8),
          Divider(color: _outlineVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Taxa de Entrega (B2B)',
                  style: GoogleFonts.montserrat(fontSize: 13, color: _onSurfaceVariant)),
              Text('R\$ 0,00',
                  style: GoogleFonts.montserrat(fontSize: 13, color: _onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w500, color: _primary)),
              Text('R\$ ${pedido.valorTotal.toStringAsFixed(2)}',
                  style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w600, color: _primary)),
            ],
          ),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: BorderSide(color: _outlineVariant.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              icon: const Icon(Icons.receipt_outlined, size: 18),
              label: Text('Baixar Nota Fiscal',
                  style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Garantia Efraim ───────────────────────────────────────────────────────────
class _GarantiaCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.verified_user, color: _secondaryFixed, size: 22),
            const SizedBox(width: 12),
            Text('Garantia Efraim',
                style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700,
                    color: _secondaryFixed, letterSpacing: 1.2)),
          ]),
          const SizedBox(height: 12),
          Text(
            'Nossa entrega segue rigorosos padrões institucionais de temperatura e higiene. Em caso de divergências, contate nosso suporte premium imediato.',
            style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white.withValues(alpha: 0.85), height: 1.5),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Text('Falar com Consultor',
                style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                    decoration: TextDecoration.underline,
                    decorationColor: _secondaryFixed.withValues(alpha: 0.6))),
          ),
        ],
      ),
    );
  }
}

// ── Endereço ──────────────────────────────────────────────────────────────────
class _EnderecoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.location_on_outlined, color: _onSurfaceVariant, size: 18),
            const SizedBox(width: 8),
            Text('Endereço de Entrega',
                style: GoogleFonts.montserrat(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: _onSurfaceVariant, letterSpacing: 1.2)),
          ]),
          const SizedBox(height: 12),
          Text('Panificadora Efraim',
              style: GoogleFonts.cinzel(fontSize: 15, fontWeight: FontWeight.w600, color: _primary)),
          const SizedBox(height: 4),
          Text('Endereço registrado no cadastro do cliente.',
              style: GoogleFonts.montserrat(fontSize: 12, color: _onSurfaceVariant, height: 1.5)),
        ],
      ),
    );
  }
}
