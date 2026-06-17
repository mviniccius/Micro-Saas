<template>
  <div class="bg-background min-h-screen pb-24 md:pb-0">
    <AppHeader cliente-nome="Hoteis Hilton S/A" />
    <AppSidebar />

    <main class="md:ml-64 px-4 py-6 md:px-margin-desktop pt-24">

      <header class="mb-6">
        <h2 class="font-headline-lg text-headline-lg text-primary mb-1">Histórico de Pedidos</h2>
        <p class="font-body-md text-on-surface-variant">Acompanhe o status e gerencie suas entregas.</p>
      </header>

      <!-- Filtros de status -->
      <div class="flex gap-2 overflow-x-auto pb-2 mb-6">
        <button
          v-for="f in filtros" :key="f.id"
          @click="filtroAtivo = f.id"
          :class="filtroAtivo === f.id ? 'bg-primary text-on-primary' : 'bg-white text-on-surface-variant border border-outline-variant/40 hover:border-primary'"
          class="px-4 py-2 rounded-full font-label-lg text-sm whitespace-nowrap transition-colors flex items-center gap-2"
        >
          <span v-if="f.cor" class="w-2 h-2 rounded-full inline-block" :style="{ background: f.cor }"></span>
          {{ f.label }}
        </button>
      </div>

      <!-- Lista de pedidos -->
      <div class="flex flex-col gap-4">
        <div
          v-for="pedido in pedidosFiltrados" :key="pedido.id"
          class="bento-card rounded-xl overflow-hidden flex"
        >
          <div class="w-1.5 shrink-0 rounded-l-xl" :style="{ background: statusCor(pedido.status) }"></div>

          <div class="flex-1 p-5">
            <div class="flex flex-col md:flex-row md:items-start justify-between gap-3">
              <div class="flex-1">
                <div class="flex items-center gap-3 mb-2 flex-wrap">
                  <h3 class="font-headline-md text-primary">#EF-{{ String(pedido.id).padStart(4, '0') }}</h3>
                  <span
                    class="px-3 py-1 rounded-full text-[11px] font-bold uppercase tracking-tighter"
                    :style="{ background: statusBg(pedido.status), color: statusCor(pedido.status) }"
                  >{{ statusLabel(pedido.status) }}</span>
                </div>
                <p class="font-label-sm text-outline mb-3">{{ pedido.data }} · {{ pedido.itens.length }} {{ pedido.itens.length === 1 ? 'item' : 'itens' }}</p>
                <div class="flex flex-wrap gap-2">
                  <span
                    v-for="item in pedido.itens.slice(0, 3)" :key="item.nome"
                    class="px-2 py-1 bg-surface-container rounded text-xs font-body-md text-on-surface-variant"
                  >{{ item.nome }} ×{{ item.qty }}</span>
                  <span v-if="pedido.itens.length > 3" class="px-2 py-1 bg-surface-container rounded text-xs text-outline">
                    +{{ pedido.itens.length - 3 }} mais
                  </span>
                </div>
              </div>

              <div class="flex flex-col items-start md:items-end gap-3 shrink-0">
                <p class="font-headline-lg text-primary text-2xl">R$ {{ pedido.total.toFixed(2).replace('.', ',') }}</p>
                <div class="flex gap-2">
                  <button class="px-4 py-2 border border-outline-variant/50 text-on-surface-variant font-label-lg text-xs uppercase tracking-wider rounded-lg hover:border-primary hover:text-primary transition-colors">
                    Detalhes
                  </button>
                  <button
                    v-if="['C', 'E'].includes(pedido.status)"
                    class="px-4 py-2 bg-primary text-on-primary font-label-lg text-xs uppercase tracking-wider rounded-lg hover:brightness-110 transition-all"
                  >
                    Repetir
                  </button>
                </div>
              </div>
            </div>

            <!-- Barra de progresso -->
            <div v-if="pedido.status !== 'X' && pedido.status !== 'C'" class="mt-4 pt-4 border-t border-outline-variant/20">
              <div class="flex items-center">
                <div v-for="(etapa, i) in etapas" :key="etapa.id" class="flex items-center" :class="i < etapas.length - 1 ? 'flex-1' : ''">
                  <div class="flex flex-col items-center gap-1">
                    <div
                      class="w-7 h-7 rounded-full flex items-center justify-center transition-all"
                      :class="etapa.id === pedido.status ? 'bg-primary text-on-primary' : ordemStatus[pedido.status] > ordemStatus[etapa.id] ? 'bg-primary-container text-on-primary-container' : 'bg-surface-container text-outline'"
                    >
                      <span class="material-symbols-outlined" style="font-size:14px;">{{ etapa.icon }}</span>
                    </div>
                    <span class="font-label-sm text-[10px] text-outline text-center hidden md:block w-12">{{ etapa.label }}</span>
                  </div>
                  <div
                    v-if="i < etapas.length - 1"
                    class="h-0.5 flex-1 mx-1 transition-all"
                    :class="ordemStatus[pedido.status] > ordemStatus[etapas[i].id] ? 'bg-primary' : 'bg-surface-container'"
                  ></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div v-if="pedidosFiltrados.length === 0" class="text-center py-20">
        <span class="material-symbols-outlined text-primary/20" style="font-size:80px;">receipt_long</span>
        <p class="font-headline-md text-on-surface-variant mt-4">Nenhum pedido nesta categoria</p>
      </div>
    </main>

    <AppBottomNav />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import AppHeader from '../components/AppHeader.vue'
