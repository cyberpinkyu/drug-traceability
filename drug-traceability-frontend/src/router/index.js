import { createRouter, createWebHistory } from 'vue-router'
import api from '@/api/client'

const routes = [
  {
    path: '/',
    redirect: '/login'
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue')
  },
  {
    path: '/home',
    name: 'Home',
    component: () => import('../views/Home.vue'),
    redirect: '/home/stats',
    meta: { requiresAuth: true },
    children: [
      {
        path: 'user',
        name: 'User',
        component: () => import('../views/user/UserList.vue'),
        meta: { requiresAuth: true, roles: ['admin'] }
      },
      {
        path: 'role',
        name: 'Role',
        component: () => import('../views/user/RoleList.vue'),
        meta: { requiresAuth: true, roles: ['admin'] }
      },
      {
        path: 'drug',
        name: 'Drug',
        component: () => import('../views/drug/DrugList.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'production',
        name: 'Production',
        component: () => import('../views/trace/ProductionBatch.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'procurement',
        name: 'Procurement',
        component: () => import('../views/trace/ProcurementRecord.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'sale',
        name: 'Sale',
        component: () => import('../views/trace/SaleRecord.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'inventory',
        name: 'Inventory',
        component: () => import('../views/trace/Inventory.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'enforcement',
        name: 'Enforcement',
        component: () => import('../views/regulatory/EnforcementList.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'stats',
        name: 'Stats',
        component: () => import('../views/regulatory/Stats.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'trace-graph',
        name: 'TraceGraph',
        component: () => import('../views/regulatory/TraceGraph.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'report-center',
        name: 'ReportCenter',
        component: () => import('../views/regulatory/ReportCenter.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'message-center',
        name: 'MessageCenter',
        component: () => import('../views/regulatory/MessageCenter.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'scan-enhance',
        name: 'ScanEnhance',
        component: () => import('../views/regulatory/ScanEnhance.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'data-exchange',
        name: 'DataExchange',
        component: () => import('../views/regulatory/DataExchange.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'ai',
        name: 'AI',
        component: () => import('../views/ai/AIChat.vue'),
        meta: { requiresAuth: true }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

let cachedMe = null
let cachedAt = 0
const CACHE_MS = 60 * 1000

async function fetchCurrentUser(force = false) {
  const now = Date.now()
  if (!force && cachedMe && now - cachedAt < CACHE_MS) {
    return cachedMe
  }

  const response = await api.get('/api/auth/me')
  if (response?.data?.code !== 200 || !response?.data?.data) {
    return null
  }

  cachedMe = response.data.data
  cachedAt = now
  localStorage.setItem('user', JSON.stringify(cachedMe))
  return cachedMe
}

router.beforeEach(async (to, from, next) => {
  if (!to.meta.requiresAuth) {
    next()
    return
  }

  const token = localStorage.getItem('token')
  if (!token) {
    next('/login')
    return
  }

  try {
    const user = await fetchCurrentUser(false)
    if (!user) {
      localStorage.removeItem('token')
      localStorage.removeItem('refreshToken')
      localStorage.removeItem('user')
      next('/login')
      return
    }

    if (to.meta.roles && !to.meta.roles.includes(user.roleCode)) {
      next('/home')
      return
    }

    next()
  } catch (_) {
    localStorage.removeItem('token')
    localStorage.removeItem('refreshToken')
    localStorage.removeItem('user')
    next('/login')
  }
})

export default router