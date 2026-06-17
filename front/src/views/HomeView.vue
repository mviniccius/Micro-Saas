<template>
  <div class="bg-background min-h-screen pb-24 md:pb-0">
    <AppHeader cliente-nome="Hoteis Hilton S/A" />
    <AppSidebar />

    <main class="flex-1 md:ml-64 px-4 py-6 md:px-margin-desktop pt-24 overflow-x-hidden">

      <!-- Welcome -->
      <header class="mb-gutter">
        <h2 class="font-headline-lg text-headline-lg text-primary mb-2">Bem-vindo ao Portal de Suprimentos</h2>
        <p class="font-body-md text-on-surface-variant">Confira o status das suas entregas e gerencie sua conta corporativa.</p>
      </header>

      <!-- Bento grid principal -->
      <div class="grid grid-cols-12 gap-gutter mb-gutter">

        <!-- Próxima entrega -->
        <div class="col-span-12 lg:col-span-8 bento-card p-gutter rounded-xl relative overflow-hidden flex flex-col justify-between min-h-[300px]">
          <div class="absolute top-0 right-0 w-1/2 h-full opacity-10 pointer-events-none flex items-center justify-end pr-8">
            <span class="material-symbols-outlined text-primary" style="font-size:180px;">local_shipping</span>
          </div>
          <div>
            <div class="flex items-center gap-2 text-secondary mb-4">
              <span class="material-symbols-outlined">schedule</span>
              <span class="font-label-lg uppercase tracking-widest">Próxima Entrega</span>
            </div>
            <h3 class="font-display-lg text-display-lg text-primary mb-2">Amanhã, às 06:30</h3>
            <p class="font-body-lg text-on-surface-variant max-w-md">
              Sua remessa programada de Pães Artesanais e Croissants está em fase final de fermentação e será despachada conforme o cronograma.
            </p>
          </div>
          <div class="flex flex-wrap gap-8 mt-6">
            <div v-for="stat in stats" :key="stat.label" class="flex flex-col gap-1 border-l-2 border-secondary pl-4">
              <span class="font-label-sm text-outline">{{ stat.label }}</span>
              <span class="font-body-md font-bold" :class="stat.color || 'text-on-surface'">{{ stat.valor }}</span>
            </div>
          </div>
        </div>

        <!-- Último pedido -->
        <div class="col-span-12 lg:col-span-4 bento-card p-gutter rounded-xl flex flex-col">
          <div class="flex justify-between items-start mb-6">
            <h4 class="font-headline-md text-primary">Último Pedido</h4>
            <span class="px-3 py-1 bg-primary-container text-on-primary-container text-[10px] font-bold rounded-full uppercase tracking-tighter">Concluído</span>
          </div>
          <div class="space-y-4 mb-6">
            <div class="flex justify-between border-b border-outline-variant/30 pb-2">
              <span class="font-body-md text-on-surface-variant">Pedido #EF-9921</span>
              <span class="font-body-md font-bold text-primary">R$ 2.450,00</span>
            </div>
            <div class="flex flex-col gap-1">
              <p class="font-label-sm text-outline">Conteúdo Principal</p>
              <p class="font-body-md">Mix de Pães Baguette (200un), Mini Brioche (500un)</p>
            </div>
          </div>
          <RouterLink to="/catalogo" class="mt-auto w-full py-4 border border-secondary text-secondary font-label-lg uppercase tracking-widest hover:bg-secondary/10 transition-colors rounded-lg text-center block">
            Repetir Pedido
          </RouterLink>
        </div>

        <!-- Atalhos rápidos -->
        <div class="col-span-12 grid grid-cols-2 md:grid-cols-4 gap-gutter">
          <RouterLink
            v-for="shortcut in shortcuts" :key="shortcut.label"
            :to="shortcut.to"
            class="bento-card p-6 rounded-xl flex flex-col items-center justify-center gap-3 text-center group"
          >
            <div class="w-12 h-12 rounded-full bg-surface-container flex items-center justify-center text-primary group-hover:bg-primary group-hover:text-white transition-all">
              <span class="material-symbols-outlined">{{ shortcut.icon }}</span>
            </div>
            <span class="font-label-lg text-primary uppercase tracking-wider text-sm">{{ shortcut.label }}</span>
          </RouterLink>
        </div>
      </div>

      <!-- Destaques da produção -->
      <section class="mb-gutter">
        <div class="flex justify-between items-end mb-8">
          <div>
            <h2 class="font-headline-lg text-headline-lg text-primary">Destaques da Produção</h2>
            <p class="font-body-md text-on-surface-variant">Lançamentos artesanais exclusivos para parceiros B2B.</p>
          </div>
          <RouterLink to="/catalogo" class="text-secondary font-label-lg underline underline-offset-8 uppercase tracking-widest hover:text-primary transition-colors">
            Ver Catálogo Completo
          </RouterLink>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-gutter">
          <div v-for="produto in destaques" :key="produto.badge"
            class="group relative h-[500px] overflow-hidden rounded-xl bg-primary"
          >
            <img
              :src="produto.img"
              :alt="produto.nome"
              class="w-full h-full object-cover opacity-80 group-hover:scale-105 transition-transform duration-700"
            />
            <div class="absolute inset-0 bg-gradient-to-t from-primary via-transparent to-transparent"></div>
            <div class="absolute bottom-0 left-0 p-gutter text-white">
              <span class="px-3 py-1 bg-secondary text-on-secondary text-[10px] font-bold rounded-full uppercase tracking-tighter mb-4 inline-block">{{ produto.badge }}</span>
              <h3 class="font-headline-lg text-headline-lg mb-2">{{ produto.nome }}</h3>
              <p class="font-body-md opacity-90 max-w-sm mb-6">{{ produto.descricao }}</p>
              <button class="bg-white text-primary px-8 py-3 rounded font-label-lg uppercase tracking-widest hover:bg-secondary-fixed transition-colors">
                {{ produto.cta }}
              </button>
            </div>
          </div>
        </div>
      </section>

      <!-- Footer institucional -->
      <footer class="mt-gutter pt-gutter border-t border-outline-variant/30 text-primary">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-gutter py-12">
          <div v-for="valor in valores" :key="valor.titulo" class="flex flex-col gap-4">
            <div class="flex items-center gap-2">
              <span class="material-symbols-outlined text-secondary">{{ valor.icon }}</span>
              <h4 class="font-headline-md">{{ valor.titulo }}</h4>
            </div>
            <p class="font-body-md text-on-surface-variant leading-relaxed">{{ valor.texto }}</p>
          </div>
        </div>
        <div class="flex flex-col md:flex-row justify-between items-center py-8 border-t border-outline-variant/10 text-on-surface-variant text-sm">
          <p>© 2024 Panificadora Efraim - Gestão B2B. Todos os direitos reservados.</p>
          <div class="flex gap-8 mt-4 md:mt-0">
            <a href="#" class="hover:text-primary underline">Termos de Serviço</a>
            <a href="#" class="hover:text-primary underline">Privacidade</a>
          </div>
        </div>
      </footer>
    </main>

    <AppBottomNav />
  </div>
