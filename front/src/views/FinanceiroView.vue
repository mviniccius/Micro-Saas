<template>
  <div class="bg-background min-h-screen pb-24 md:pb-0">
    <AppHeader cliente-nome="Hoteis Hilton S/A" />
    <AppSidebar />

    <main class="md:ml-64 px-4 py-6 md:px-margin-desktop pt-24">

      <header class="mb-6">
        <h2 class="font-headline-lg text-headline-lg text-primary mb-1">Área Financeira</h2>
        <p class="font-body-md text-on-surface-variant">Faturas, pagamentos e relatórios corporativos.</p>
      </header>

      <!-- KPIs -->
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-gutter mb-8">
        <div class="bento-card rounded-xl p-5 flex flex-col gap-2">
          <div class="flex items-center gap-2 text-outline">
            <span class="material-symbols-outlined text-lg">pending_actions</span>
            <p class="font-label-sm uppercase tracking-wider text-xs">Total em Aberto</p>
          </div>
          <p class="font-headline-lg text-primary text-3xl">R$ 7.325,00</p>
          <div class="w-full bg-surface-container rounded-full h-1.5 mt-1">
            <div class="bg-secondary h-1.5 rounded-full" style="width: 58%"></div>
          </div>
          <p class="font-label-sm text-outline text-xs">58% do limite mensal utilizado</p>
        </div>

        <div class="bento-card rounded-xl p-5 flex flex-col gap-2">
          <div class="flex items-center gap-2 text-outline">
            <span class="material-symbols-outlined text-lg">event</span>
            <p class="font-label-sm uppercase tracking-wider text-xs">Próximo Vencimento</p>
          </div>
          <p class="font-headline-lg text-primary text-3xl">25 jun</p>
          <span class="px-3 py-1 bg-[#fff8ec] text-[#79591d] rounded-full text-[11px] font-bold uppercase tracking-tighter w-fit">Fatura #EF-0142</span>
          <p class="font-label-sm text-outline text-xs">R$ 4.875,00 em aberto</p>
        </div>

        <div class="bento-card rounded-xl p-5 flex flex-col gap-2">
          <div class="flex items-center gap-2 text-outline">
            <span class="material-symbols-outlined text-lg">savings</span>
            <p class="font-label-sm uppercase tracking-wider text-xs">Limite Disponível</p>
          </div>
          <p class="font-headline-lg text-primary text-3xl">R$ 5.175,00</p>
          <div class="w-full bg-surface-container rounded-full h-1.5 mt-1">
            <div class="bg-primary h-1.5 rounded-full" style="width: 42%"></div>
          </div>
          <p class="font-label-sm text-outline text-xs">de R$ 12.500,00 de limite total</p>
        </div>
      </div>

      <!-- Tabs -->
      <div class="flex gap-0 border-b border-outline-variant/30 mb-6">
        <button
          v-for="tab in tabs" :key="tab.id"
          @click="tabAtiva = tab.id"
          :class="tabAtiva === tab.id ? 'border-b-2 border-primary text-primary' : 'text-on-surface-variant'"
          class="px-6 py-3 font-label-lg text-sm uppercase tracking-wider transition-colors"
        >
          {{ tab.label }}
        </button>
      </div>

      <!-- Tab: Faturas -->
      <div v-if="tabAtiva === 'faturas'">
        <div class="bento-card rounded-xl overflow-hidden">
          <!-- Cabeçalho da tabela (desktop) -->
          <div class="hidden md:grid grid-cols-[2fr_1fr_1fr_1fr_1fr] gap-4 px-6 py-3 bg-surface-container border-b border-outline-variant/20">
            <span class="font-label-sm text-outline uppercase tracking-wider text-xs">Fatura</span>
            <span class="font-label-sm text-outline uppercase tracking-wider text-xs">Emissão</span>
            <span class="font-label-sm text-outline uppercase tracking-wider text-xs">Vencimento</span>
            <span class="font-label-sm text-outline uppercase tracking-wider text-xs text-right">Valor</span>
            <span class="font-label-sm text-outline uppercase tracking-wider text-xs text-center">Status</span>
          </div>

          <div
            v-for="fatura in faturas" :key="fatura.id"
            class="flex flex-col md:grid md:grid-cols-[2fr_1fr_1fr_1fr_1fr] gap-2 md:gap-4 px-6 py-4 border-b border-outline-variant/10 last:border-0 hover:bg-surface-container/50 transition-colors"
          >
            <div>
              <p class="font-headline-md text-primary text-sm">{{ fatura.id }}</p>
              <p class="font-label-sm text-outline text-xs md:hidden">{{ fatura.emissao }}</p>
            </div>
            <p class="font-body-md text-on-surface-variant text-sm hidden md:block">{{ fatura.emissao }}</p>
            <p class="font-body-md text-sm" :class="fatura.vencido ? 'text-error font-bold' : 'text-on-surface-variant'">{{ fatura.vencimento }}</p>
            <p class="font-headline-md text-primary text-sm md:text-right">R$ {{ fatura.valor.toFixed(2).replace('.', ',') }}</p>
            <div class="flex md:justify-center">
              <span
                class="px-3 py-1 rounded-full text-[11px] font-bold uppercase tracking-tighter w-fit"
                :class="statusFaturaClass(fatura.status)"
              >{{ fatura.status }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Tab: Histórico de Pagamentos -->
      <div v-if="tabAtiva === 'historico'" class="flex flex-col gap-4">
        <div
          v-for="pag in pagamentos" :key="pag.id"
          class="bento-card rounded-xl p-5 flex items-center gap-4"
        >
          <div
            class="w-10 h-10 rounded-full flex items-center justify-center shrink-0"
            :class="pag.tipo === 'credito' ? 'bg-[#e8f5e9] text-[#2e7d32]' : 'bg-[#fdecea] text-error'"
          >
            <span class="material-symbols-outlined text-lg">{{ pag.tipo === 'credito' ? 'add_circle' : 'remove_circle' }}</span>
          </div>
          <div class="flex-1">
            <p class="font-headline-md text-on-surface text-sm">{{ pag.descricao }}</p>
            <p class="font-label-sm text-outline text-xs">{{ pag.data }}</p>
          </div>
          <p
            class="font-headline-md text-lg shrink-0"
            :class="pag.tipo === 'credito' ? 'text-[#2e7d32]' : 'text-error'"
          >{{ pag.tipo === 'credito' ? '+' : '-' }} R$ {{ pag.valor.toFixed(2).replace('.', ',') }}</p>
        </div>
      </div>
    </main>

    <AppBottomNav />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import AppHeader from '../components/AppHeader.vue'
import AppSidebar from '../components/AppSidebar.vue'
import AppBottomNav from '../components/AppBottomNav.vue'

const tabAtiva = ref('faturas')

const tabs = [
  { id: 'faturas',   label: 'Faturas' },
  { id: 'historico', label: 'Histórico' },
]

function statusFaturaClass(status) {
  return {
    'Em Aberto': 'bg-[#fff8ec] text-[#79591d]',
    'Pago':      'bg-[#e8f5e9] text-[#2e7d32]',
    'Vencido':   'bg-[#fdecea] text-error',
  }[status] || 'bg-surface-container text-on-surface-variant'
}

const faturas = [
  { id: 'FAT-0142', emissao: '01 jun 2026', vencimento: '25 jun 2026', valor: 4875.00, status: 'Em Aberto', vencido: false },
  { id: 'FAT-0141', emissao: '18 mai 2026', vencimento: '10 jun 2026', valor: 2450.00, status: 'Pago',      vencido: false },
  { id: 'FAT-0140', emissao: '04 mai 2026', vencimento: '28 mai 2026', valor: 3630.00, status: 'Pago',      vencido: false },
  { id: 'FAT-0139', emissao: '19 abr 2026', vencimento: '14 mai 2026', valor: 1220.00, status: 'Pago',      vencido: false },
  { id: 'FAT-0138', emissao: '02 abr 2026', vencimento: '26 abr 2026', valor: 980.00,  status: 'Vencido',   vencido: true  },
]

const pagamentos = [
  { id: 1, tipo: 'debito',  descricao: 'Fatura FAT-0142 — Pedido #EF-9931', data: '01 jun 2026', valor: 4875.00 },
  { id: 2, tipo: 'credito', descricao: 'Pagamento recebido — FAT-0141',      data: '10 jun 2026', valor: 2450.00 },
  { id: 3, tipo: 'debito',  descricao: 'Fatura FAT-0141 — Pedido #EF-9921', data: '18 mai 2026', valor: 2450.00 },
  { id: 4, tipo: 'credito', descricao: 'Pagamento recebido — FAT-0140',      data: '28 mai 2026', valor: 3630.00 },
  { id: 5, tipo: 'debito',  descricao: 'Fatura FAT-0140 — Pedido #EF-9908', data: '04 mai 2026', valor: 3630.00 },
]
</script>
