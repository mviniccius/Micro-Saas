<template>
  <div class="bg-background min-h-screen pb-24 md:pb-0">
    <AppHeader cliente-nome="Hoteis Hilton S/A" />
    <AppSidebar />

    <main class="md:ml-64 px-4 py-6 md:px-margin-desktop pt-24">

      <header class="mb-6">
        <h2 class="font-headline-lg text-headline-lg text-primary mb-1">Catálogo B2B</h2>
        <p class="font-body-md text-on-surface-variant">Selecione os produtos e monte seu pedido corporativo.</p>
      </header>

      <!-- Busca + Filtros -->
      <div class="flex flex-col md:flex-row gap-4 mb-8">
        <div class="relative flex-1">
          <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-outline text-xl">search</span>
          <input
            v-model="busca"
            type="text"
            placeholder="Buscar produto..."
            class="w-full pl-10 pr-4 py-3 border border-outline-variant/50 rounded-xl font-body-md focus:outline-none focus:border-secondary transition-colors bg-white"
          />
        </div>
        <div class="flex gap-2 overflow-x-auto pb-1 scrollbar-hide">
          <button
            v-for="cat in categorias" :key="cat.id"
            @click="categoriaAtiva = cat.id"
            :class="categoriaAtiva === cat.id
              ? 'bg-primary text-on-primary'
              : 'bg-white text-on-surface-variant border border-outline-variant/40 hover:border-primary'"
            class="px-4 py-2 rounded-full font-label-lg text-sm whitespace-nowrap transition-colors"
          >
            {{ cat.label }}
          </button>
        </div>
      </div>

      <!-- Grid de produtos -->
      <div v-if="produtosFiltrados.length > 0" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-gutter mb-12">
        <div
          v-for="p in produtosFiltrados" :key="p.id"
          class="bento-card rounded-xl overflow-hidden flex flex-col"
        >
          <div class="h-40 bg-surface-container flex items-center justify-center relative">
            <span class="material-symbols-outlined text-primary/20" style="font-size:72px;">bakery_dining</span>
            <span
              v-if="p.destaque"
              class="absolute top-3 left-3 px-2 py-1 bg-secondary text-on-secondary text-[10px] font-bold rounded-full uppercase tracking-tighter"
            >{{ p.destaque }}</span>
          </div>

          <div class="p-4 flex flex-col flex-1">
            <p class="font-label-sm text-outline uppercase tracking-wider mb-1">{{ p.categoria }}</p>
            <h3 class="font-headline-md text-primary text-base mb-1 leading-snug">{{ p.nome }}</h3>
            <p class="font-body-md text-on-surface-variant text-sm mb-4 flex-1">{{ p.descricao }}</p>

            <div class="flex items-center justify-between mt-auto">
              <div>
                <p class="font-label-sm text-outline">por {{ p.unidade }}</p>
                <p class="font-headline-md text-secondary text-lg">R$ {{ p.preco.toFixed(2).replace('.', ',') }}</p>
              </div>

              <div v-if="carrinho[p.id]" class="flex items-center gap-1 border border-primary rounded-lg px-2 py-1">
                <button @click="alterar(p.id, -1)" class="text-primary w-7 h-7 flex items-center justify-center hover:bg-primary/10 rounded transition-colors">
                  <span class="material-symbols-outlined text-sm">remove</span>
                </button>
                <span class="font-label-lg text-primary w-6 text-center text-sm">{{ carrinho[p.id] }}</span>
                <button @click="alterar(p.id, 1)" class="text-primary w-7 h-7 flex items-center justify-center hover:bg-primary/10 rounded transition-colors">
                  <span class="material-symbols-outlined text-sm">add</span>
                </button>
              </div>
              <button
                v-else
                @click="alterar(p.id, 1)"
                class="flex items-center gap-1 px-3 py-2 bg-primary text-on-primary rounded-lg font-label-lg text-xs uppercase tracking-wider hover:brightness-110 transition-all"
              >
                <span class="material-symbols-outlined text-sm">add_shopping_cart</span>
                Adicionar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty state -->
      <div v-else class="text-center py-20">
        <span class="material-symbols-outlined text-primary/20" style="font-size:80px;">search_off</span>
        <p class="font-headline-md text-on-surface-variant mt-4">Nenhum produto encontrado</p>
        <button @click="busca = ''; categoriaAtiva = 'todos'" class="mt-4 text-secondary font-label-lg underline">Limpar filtros</button>
      </div>
    </main>

    <!-- Barra de carrinho flutuante -->
    <Transition name="slide-up">
      <div v-if="totalItens > 0" class="fixed bottom-16 md:bottom-6 left-0 md:left-auto md:right-8 w-full md:w-auto z-50">
        <div class="bg-primary text-on-primary px-6 py-4 md:rounded-xl shadow-2xl flex items-center justify-between gap-8 md:gap-12">
          <div>
            <p class="font-label-sm opacity-70 uppercase tracking-wider">{{ totalItens }} {{ totalItens === 1 ? 'item' : 'itens' }}</p>
            <p class="font-headline-md text-xl">R$ {{ totalValor.toFixed(2).replace('.', ',') }}</p>
          </div>
          <button class="bg-secondary text-on-secondary px-6 py-3 rounded-lg font-label-lg uppercase tracking-widest hover:brightness-110 transition-all">
            Finalizar Pedido
          </button>
        </div>
      </div>
    </Transition>

    <AppBottomNav />
  </div>
