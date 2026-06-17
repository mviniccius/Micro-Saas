import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/cliente_model.dart';
import '../../data/models/produto_model.dart';
import '../../data/models/pedido_model.dart';
import '../../data/services/produto_service.dart';
import '../../data/services/pedido_service.dart';
import 'criar_pedido_screen.dart';
import 'pedido_detalhe_screen.dart';

// Cores do design system (acesso rápido sem Theme.of)
const _primary = Color(0xFF173426);
const _secondary = Color(0xFF79591D);
const _onSurface = Color(0xFF1C1B1B);
const _onSurfaceVariant = Color(0xFF424844);
const _surfaceContainer = Color(0xFFF0EDED);
const _surfaceContainerLow = Color(0xFFF6F3F2);
const _outlineVariant = Color(0xFFC2C8C2);
const _secondaryContainer = Color(0xFFFDD089);
const _onSecondaryContainer = Color(0xFF78581C);
const _background = Color(0xFFFCF9F8);

// ─────────────────────────────────────────────
// Shell principal com Bottom Navigation
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  final Cliente cliente;
  const HomeScreen({super.key, required this.cliente});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _goTo(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _DashboardTab(cliente: widget.cliente, onNovoPedido: () => _goTo(1)),
          _CatalogoTab(cliente: widget.cliente),
          _PedidosTab(cliente: widget.cliente, onNovoPedido: () => _goTo(1)),
          const _FinanceiroTab(),
          const _AssinaturaTab(),
        ],
      ),
      floatingActionButton: _selectedIndex < 2
          ? FloatingActionButton(
              onPressed: () => _goTo(1),
              backgroundColor: _secondary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _goTo,
        backgroundColor: _surfaceContainer,
        indicatorColor: _secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: _onSecondaryContainer),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: _onSecondaryContainer),
            label: 'Catálogo',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: _onSecondaryContainer),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet, color: _onSecondaryContainer),
            label: 'Financeiro',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_repeat_outlined),
            selectedIcon: Icon(Icons.event_repeat, color: _onSecondaryContainer),
            label: 'Assinatura',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab 0 — Dashboard
// ─────────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback onNovoPedido;

  const _DashboardTab({required this.cliente, required this.onNovoPedido});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: _background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              const Icon(Icons.bakery_dining, color: _primary),
              const SizedBox(width: 8),
              Text(
                'Panificadora Efraim',
                style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w600, color: _primary),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: _onSurfaceVariant),
              onPressed: () {},
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: _outlineVariant.withValues(alpha: 0.3)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _HeroBanner(onExplorar: onNovoPedido),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _ProximaEntregaCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _UltimoPedidoCard(onRepetir: onNovoPedido)),
                ],
              ),
              const SizedBox(height: 16),
              _QuickShortcuts(onNovoPedido: onNovoPedido),
              const SizedBox(height: 24),
              _FeaturedProducts(),
            ]),
          ),
        ),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final VoidCallback onExplorar;
  const _HeroBanner({required this.onExplorar});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF173426), Color(0xFF2E4B3C), Color(0xFF476555)],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'TRADIÇÃO DESDE 1984',
            style: GoogleFonts.montserrat(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: const Color(0xFFFFDEAC), letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Qualidade Institucional\npara seu Negócio',
            style: GoogleFonts.cinzel(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, height: 1.3,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: onExplorar,
              style: ElevatedButton.styleFrom(
                backgroundColor: _secondary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: Text('EXPLORAR CATÁLOGO',
                  style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProximaEntregaCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: const BorderSide(color: _secondary, width: 4),
          top: BorderSide(color: _primary.withValues(alpha: 0.1)),
          right: BorderSide(color: _primary.withValues(alpha: 0.1)),
          bottom: BorderSide(color: _primary.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Próxima Entrega',
                    style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.w500, color: _primary)),
              ),
              const Icon(Icons.local_shipping, color: _secondary, size: 24),
            ],
          ),
          Text('Rastreamento', style: GoogleFonts.montserrat(fontSize: 11, color: _onSurfaceVariant)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.75,
              backgroundColor: _outlineVariant.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(_secondary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text('A caminho',
              style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, color: _secondary)),
          const SizedBox(height: 10),
          Text('Horário Previsto', style: GoogleFonts.montserrat(fontSize: 10, color: _onSurfaceVariant)),
          Text('06:45 – 07:15',
              style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.w500, color: _primary)),
        ],
      ),
    );
  }
}

