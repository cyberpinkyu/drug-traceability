<template>
  <div class="home-container">
    <el-aside width="230px" class="sidebar panel-card">
      <div class="logo"><h3>药品追溯系统</h3></div>
      <el-menu :default-active="$route.path" class="el-menu-vertical-demo" router>
        <el-sub-menu
          v-for="section in visibleSections"
          :key="section.index"
          :index="section.index"
        >
          <template #title>
            <el-icon><component :is="section.icon" /></el-icon>
            <span>{{ section.title }}</span>
          </template>
          <el-menu-item
            v-for="item in section.items"
            :key="item.path"
            :index="item.path"
          >
            {{ item.label }}
          </el-menu-item>
        </el-sub-menu>

        <el-menu-item v-if="canAccess('/home/ai')" index="/home/ai">
          <el-icon><ChatLineSquare /></el-icon>
          <span>AI助手</span>
        </el-menu-item>
      </el-menu>
    </el-aside>

    <el-container class="main-content">
      <el-header height="64px" class="header panel-card">
        <div class="header-left">监管可视化控制台</div>
        <div class="header-right">
          <span class="user-pill">{{ user?.name || '-' }}</span>
          <el-button link @click="logout">
            <el-icon><SwitchButton /></el-icon>
            退出
          </el-button>
        </div>
      </el-header>
      <el-main>
        <router-view />
      </el-main>
    </el-container>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import { User, Goods, DataAnalysis, Monitor, ChatLineSquare, SwitchButton } from '@element-plus/icons-vue'
import { hasRouteAccess } from '@/permission/routeAccess'

const router = useRouter()
const user = ref(null)

const userRaw = localStorage.getItem('user')
if (userRaw) {
  user.value = JSON.parse(userRaw)
}

const roleCode = computed(() => user.value?.roleCode || '')
const canAccess = (path) => hasRouteAccess(roleCode.value, path)

const menuSections = [
  {
    index: '1',
    title: '用户管理',
    icon: User,
    items: [
      { path: '/home/user', label: '用户列表' },
      { path: '/home/role', label: '角色管理' }
    ]
  },
  {
    index: '2',
    title: '药品管理',
    icon: Goods,
    items: [
      { path: '/home/drug', label: '药品列表' }
    ]
  },
  {
    index: '3',
    title: '追溯管理',
    icon: DataAnalysis,
    items: [
      { path: '/home/production', label: '生产批次' },
      { path: '/home/procurement', label: '采购记录' },
      { path: '/home/sale', label: '销售记录' },
      { path: '/home/inventory', label: '库存管理' }
    ]
  },
  {
    index: '4',
    title: '监管中心',
    icon: Monitor,
    items: [
      { path: '/home/enforcement', label: '监管任务中心' },
      { path: '/home/stats', label: '统计分析' },
      { path: '/home/trace-graph', label: '追溯图谱' },
      { path: '/home/report-center', label: '报表中心' },
      { path: '/home/message-center', label: '消息工单' },
      { path: '/home/scan-enhance', label: '扫码增强' },
      { path: '/home/data-exchange', label: '数据导入导出' }
    ]
  }
]

const visibleSections = computed(() =>
  menuSections
    .map((section) => ({
      ...section,
      items: section.items.filter((item) => canAccess(item.path))
    }))
    .filter((section) => section.items.length > 0)
)

const logout = () => {
  localStorage.removeItem('user')
  localStorage.removeItem('token')
  localStorage.removeItem('refreshToken')
  router.push('/login')
}
</script>

<style scoped>
.home-container {
  display: flex;
  height: 100vh;
  overflow: hidden;
  padding: 12px;
  gap: 12px;
}

.sidebar {
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.logo {
  padding: 18px;
  text-align: center;
  border-bottom: 1px solid var(--border);
  background: linear-gradient(120deg, #0f766e, #2563eb);
}

.logo h3 {
  margin: 0;
  color: #fff;
  font-size: 16px;
  letter-spacing: 0.3px;
}

.el-menu-vertical-demo {
  border-right: none;
  flex: 1;
  overflow-y: auto;
}

.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  gap: 12px;
}

.header {
  border: 1px solid var(--border);
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
}

.header-left {
  color: var(--text-secondary);
  font-size: 13px;
  font-weight: 600;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 14px;
}

.user-pill {
  padding: 6px 10px;
  border-radius: 999px;
  background: var(--brand-soft);
  color: #1e3a8a;
  font-size: 12px;
  font-weight: 700;
}

.el-main {
  flex: 1;
  padding: 0;
  overflow-y: auto;
  background: transparent;
}
</style>