</template>

<script setup>
import { ref, computed, reactive } from 'vue'
import AppHeader from '../components/AppHeader.vue'
import AppSidebar from '../components/AppSidebar.vue'
import AppBottomNav from '../components/AppBottomNav.vue'

const busca = ref('')
const categoriaAtiva = ref('todos')
const carrinho = reactive({})

const categorias = [
  { id: 'todos',    label: 'Todos' },
  { id: 'paes',     label: 'Pães' },
  { id: 'doces',    label: 'Doces' },
  { id: 'salgados', label: 'Salgados' },
  { id: 'bebidas',  label: 'Bebidas' },
]

const produtos = [
  { id: 1,  nome: 'Levain de Longa Fermentação', categoria: 'paes',     descricao: 'Massa madre 30 anos, hidratação 80%. Ideal para buffets premium.',        preco: 12.50, unidade: 'unidade', destaque: 'Best-Seller' },
  { id: 2,  nome: 'Baguette Francesa',            categoria: 'paes',     descricao: 'Crocante por fora, macia por dentro. Formato clássico 300g.',             preco: 4.80,  unidade: 'unidade', destaque: null },
  { id: 3,  nome: 'Mini Brioche',                 categoria: 'paes',     descricao: 'Enriquecido com manteiga e ovos. Perfeito para café da manhã corporativo.', preco: 3.20, unidade: 'unidade', destaque: null },
  { id: 4,  nome: 'Pão de Centeio Integral',      categoria: 'paes',     descricao: 'Fibras e sabor terroso. Alta aceitação em cardápios saudáveis.',          preco: 8.90,  unidade: 'unidade', destaque: null },
  { id: 5,  nome: 'Croissant Viennoiserie',        categoria: 'doces',    descricao: 'Manteiga AOP importada, 27 camadas. Padrão hotelaria 5 estrelas.',        preco: 9.50,  unidade: 'unidade', destaque: 'Lançamento' },
  { id: 6,  nome: 'Éclair de Chocolate',           categoria: 'doces',    descricao: 'Massa choux com ganache dark 70% cacau e glacê espelhado.',              preco: 7.80,  unidade: 'unidade', destaque: null },
  { id: 7,  nome: 'Caixa de Macarons (12un)',      categoria: 'doces',    descricao: 'Seis sabores exclusivos, embalagem presenteável.',                       preco: 48.00, unidade: 'caixa',   destaque: null },
  { id: 8,  nome: 'Coxinha de Frango Artesanal',  categoria: 'salgados', descricao: 'Recheio cremoso, massa fina e crocante. Porção 80g.',                    preco: 5.60,  unidade: 'unidade', destaque: null },
  { id: 9,  nome: 'Esfiha Fechada',               categoria: 'salgados', descricao: 'Massa fermentada, carne temperada com especiarias árabes.',               preco: 4.90,  unidade: 'unidade', destaque: null },
  { id: 10, nome: 'Suco de Laranja Natural 1L',   categoria: 'bebidas',  descricao: 'Laranjas selecionadas, sem adição de açúcar ou conservantes.',            preco: 14.00, unidade: 'garrafa', destaque: null },
]

const produtosFiltrados = computed(() =>
  produtos.filter(p => {
    const matchCat = categoriaAtiva.value === 'todos' || p.categoria === categoriaAtiva.value
    const matchBusca = p.nome.toLowerCase().includes(busca.value.toLowerCase())
    return matchCat && matchBusca
  })
)

function alterar(id, delta) {
  const novo = (carrinho[id] || 0) + delta
  if (novo <= 0) delete carrinho[id]
  else carrinho[id] = novo
}

const totalItens = computed(() => Object.values(carrinho).reduce((a, b) => a + b, 0))
const totalValor = computed(() =>
  Object.entries(carrinho).reduce((acc, [id, qty]) => {
    const p = produtos.find(p => p.id === Number(id))
    return acc + (p ? p.preco * qty : 0)
  }, 0)
)
</script>

<style scoped>
.slide-up-enter-active, .slide-up-leave-active { transition: transform 0.25s ease, opacity 0.25s ease; }
.slide-up-enter-from, .slide-up-leave-to { transform: translateY(40px); opacity: 0; }
</style>