import AppSidebar from '../components/AppSidebar.vue'
import AppBottomNav from '../components/AppBottomNav.vue'

const filtroAtivo = ref('todos')

const filtros = [
  { id: 'todos', label: 'Todos',       cor: null },
  { id: 'P',     label: 'Recebido',    cor: '#79591d' },
  { id: 'A',     label: 'Em Produção', cor: '#173426' },
  { id: 'S',     label: 'Separado',    cor: '#2e7d52' },
  { id: 'E',     label: 'Em Entrega',  cor: '#1565c0' },
  { id: 'C',     label: 'Entregue',    cor: '#2e7d32' },
  { id: 'X',     label: 'Cancelado',   cor: '#c62828' },
]

const etapas = [
  { id: 'P', label: 'Recebido',   icon: 'inbox' },
  { id: 'A', label: 'Produção',   icon: 'blender' },
  { id: 'S', label: 'Separado',   icon: 'inventory' },
  { id: 'E', label: 'Entrega',    icon: 'local_shipping' },
]

const ordemStatus = { P: 0, A: 1, S: 2, E: 3, C: 4, X: -1 }

const statusLabel = s => ({ P: 'Recebido', A: 'Em Produção', S: 'Separado', E: 'Em Entrega', C: 'Entregue', X: 'Cancelado' }[s] || s)
const statusCor  = s => ({ P: '#79591d', A: '#173426', S: '#2e7d52', E: '#1565c0', C: '#2e7d32', X: '#c62828' }[s] || '#727973')
const statusBg   = s => ({ P: '#fff8ec', A: '#edf4ef', S: '#e8f5ee', E: '#e3eeff', C: '#e8f5e9', X: '#fdecea' }[s] || '#f0eded')

const pedidos = [
  { id: 9931, status: 'A', data: '16 jun 2026 · 08:14', total: 4875.00,
    itens: [{ nome: 'Levain', qty: 200 }, { nome: 'Mini Brioche', qty: 500 }, { nome: 'Baguette', qty: 150 }] },
  { id: 9921, status: 'C', data: '14 jun 2026 · 06:30', total: 2450.00,
    itens: [{ nome: 'Mix Baguette', qty: 200 }, { nome: 'Mini Brioche', qty: 500 }] },
  { id: 9908, status: 'C', data: '12 jun 2026 · 06:30', total: 3630.00,
    itens: [{ nome: 'Croissant', qty: 300 }, { nome: 'Éclair', qty: 100 }, { nome: 'Levain', qty: 80 }] },
  { id: 9895, status: 'E', data: '11 jun 2026 · 07:00', total: 2188.00,
    itens: [{ nome: 'Pão Centeio', qty: 120 }, { nome: 'Coxinha', qty: 200 }] },
  { id: 9880, status: 'X', data: '09 jun 2026 · 10:22', total: 960.00,
    itens: [{ nome: 'Macarons 12un', qty: 20 }] },
]

const pedidosFiltrados = computed(() =>
  filtroAtivo.value === 'todos' ? pedidos : pedidos.filter(p => p.status === filtroAtivo.value)
)
</script>