class _UltimoPedidoCard extends StatelessWidget {
  final VoidCallback onRepetir;
  const _UltimoPedidoCard({required this.onRepetir});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Último Pedido',
              style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.w500, color: _primary)),
          const SizedBox(height: 10),
          _OrderItem('50x Pão de Sal', 'R\$ 45,00'),
          Divider(height: 14, color: _outlineVariant.withValues(alpha: 0.3)),
          _OrderItem('10x Bolo Cenoura', 'R\$ 120,00'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRepetir,
              style: ElevatedButton.styleFrom(
                backgroundColor: _secondary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text('REPETIR',
                  style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final String nome;
  final String valor;
  const _OrderItem(this.nome, this.valor);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(nome,
              style: GoogleFonts.montserrat(fontSize: 11, color: _onSurface), overflow: TextOverflow.ellipsis),
        ),
        Text(valor,
            style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, color: _primary)),
      ],
    );
  }
}

class _QuickShortcuts extends StatelessWidget {
  final VoidCallback onNovoPedido;
  const _QuickShortcuts({required this.onNovoPedido});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ShortcutButton(icon: Icons.add_shopping_cart, label: 'NOVO\nPEDIDO', onTap: onNovoPedido)),
        const SizedBox(width: 8),
        Expanded(child: _ShortcutButton(icon: Icons.account_balance_wallet, label: 'FATURAS', onTap: () {})),
        const SizedBox(width: 8),
        Expanded(child: _ShortcutButton(icon: Icons.support_agent, label: 'SUPORTE', onTap: () {})),
      ],
    );
  }
}

class _ShortcutButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShortcutButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: _primary.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: Icon(icon, color: _primary, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w600, color: _primary, letterSpacing: 0.5),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _FeaturedProducts extends StatefulWidget {
  @override
  State<_FeaturedProducts> createState() => _FeaturedProductsState();
}

class _FeaturedProductsState extends State<_FeaturedProducts> {
  final _service = ProdutoService();
  late Future<List<Produto>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.listarProdutos();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Destaques da Produção',
                style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w600, color: _primary)),
            TextButton(
              onPressed: () {},
              child: Text('Ver tudo',
                  style: GoogleFonts.montserrat(
                    fontSize: 12, fontWeight: FontWeight.w600, color: _secondary,
                    decoration: TextDecoration.underline, decorationColor: _secondary,
                  )),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Produto>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();
            return Column(
              children: snapshot.data!.take(2).map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _FeaturedCard(produto: p),
              )).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Produto produto;
  const _FeaturedCard({required this.produto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.bakery_dining, color: _primary, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(produto.nomeProduto,
                    style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.w500, color: _primary)),
                const SizedBox(height: 4),
                Text('R\$ ${produto.preco.toStringAsFixed(2)} / unid',
                    style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: _secondary)),
              ],
            ),
          ),
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.add, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab 1 — Catálogo (Pedido Rápido)
// ─────────────────────────────────────────────
class _CatalogoTab extends StatefulWidget {
  final Cliente cliente;
  const _CatalogoTab({required this.cliente});

  @override
  State<_CatalogoTab> createState() => _CatalogoTabState();
}

class _CatalogoTabState extends State<_CatalogoTab> {
  final _produtoService = ProdutoService();
  late Future<List<Produto>> _produtosFuture;
  final Map<int, int> _quantidades = {};
  final Map<int, TextEditingController> _controllers = {};
  int _categoriaAtiva = 0;

  static const _categorias = ['Frequentes', 'Pães', 'Confeitaria', 'Integrais'];

