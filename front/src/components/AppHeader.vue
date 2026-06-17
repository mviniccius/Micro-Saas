<template>
  <header class="fixed top-0 w-full z-50 bg-background border-b border-outline-variant/30 flex justify-between items-center px-margin-desktop h-16">
    <div class="flex items-center gap-3">
      <span class="material-symbols-outlined text-primary text-headline-md">bakery_dining</span>
      <h1 class="font-headline-md text-headline-md text-primary">Panificadora Efraim</h1>
    </div>
    <div class="flex items-center gap-6">
      <div class="hidden md:flex gap-4 items-center">
        <span class="font-label-lg text-label-lg text-on-surface-variant">Unidade: Matriz São Paulo</span>
        <div class="h-4 w-px bg-outline-variant/50"></div>
        <span class="font-label-lg text-label-lg text-primary font-bold">{{ clienteNome }}</span>
      </div>
      <button class="p-2 hover:bg-primary-container/10 rounded-full transition-colors">
        <span class="material-symbols-outlined text-on-surface-variant">notifications</span>
      </button>
      <div class="w-10 h-10 rounded-full bg-primary flex items-center justify-center text-white font-bold text-sm">
        {{ inicial }}
      </div>
    </div>
  </header>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  clienteNome: { type: String, default: 'Cliente Efraim' }
})

const inicial = computed(() => props.clienteNome.charAt(0).toUpperCase())
</script>
