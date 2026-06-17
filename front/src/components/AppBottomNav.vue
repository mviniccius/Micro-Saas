<template>
  <nav class="md:hidden fixed bottom-0 left-0 w-full flex justify-around items-center py-2 px-2 bg-surface-container border-t border-outline-variant/20 z-50">
    <RouterLink
      v-for="item in navItems" :key="item.to"
      :to="item.to"
      class="flex flex-col items-center justify-center text-on-surface-variant p-2 transition-transform active:scale-90"
      active-class="bg-secondary-container text-on-secondary-container rounded-xl"
    >
      <span class="material-symbols-outlined">{{ item.icon }}</span>
      <span class="font-label-sm text-label-sm">{{ item.label }}</span>
    </RouterLink>
  </nav>
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
