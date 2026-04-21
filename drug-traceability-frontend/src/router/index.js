import { createRouter, createWebHistory } from 'vue-router'
import api from '@/api/client'
import { ROUTE_ACCESS, getHomeLandingPath, hasRouteAccess } from '@/permission/routeAccess'

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
    meta: { requiresAuth: true },
    children: [
      {
        path: 'user',
        name: 'User',
        component: () => import('../views/user/UserList.vue'),
        meta: { requiresAuth: true, roles: ROUTE_ACCESS['/home/user'] }
      },
      {
        path: 'role',
        name: 'Role',
        component: () => import('../views/user/RoleList.vue'),
        meta: { requiresAuth: true, roles: ROUTE_ACCESS['/home/role'] }
      },
      {
        path: 'drug',
        name: 'Drug',
        component: () => import('../views/drug/DrugList.vue'),
        meta: { requiresAuth: true, roles: ROUTE_ACCESS['/home/drug'] }
      },
      {
        path: 'production',
        name: 'Production',
        component: () => import('../views/trace/ProductionBatch.vue'),
        meta: { requiresAuth: true, roles: ROUTE_ACCESS['/home/production'] }
      },
      {
        path: 'procurement',
        name: 'Procurement',
        component: () => import('../views/trace/ProcurementRecord.vue'),
        meta: { requiresAuth: true, roles: ROUTE_ACCESS['/home/procurement'] }
      },
      {
        path: 'sale',
        name: 'Sale',
        component: () => import('../views/trace/SaleRecord.vue'),
        meta: { requiresAuth: true, roles: ROUTE_ACCESS['/home/sale'] }
      },
      {
        path: 'inventory',
        name: 'Inventory',
        component: () => import('../views/trace/Inventory.vue'),
        meta: { requiresAuth: true, roles: ROUTE_ACCESS['/home/inventory'] }
      },
      {
        path: 'enforcement',
        name: 'Enforcement',
        component: () => import('../views/regulatory/EnforcementList.vue'),
        meta: { requiresAuth: true, roles: ROUTE_ACCESS['/home/enforcement'] }
      },
      {
        path: 'stats',
        name: 'Stats',
        component: () => import('../views/regulatory/Stats.vue'),
        meta: { requiresAuth: true, roles: ROUTE_ACCESS['/home/stats'] }
      },
      {
        path: 'trace-graph',
        name: 'TraceGraph',
        component: () => import('../views/regulatory/TraceGraph.vue'),
        meta: { requiresAuth: true, roles: ROUTE_ACCESS['/home/trace-graph'] }
      },
      {
        path: 'report-center',
        name: 'ReportCenter',
        component: () => import('../views/regulatory/ReportCenter.vue'),
        meta: { requiresAuth: true, roles: ROUTE_ACCESS['/home/report-center'] }
      },
      {
        path: 'message-center',
        name: 'MessageCenter',
        component: () => import('../views/regulatory/MessageCenter.vue'),
        meta: { requiresAuth: true, roles: ROUTE_ACCESS['/home/message-center'] }
      },
      {
        path: 'scan-enhance',
        name: 'ScanEnhance',
        component: () => import('../views/regulatory/ScanEnhance.vue'),
        meta: { requiresAuth: true, roles: ROUTE_ACCESS['/home/scan-enhance'] }
      },
      {
        path: 'data-exchange',
        name: 'DataExchange',
        component: () => import('../views/regulatory/DataExchange.vue'),
        meta: { requiresAuth: true, roles: ROUTE_ACCESS['/home/data-exchange'] }
      },
      {
        path: 'ai',
        name: 'AI',
        component: () => import('../views/ai/AIChat.vue'),
        meta: { requiresAuth: true, roles: ROUTE_ACCESS['/home/ai'] }
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

function clearAuth() {
  localStorage.removeItem('token')
  localStorage.removeItem('refreshToken')
  localStorage.removeItem('user')
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
      clearAuth()
      next('/login')
      return
    }

    const roleCode = user.roleCode
    if (to.path === '/home') {
      next(getHomeLandingPath(roleCode))
      return
    }

    if (!hasRouteAccess(roleCode, to.path)) {
      next(getHomeLandingPath(roleCode))
      return
    }

    next()
  } catch (_) {
    clearAuth()
    next('/login')
  }
})

export default router