  @override
  void initState() {
    super.initState();
    _produtosFuture = _produtoService.listarProdutos();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  TextEditingController _controllerFor(int id) =>
      _controllers.putIfAbsent(id, () => TextEditingController(text: '0'));

  void _setQuantidade(int id, int valor, {bool atualizarController = true}) {
    final qtd = valor < 0 ? 0 : valor;
    setState(() {
      if (qtd == 0) _quantidades.remove(id);
      else _quantidades[id] = qtd;
      if (atualizarController) _controllerFor(id).text = '$qtd';
    });
  }

  int get _totalItens => _quantidades.values.fold(0, (s, q) => s + q);

  double _calcularTotal(List<Produto> produtos) {
    return _quantidades.entries.fold(0.0, (soma, e) {
      final p = produtos.where((p) => p.idProduto == e.key).firstOrNull;
      return soma + (p?.preco ?? 0) * e.value;
    });
  }

  void _irParaPedido(List<Produto> produtos) {
    final itens = _quantidades.entries.map((e) {
      final produto = produtos.firstWhere((p) => p.idProduto == e.key);
      return {'produto': produto, 'quantidade': e.value};
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CriarPedidoScreen(cliente: widget.cliente, itens: itens)),
    ).then((_) {
      setState(() {
        _quantidades.clear();
        for (final c in _controllers.values) c.text = '0';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: FutureBuilder<List<Produto>>(
        future: _produtosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));
          final produtos = snapshot.data!;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // AppBar
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: _background,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    title: Row(
                      children: [
                        const Icon(Icons.bakery_dining, color: _primary),
                        const SizedBox(width: 8),
                        Text('Panificadora Efraim',
                            style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w600, color: _primary)),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: _onSurfaceVariant),
                        onPressed: () {},
                      ),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(1),
                      child: Divider(height: 1, color: _outlineVariant.withValues(alpha: 0.3)),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Título + subtítulo
                        Text('Pedido Rápido',
                            style: GoogleFonts.cinzel(fontSize: 26, fontWeight: FontWeight.w600, color: _primary)),
                        const SizedBox(height: 6),
                        Text(
                          'Bem-vindo de volta, ${widget.cliente.nome}. Selecione os itens para sua reposição.',
                          style: GoogleFonts.montserrat(fontSize: 14, color: _onSurfaceVariant, height: 1.5),
                        ),
                        const SizedBox(height: 20),

                        // Chips de categoria
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categorias.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final ativo = i == _categoriaAtiva;
                              return GestureDetector(
                                onTap: () => setState(() => _categoriaAtiva = i),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: ativo ? _primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: ativo ? _primary : _secondary),
                                  ),
                                  child: Text(
                                    _categorias[i].toUpperCase(),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12, fontWeight: FontWeight.w600,
                                      color: ativo ? Colors.white : _secondary,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Lista de produtos
                        if (produtos.isEmpty)
                          const Center(child: Text('Nenhum produto disponível'))
                        else
                          ...produtos.map((p) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ProdutoCard(
                                  produto: p,
                                  controller: _controllerFor(p.idProduto),
                                  quantidade: _quantidades[p.idProduto] ?? 0,
                                  onAlterarQuantidade: (delta) =>
                                      _setQuantidade(p.idProduto, (_quantidades[p.idProduto] ?? 0) + delta),
                                  onDigitar: (v) =>
                                      _setQuantidade(p.idProduto, int.tryParse(v) ?? 0, atualizarController: false),
                                ),
                              )),

                        // Card "Últimos Detalhes"
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border(top: BorderSide(color: _secondary.withValues(alpha: 0.3), width: 2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Icon(Icons.history, color: _primary, size: 20),
                                const SizedBox(width: 8),
                                Text('Últimos Detalhes',
                                    style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w500, color: _primary)),
                              ]),
                              const SizedBox(height: 16),
                              Row(children: [
                                const Icon(Icons.schedule, color: _secondary, size: 20),
                                const SizedBox(width: 12),
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Entrega Programada',
                                      style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: _primary)),
                                  Text('Amanhã, entre 06:30 e 07:15',
                                      style: GoogleFonts.montserrat(fontSize: 13, color: _onSurfaceVariant)),
                                ]),
                              ]),
                              const SizedBox(height: 12),
                              Row(children: [
                                const Icon(Icons.credit_card, color: _secondary, size: 20),
                                const SizedBox(width: 12),
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Forma de Pagamento',
                                      style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: _primary)),
                                  Text('Boleto Quinzenal (Faturado)',
                                      style: GoogleFonts.montserrat(fontSize: 13, color: _onSurfaceVariant)),
                                ]),
                              ]),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),

              // FAB com total — só aparece quando há itens
              if (_totalItens > 0)
                Positioned(
                  bottom: 16, left: 16, right: 16,
                  child: GestureDetector(
                    onTap: () => _irParaPedido(produtos),
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [BoxShadow(color: _primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TOTAL ESTIMADO',
                                  style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w500,
                                      color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1.5)),
                              Text(
                                'R\$ ${_calcularTotal(produtos).toStringAsFixed(2).replaceAll('.', ',')}',
                                style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ],
                          ),
                          Row(children: [
                            Text('FINALIZAR',
                                style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700,
                                    color: Colors.white, letterSpacing: 1)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: Colors.white),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ProdutoCard extends StatelessWidget {
  final Produto produto;
  final int quantidade;
  final TextEditingController controller;
  final void Function(int) onAlterarQuantidade;
  final void Function(String) onDigitar;

  const _ProdutoCard({
    required this.produto, required this.quantidade,
    required this.controller, required this.onAlterarQuantidade, required this.onDigitar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Placeholder de imagem
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: _surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.bakery_dining, color: _primary.withValues(alpha: 0.4), size: 32),
          ),
          const SizedBox(width: 14),
          // Info + controles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(produto.nomeProduto,
                    style: GoogleFonts.cinzel(fontSize: 15, fontWeight: FontWeight.w500, color: _primary, height: 1.2)),
                const SizedBox(height: 4),
                Text('R\$ ${produto.preco.toStringAsFixed(2)} / un',
                    style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: _secondary)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Botão −
                    GestureDetector(
                      onTap: quantidade > 0 ? () => onAlterarQuantidade(-1) : null,
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          border: Border.all(color: _outlineVariant),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(Icons.remove, size: 18,
                            color: quantidade > 0 ? _primary : _outlineVariant),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Campo numérico
                    SizedBox(
                      width: 56,
                      height: 36,
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 14, color: _primary),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          filled: true,
                          fillColor: _surfaceContainer,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(color: _secondary, width: 1),
                          ),
                        ),
                        onChanged: onDigitar,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botão +
                    GestureDetector(
                      onTap: () => onAlterarQuantidade(1),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.add, size: 18, color: Colors.white),
                      ),
                    ),
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

