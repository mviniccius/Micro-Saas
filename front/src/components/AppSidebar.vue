<template>
  <aside class="hidden md:flex flex-col w-64 bg-surface-container border-r border-outline-variant/20 fixed h-full z-40 overflow-y-auto top-16">
    <nav class="flex flex-col gap-1 p-4">
      <RouterLink
        v-for="item in navItems" :key="item.to"
        :to="item.to"
        class="flex items-center gap-3 px-4 py-3 rounded-xl text-on-surface-variant hover:bg-outline-variant/10 font-label-lg text-label-lg transition-colors"
        active-class="sidebar-active"
      >
        <span class="material-symbols-outlined">{{ item.icon }}</span>
        {{ item.label }}
      </RouterLink>

      <div class="my-4 border-t border-outline-variant/20"></div>

      <RouterLink to="/perfil"
        class="flex items-center gap-3 px-4 py-3 rounded-xl text-on-surface-variant hover:bg-outline-variant/10 font-label-lg text-label-lg transition-colors"
      >
        <span class="material-symbols-outlined">person</span>
        Perfil
      </RouterLink>
    </nav>

    <div class="mt-auto p-4 m-4 rounded-xl bg-primary-container text-on-primary-container">
      <p class="font-label-sm text-[11px] uppercase tracking-wider mb-2 opacity-80">Suporte Exclusivo</p>
      <p class="font-body-md text-sm font-semibold mb-3">Dúvidas com seu pedido corporativo?</p>
      <button class="w-full py-2 bg-secondary text-on-secondary rounded-lg font-label-lg text-xs uppercase tracking-widest hover:brightness-110 transition-all">
        Falar com Gerente
      </button>
    </div>
  </aside>
</template>

<script setup>
import { RouterLink } from 'vue-router'

const navItems = [
  { to: '/',           icon: 'home',                   label: 'Home' },
  { to: '/catalogo',   icon: 'menu_book',              label: 'Catálogo' },
  { to: '/pedidos',    icon: 'receipt_long',           label: 'Pedidos' },
  { to: '/financeiro', icon: 'account_balance_wallet', label: 'Financeiro' },
]
</script>
