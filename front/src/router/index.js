import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'

const routes = [
  { path: '/',          component: HomeView },
  { path: '/catalogo',  component: () => import('../views/CatalogoView.vue') },
  { path: '/pedidos',   component: () => import('../views/PedidosView.vue') },
  { path: '/financeiro',component: () => import('../views/FinanceiroView.vue') },
  { path: '/login',     component: () => import('../views/LoginView.vue') },
]

export default createRouter({
  history: createWebHistory(),
  routes,
})