// ─────────────────────────────────────────────
// Tab 2 — Pedidos (polling 10s)
// ─────────────────────────────────────────────
// Tab 2 — Histórico de Pedidos
// ─────────────────────────────────────────────
class _PedidosTab extends StatefulWidget {
  final Cliente cliente;
  final VoidCallback onNovoPedido;
  const _PedidosTab({required this.cliente, required this.onNovoPedido});

  @override
  State<_PedidosTab> createState() => _PedidosTabState();
}

class _PedidosTabState extends State<_PedidosTab> {
  final _pedidoService = PedidoService();
  List<Pedido> _pedidos = [];
  bool _carregando = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _buscarPedidos();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _buscarPedidos());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _buscarPedidos() async {
    try {
      final pedidos = await _pedidoService.buscarPedidosPorTelefone(widget.cliente.telefone);
      if (mounted) setState(() { _pedidos = pedidos; _carregando = false; });
    } catch (_) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            title: Text('Histórico de Pedidos',
                style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w600, color: _primary)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: _primary),
                onPressed: () { setState(() => _carregando = true); _buscarPedidos(); },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: _outlineVariant.withValues(alpha: 0.3)),
            ),
          ),

          if (_carregando)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_pedidos.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.receipt_long, size: 64, color: _primary.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text('Nenhum pedido ainda',
                      style: GoogleFonts.cinzel(fontSize: 18, color: _onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('Gerencie seus suprimentos recorrentes aqui.',
                      style: GoogleFonts.montserrat(fontSize: 13, color: _onSurfaceVariant)),
                ]),
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Gerencie seus suprimentos recorrentes e acompanhe o status das suas entregas.',
                  style: GoogleFonts.montserrat(fontSize: 13, color: _onSurfaceVariant, height: 1.5),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _PedidoCard(
                      pedido: _pedidos[i],
                      onDetalhe: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PedidoDetalheScreen(pedido: _pedidos[i])),
                      ),
                      onRepetir: widget.onNovoPedido,
                    ),
                  ),
                  childCount: _pedidos.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onDetalhe;
  final VoidCallback onRepetir;
  const _PedidoCard({required this.pedido, required this.onDetalhe, required this.onRepetir});

  static const _statusConfig = {
    'P': (label: 'Recebido',    color: Color(0xFF1565C0), borderColor: Color(0xFF173426)),
    'A': (label: 'Em Produção', color: Color(0xFF6D4C41), borderColor: Color(0xFF79591D)),
    'S': (label: 'Separado',    color: Color(0xFF00695C), borderColor: Color(0xFF00695C)),
    'E': (label: 'Em Trânsito', color: Color(0xFF79591D), borderColor: Color(0xFF79591D)),
    'C': (label: 'Entregue',    color: Color(0xFF173426), borderColor: Color(0xFF173426)),
    'X': (label: 'Cancelado',   color: Color(0xFFBA1A1A), borderColor: Color(0xFFBA1A1A)),
  };

  static const _statusBg = {
    'P': Color(0xFFE3F2FD),
    'A': Color(0xFFFFF3E0),
    'S': Color(0xFFE0F2F1),
    'E': Color(0xFFFDD089),
    'C': Color(0xFFE8F5E9),
    'X': Color(0xFFFFDAD6),
  };

  @override
  Widget build(BuildContext context) {
    final s = pedido.status.trim().toUpperCase();
    final cfg = _statusConfig[s] ?? (label: 'Desconhecido', color: _onSurfaceVariant, borderColor: _outlineVariant);
    final bg = _statusBg[s] ?? _surfaceContainerLow;
    final cancelado = s == 'X';
    final totalItens = pedido.itens.fold(0, (soma, item) => soma + item.quantidade);

    return Container(
      decoration: BoxDecoration(
        color: cancelado ? _surfaceContainerLow : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _secondary.withValues(alpha: 0.15)),
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Borda colorida esquerda
            Container(width: 4, color: cfg.borderColor.withValues(alpha: cancelado ? 0.3 : 0.7)),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Linha 1: ID + badge status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('#EF-${pedido.idPedido.toString().padLeft(5, '0')}',
                            style: GoogleFonts.cinzel(
                                fontSize: 15, fontWeight: FontWeight.w600,
                                color: cancelado ? _onSurfaceVariant : _primary)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: cfg.color.withValues(alpha: 0.3)),
                          ),
                          child: Text(cfg.label,
                              style: GoogleFonts.montserrat(
                                  fontSize: 10, fontWeight: FontWeight.w700,
                                  color: cfg.color, letterSpacing: 0.8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Linha 2: resumo de itens
                    Row(children: [
                      Icon(cancelado ? Icons.block : Icons.inventory_2_outlined,
                          size: 16, color: _onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text('$totalItens unidade(s) • ${pedido.itens.length} produto(s)',
                          style: GoogleFonts.montserrat(fontSize: 12, color: _onSurfaceVariant)),
                    ]),
                    const SizedBox(height: 12),

                    // Linha 3: valor total
                    Text('R\$ ${pedido.valorTotal.toStringAsFixed(2)}',
                        style: GoogleFonts.cinzel(
                            fontSize: 22, fontWeight: FontWeight.w500,
                            color: cancelado ? _onSurfaceVariant : _primary)),
                    const SizedBox(height: 14),

                    // Linha 4: botões de ação
                    Row(children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: cancelado ? null : onRepetir,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cancelado ? _primary.withValues(alpha: 0.15) : _primary,
                            foregroundColor: cancelado ? _primary.withValues(alpha: 0.4) : Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.replay, size: 16),
                          label: Text('Repetir',
                              style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: onDetalhe,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _onSurfaceVariant,
                          side: BorderSide(color: _outlineVariant.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          s == 'E' ? 'Rastrear' : (s == 'X' ? 'Ajuda' : 'Detalhes'),
                          style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab 3 — Área Financeira
// ─────────────────────────────────────────────
class _FinanceiroTab extends StatelessWidget {
  const _FinanceiroTab();

  static const _barData = [
    (mes: 'Jan', h: 0.50),
    (mes: 'Fev', h: 0.63),
    (mes: 'Mar', h: 0.82),
    (mes: 'Abr', h: 0.56),
    (mes: 'Mai', h: 0.75),
    (mes: 'Jun', h: 0.94),
  ];

  static const _faturas = [
    (id: '#EF-9821', venc: '15/10/2024', valor: 'R\$ 1.250,00'),
    (id: '#EF-9755', venc: '25/10/2024', valor: 'R\$ 3.000,80'),
  ];

  static const _historico = [
    (titulo: 'Fatura Setembro', data: 'Pago em 14/09/2024', valor: 'R\$ 2.400,00'),
    (titulo: 'Fatura Agosto',   data: 'Pago em 15/08/2024', valor: 'R\$ 1.950,50'),
    (titulo: 'Fatura Julho',    data: 'Pago em 12/07/2024', valor: 'R\$ 2.120,00'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            title: Text('Área Financeira',
                style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w600, color: _primary)),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: _outlineVariant.withValues(alpha: 0.3)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Header ──────────────────────────────────────
                Text('Painel do Cliente',
                    style: GoogleFonts.montserrat(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: _secondary, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Área Financeira',
                        style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.w600, color: _primary)),
                    Row(children: [
                      _ActionBtn(icon: Icons.account_balance_wallet_outlined, label: 'PIX', filled: true),
                      const SizedBox(width: 8),
                      _ActionBtn(icon: Icons.download_outlined, label: 'Relatórios', filled: false),
                    ]),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Total em aberto ──────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total em Aberto',
                          style: GoogleFonts.montserrat(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.6), letterSpacing: 1)),
                      const SizedBox(height: 6),
                      Text('R\$ 4.250,80',
                          style: GoogleFonts.cinzel(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 16),
                      Text('Próximo vencimento: 15 de Outubro',
                          style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.66,
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFDEAC)),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Gráfico consumo mensal ───────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _outlineVariant.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Consumo Mensal',
                              style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w500, color: _primary)),
                          Row(children: [
                            _Legenda(color: _primary, label: 'Compras'),
                            const SizedBox(width: 12),
                            _Legenda(color: _secondary, label: 'Pagamentos'),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 140,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: _barData.map((d) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: FractionallySizedBox(
                                        heightFactor: d.h,
                                        alignment: Alignment.bottomCenter,
                                        child: Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: _secondary.withValues(alpha: 0.15),
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0, left: 0, right: 0,
                                              height: 80 * d.h,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: _primary,
                                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(d.mes,
                                        style: GoogleFonts.montserrat(fontSize: 10, color: _onSurfaceVariant)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Faturas em aberto ────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _outlineVariant.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Faturas em Aberto',
                          style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w500, color: _primary)),
                      const SizedBox(height: 16),
                      Divider(color: _outlineVariant.withValues(alpha: 0.3)),
                      // Cabeçalho tabela
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(children: [
                          Expanded(child: _ThLabel('ID PEDIDO')),
                          Expanded(child: _ThLabel('VENCIMENTO')),
                          Expanded(child: _ThLabel('VALOR')),
                          _ThLabel('AÇÕES'),
                        ]),
                      ),
                      Divider(color: _outlineVariant.withValues(alpha: 0.3)),
                      ..._faturas.map((f) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(children: [
                          Expanded(
                            child: Text(f.id,
                                style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700, color: _primary)),
                          ),
                          Expanded(
                            child: Text(f.venc,
                                style: GoogleFonts.montserrat(fontSize: 12, color: _onSurfaceVariant)),
                          ),
                          Expanded(
                            child: Text(f.valor,
                                style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                          Row(children: [
                            Icon(Icons.description_outlined, size: 20, color: _secondary),
                            const SizedBox(width: 8),
                            Icon(Icons.qr_code_2, size: 20, color: _secondary),
                          ]),
                        ]),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Histórico de pagamentos ──────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _outlineVariant.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Histórico',
                              style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w500, color: _primary)),
                          Text('VER TUDO',
                              style: GoogleFonts.montserrat(
                                  fontSize: 10, fontWeight: FontWeight.w700,
                                  color: _secondary, letterSpacing: 1)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._historico.asMap().entries.map((e) => Padding(
                        padding: EdgeInsets.only(bottom: e.key < _historico.length - 1 ? 16 : 0,
                            top: e.key > 0 ? 0 : 0),
                        child: Row(children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: _primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.check_circle_outline, color: _primary, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(e.value.titulo,
                                style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: _primary)),
                            Text(e.value.data,
                                style: GoogleFonts.montserrat(fontSize: 11, color: _onSurfaceVariant)),
                          ])),
                          Text(e.value.valor,
                              style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: _secondary)),
                        ]),
                      )),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  const _ActionBtn({required this.icon, required this.label, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? _primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: filled ? null : Border.all(color: _secondary.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        Icon(icon, size: 14, color: filled ? Colors.white : _secondary),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.montserrat(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: filled ? Colors.white : _secondary, letterSpacing: 0.8)),
      ]),
    );
  }
}