</template>

<script setup>
import { RouterLink } from 'vue-router'
import AppHeader from '../components/AppHeader.vue'
import AppSidebar from '../components/AppSidebar.vue'
import AppBottomNav from '../components/AppBottomNav.vue'

const stats = [
  { label: 'Items',  valor: '420 Unidades' },
  { label: 'Status', valor: 'Em Produção', color: 'text-primary' },
  { label: 'Carga',  valor: 'Caminhão #04' },
]

const shortcuts = [
  { to: '/catalogo',   icon: 'add_shopping_cart',        label: 'Novo Pedido' },
  { to: '/financeiro', icon: 'description',              label: 'Notas Fiscais' },
  { to: '/catalogo',   icon: 'inventory_2',              label: 'Meus Produtos' },
  { to: '/',           icon: 'support_agent',            label: 'Ouvidoria' },
]

const destaques = [
  {
    badge: 'Best-Seller B2B',
    nome: 'Levain de Longa Fermentação',
    descricao: 'Massa madre de 30 anos, hidratação de 80%. O pão perfeito para o buffet de café da manhã premium.',
    cta: 'Solicitar Amostra',
    img: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBlwvcAhNLoyTtcTrGkmpGg_Sl9YHc7qydASr_dh1Z9uPCwuKgboRweQfcsSHcgDxn4RRR8_a35DVEtkrhoGeTP7skyPABgYR5Q05TqIAUbH5-nnOWskVxpNaKkjPdIMcHeNyumnAZMrFPEYcRLdydo86kCifrNDatHlqaUDCypRNpGpV5QIhyd4eoJxnqj9YmX1ki0voVHDrOiWeL0t8si4UZZ-gFqcJMkA0XnJzx9H__eFnJ6L62xWXTAGq-ain3h7CG62-rTjf64',
  },
  {
    badge: 'Lançamento',
    nome: 'Linha Viennoiserie Paris',
    descricao: 'Manteiga AOP e técnicas francesas tradicionais. Croissants que derretem na boca, ideais para hotelaria.',
    cta: 'Solicitar Tabela',
    img: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBayAVHfBiIAeZcpnxW-4cLbVTuP2Q-RuHlhgj75DaYR_fSI8zEe9lFBKhbn9RZiEDXiUy1ygyorKKsHMdfl3alSC8_QE95s7dS58ajI-GCavPaqLd9JxIxTosCtT_YolLQcriu43iINT0KF9rpWFv2OdHRMLxcti8w5mPkMJGC8RZL0qRxYk1VBnebdzzFS01d7PTizj0jANQisGYpxId2YTWN5dcNoaumsEm3CwoVlKaTbVmw8fEwU-SyraAVLb5gAFh0cnSz0iQU',
  },
]

const valores = [
  {
    icon: 'verified',
    titulo: 'Confiança',
    texto: 'Há mais de 3 décadas sendo o braço direito de grandes redes hoteleiras e hospitais. Pontualidade e segurança alimentar são nossas premissas inegociáveis.',
  },
  {
    icon: 'history_edu',
    titulo: 'Tradição',
    texto: 'Respeitamos o tempo do trigo. Nossa produção industrial preserva o toque artesanal, utilizando processos de fermentação natural que garantem sabor e saúde.',
  },
  {
    icon: 'eco',
    titulo: 'Qualidade Natural',
    texto: 'Ingredientes selecionados da fonte. Trabalhamos com produtores locais para garantir o frescor que o seu cliente final exige e merece.',
  },
]
</script>
