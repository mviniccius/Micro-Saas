<template>
  <div class="min-h-screen bg-background flex items-center justify-center px-4">
    <div class="w-full max-w-md">
      <div class="text-center mb-10">
        <span class="material-symbols-outlined text-primary" style="font-size:48px;">bakery_dining</span>
        <h1 class="font-headline-lg text-headline-lg text-primary mt-2">Panificadora Efraim</h1>
        <p class="font-label-sm text-on-surface-variant mt-1 uppercase tracking-widest">Portal B2B</p>
      </div>
      <div class="bg-white rounded-xl border border-outline-variant/20 p-8">
        <h2 class="font-headline-md text-headline-md text-primary mb-6">Bem-vindo de volta</h2>
        <div class="flex flex-col gap-4">
          <input
            v-model="email"
            type="email"
            placeholder="E-mail corporativo"
            class="w-full border border-outline-variant/50 rounded-lg px-4 py-3 font-body-md focus:outline-none focus:border-secondary transition-colors"
          />
          <input
            v-model="senha"
            type="password"
            placeholder="Senha"
            class="w-full border border-outline-variant/50 rounded-lg px-4 py-3 font-body-md focus:outline-none focus:border-secondary transition-colors"
          />
          <button
            @click="entrar"
            class="w-full bg-primary text-white py-4 rounded-lg font-label-lg uppercase tracking-widest hover:bg-primary-container transition-colors mt-2"
          >
            Entrar
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const email = ref('')
const senha = ref('')
const router = useRouter()

function entrar() {
  router.push('/')
}
</script>