class _Legenda extends StatelessWidget {
  final Color color;
  final String label;
  const _Legenda({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.montserrat(fontSize: 10, color: _onSurfaceVariant)),
    ]);
  }
}

class _ThLabel extends StatelessWidget {
  final String text;
  const _ThLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.montserrat(
            fontSize: 10, fontWeight: FontWeight.w700, color: _secondary, letterSpacing: 0.8));
  }
}

// ─────────────────────────────────────────────
// Tab 4 — Assinatura de Pedidos Recorrentes
// ─────────────────────────────────────────────
class _AssinaturaTab extends StatefulWidget {
  const _AssinaturaTab();

  @override
  State<_AssinaturaTab> createState() => _AssinaturaTabState();
}

class _AssinaturaTabState extends State<_AssinaturaTab> {
  int _frequencia = 0; // 0=Diário, 1=Semanal, 2=Mensal
  final _qtds = [100, 50];
  static const _freqLabels = ['DIÁRIO', 'SEMANAL', 'MENSAL'];
  static const _freqIcons = [Icons.event_repeat, Icons.date_range, Icons.calendar_today];

  static const _itens = [
    (nome: 'Pão Francês Tradicional', codigo: 'EF-001', horario: '06:00'),
    (nome: 'Mini Croissants Manteiga', codigo: 'EF-042', horario: '07:30'),
  ];

  static const _sugestoes = [
    (titulo: 'Kit Café Escolar',      sub: 'Frutas + Pães Integrais'),
    (titulo: 'Coffee Break Premium',  sub: 'Mini Salgados Variados'),
    (titulo: 'Clássicos do Dia',      sub: 'Pão Francês + Queijo'),
    (titulo: 'Catálogo Completo',     sub: 'Ver todos os produtos'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            title: Text('Assinatura',
                style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w600, color: _primary)),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: _outlineVariant.withValues(alpha: 0.3)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Hero ─────────────────────────────────────────
                Text('Parceria B2B',
                    style: GoogleFonts.montserrat(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: _secondary, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text('Assinatura de Entregas Recorrentes',
                          style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.w600, color: _primary)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary, foregroundColor: Colors.white,
                        elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.add_circle_outline, size: 16),
                      label: Text('Nova', style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Gerencie o abastecimento automático com a pontualidade e tradição da Efraim.',
                  style: GoogleFonts.montserrat(fontSize: 13, color: _onSurfaceVariant, height: 1.5),
                ),
                const SizedBox(height: 24),

                // ── Configurador de ciclo ─────────────────────────
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
                      Row(children: [
                        const Icon(Icons.calendar_month, color: _secondary, size: 22),
                        const SizedBox(width: 10),
                        Text('Configurador de Ciclo',
                            style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w500, color: _primary)),
                      ]),
                      const SizedBox(height: 20),

                      // Seletor de frequência
                      Row(children: List.generate(3, (i) {
                        final ativo = i == _frequencia;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _frequencia = i),
                            child: Container(
                              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: ativo ? _secondary.withValues(alpha: 0.08) : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: ativo ? _secondary : _outlineVariant.withValues(alpha: 0.4),
                                  width: ativo ? 2 : 1,
                                ),
                              ),
                              child: Column(children: [
                                Icon(_freqIcons[i],
                                    size: 28, color: ativo ? _secondary : _outlineVariant),
                                const SizedBox(height: 6),
                                Text(_freqLabels[i],
                                    style: GoogleFonts.montserrat(
                                        fontSize: 10, fontWeight: FontWeight.w700,
                                        color: ativo ? _secondary : _onSurfaceVariant, letterSpacing: 0.8)),
                              ]),
                            ),
                          ),
                        );
                      })),
                      const SizedBox(height: 20),

                      // Cabeçalho tabela
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _surfaceContainer,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('ITENS DO PEDIDO AUTOMÁTICO',
                                style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w700,
                                    color: _primary, letterSpacing: 0.8)),
                            Text('Total: R\$ 420,00/dia',
                                style: GoogleFonts.montserrat(fontSize: 10, color: _onSurfaceVariant,
                                    fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),

                      // Itens
                      ...List.generate(_itens.length, (i) {
                        final item = _itens[i];
                        return Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: _outlineVariant.withValues(alpha: 0.1)),
                          ),
                          child: Row(children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                color: _surfaceContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(Icons.bakery_dining,
                                  color: _primary.withValues(alpha: 0.3), size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(item.nome,
                                    style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.w500, color: _primary)),
                                Text('Código: ${item.codigo}',
                                    style: GoogleFonts.montserrat(fontSize: 10, color: _onSurfaceVariant)),
                              ]),
                            ),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              // +/-
                              Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border.all(color: _outlineVariant.withValues(alpha: 0.4)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(children: [
                                  _MiniQtyBtn(icon: Icons.remove,
                                      onTap: () => setState(() { if (_qtds[i] > 0) _qtds[i] -= 10; })),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('${_qtds[i]}',
                                        style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700, color: _primary)),
                                  ),
                                  _MiniQtyBtn(icon: Icons.add,
                                      onTap: () => setState(() => _qtds[i] += 10)),
                                ]),
                              ),
                              const SizedBox(height: 4),
                              Text(item.horario,
                                  style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, color: _primary)),
                              Text('Entrega', style: GoogleFonts.montserrat(fontSize: 9, color: _onSurfaceVariant)),
                            ]),
                          ]),
                        );
                      }),

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            const Icon(Icons.info_outline, color: _secondary, size: 16),
                            const SizedBox(width: 6),
                            Text('Alterações até 12h antes.',
                                style: GoogleFonts.montserrat(fontSize: 11, color: _onSurfaceVariant)),
                          ]),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _secondary, foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            child: Text('SALVAR',
                                style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Logística ativa ───────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.local_shipping, color: _secondary, size: 20),
                        const SizedBox(width: 8),
                        Text('LOGÍSTICA ATIVA',
                            style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700,
                                color: _primary, letterSpacing: 1)),
                      ]),
                      const SizedBox(height: 16),
                      _TimelineItem(
                        tempo: 'HOJE - 06:05',
                        descricao: 'Pedido #9842 Entregue',
                        badge: 'Sucesso',
                        badgeColor: _primary,
                        ativo: true,
                      ),
                      const SizedBox(height: 12),
                      _TimelineItem(
                        tempo: 'AMANHÃ - 06:00',
                        descricao: 'Pedido Programado (${_qtds[0] + _qtds[1]} itens)',
                        badge: 'Pendente',
                        badgeColor: _onSurfaceVariant,
                        ativo: false,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _secondary,
                          side: const BorderSide(color: _secondary),
                          minimumSize: const Size.fromHeight(40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: Text('VER MAPA DE ROTAS',
                            style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Financeiro ────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _primary, borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Faturamento Mensal Estimado',
                                style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white.withValues(alpha: 0.6),
                                    letterSpacing: 0.5)),
                            Text('R\$ 12.600,00',
                                style: GoogleFonts.cinzel(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                          ]),
                          Icon(Icons.payments_outlined, color: Colors.white.withValues(alpha: 0.4), size: 28),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Desconto B2B (15%)',
                            style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                        Text('-R\$ 1.890,00',
                            style: GoogleFonts.montserrat(fontSize: 12, color: const Color(0xFFFFDEAC), fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 6),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Taxa de Entrega Fixa',
                            style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                        Text('Inclusa',
                            style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                      ]),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E4B3C),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('PRÓXIMO VENCIMENTO',
                              style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white.withValues(alpha: 0.6), letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text('Dia 10 de Outubro',
                              style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                        ]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Suporte ───────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _surfaceContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _outlineVariant.withValues(alpha: 0.5),
                        style: BorderStyle.solid),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Suporte Corporativo',
                          style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700,
                              color: _primary, letterSpacing: 0.5)),
                      const SizedBox(height: 6),
                      Text('Dúvidas sobre grandes volumes ou faturamento via boleto?',
                          style: GoogleFonts.montserrat(fontSize: 12, color: _onSurfaceVariant, height: 1.4)),
                      const SizedBox(height: 12),
                      Row(children: [
                        Text('Falar com Gerente de Conta',
                            style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700, color: _secondary)),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, color: _secondary, size: 16),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Sugestões ─────────────────────────────────────
                Text('Sugestões para seu Setor',
                    style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w500, color: _primary)),
                Divider(color: _outlineVariant.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.85,
                  children: _sugestoes.asMap().entries.map((e) {
                    final isLast = e.key == _sugestoes.length - 1;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isLast ? _secondary.withValues(alpha: 0.05) : _surfaceContainer,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isLast
                                    ? _secondary.withValues(alpha: 0.3)
                                    : _outlineVariant.withValues(alpha: 0.2),
                                style: isLast ? BorderStyle.solid : BorderStyle.solid,
                              ),
                            ),
                            child: isLast
                                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Icon(Icons.auto_awesome, color: _secondary, size: 36),
                                    const SizedBox(height: 8),
                                    Text('CATÁLOGO', textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w700,
                                            color: _secondary, letterSpacing: 1)),
                                    Text('COMPLETO', textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w700,
                                            color: _secondary, letterSpacing: 1)),
                                  ])
                                : Center(
                                    child: Icon(Icons.bakery_dining,
                                        color: _primary.withValues(alpha: 0.2), size: 48)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(e.value.titulo,
                            style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.w500, color: _primary)),
                        Text(e.value.sub,
                            style: GoogleFonts.montserrat(fontSize: 11, color: _onSurfaceVariant)),
                      ],
                    );
                  }).toList(),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniQtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MiniQtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 30,
        alignment: Alignment.center,
        child: Icon(icon, size: 14, color: _primary),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String tempo;
  final String descricao;
  final String badge;
  final Color badgeColor;
  final bool ativo;
  const _TimelineItem({
    required this.tempo, required this.descricao,
    required this.badge, required this.badgeColor, required this.ativo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
              color: ativo ? _primary : _outlineVariant,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          Container(width: 2, height: 36, color: ativo ? _primary.withValues(alpha: 0.3) : _outlineVariant.withValues(alpha: 0.3)),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tempo,
                style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w700, color: _onSurfaceVariant)),
            Text(descricao,
                style: GoogleFonts.montserrat(fontSize: 13, color: _primary)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(badge,
                  style: GoogleFonts.montserrat(
                      fontSize: 9, fontWeight: FontWeight.w700,
                      color: badgeColor, letterSpacing: 0.8)),
            ),
          ]),
        ),
      ],
    );
  }
}
