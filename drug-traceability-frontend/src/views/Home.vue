<template>
  <div class="home-container">
    <el-aside width="220px" class="sidebar">
      <div class="logo"><h3>药品追溯系统</h3></div>
      <el-menu :default-active="$route.path" class="el-menu-vertical-demo" router>
        <el-sub-menu index="1">
          <template #title><el-icon><User /></el-icon><span>用户管理</span></template>
          <el-menu-item index="/home/user">用户列表</el-menu-item>
          <el-menu-item index="/home/role">角色管理</el-menu-item>
        </el-sub-menu>

        <el-sub-menu index="2">
          <template #title><el-icon><Goods /></el-icon><span>药品管理</span></template>
          <el-menu-item index="/home/drug">药品列表</el-menu-item>
        </el-sub-menu>

        <el-sub-menu index="3">
          <template #title><el-icon><DataAnalysis /></el-icon><span>追溯管理</span></template>
          <el-menu-item index="/home/production">生产批次</el-menu-item>
          <el-menu-item index="/home/procurement">采购记录</el-menu-item>
          <el-menu-item index="/home/sale">销售记录</el-menu-item>
          <el-menu-item index="/home/inventory">库存管理</el-menu-item>
        </el-sub-menu>

        <el-sub-menu index="4">
          <template #title><el-icon><Monitor /></el-icon><span>监管中心</span></template>
          <el-menu-item index="/home/enforcement">监管任务中心</el-menu-item>
          <el-menu-item index="/home/stats">统计分析</el-menu-item>
          <el-menu-item index="/home/trace-graph">追溯图谱</el-menu-item>
          <el-menu-item index="/home/report-center">报表中心</el-menu-item>
          <el-menu-item index="/home/message-center">消息工单</el-menu-item>
          <el-menu-item index="/home/scan-enhance">扫码增强</el-menu-item>
          <el-menu-item index="/home/data-exchange">数据导入导出</el-menu-item>
        </el-sub-menu>

        <el-menu-item index="/home/ai">
          <el-icon><ChatLineSquare /></el-icon><span>AI助手</span>
        </el-menu-item>
      </el-menu>
    </el-aside>

    <el-container class="main-content">
      <el-header height="60px" class="header">
        <div class="header-left"></div>
        <div class="header-right">
          <span>{{ user?.name }}</span>
          <el-button type="text" @click="logout">
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
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { User, Goods, DataAnalysis, Monitor, ChatLineSquare, SwitchButton } from '@element-plus/icons-vue'

const router = useRouter()
const user = ref(null)

const logout = () => {
  localStorage.removeItem('user')
  localStorage.removeItem('token')
  router.push('/login')
}

onMounted(() => {
  const userStr = localStorage.getItem('user')
  if (userStr) {
    user.value = JSON.parse(userStr)
  } else {
    router.push('/login')
  }
})
</script>

<style scoped>
.home-container { display: flex; height: 100vh; overflow: hidden; }
.sidebar { background: #f0f9ff; color: #304156; display: flex; flex-direction: column; }
.logo { padding: 16px; text-align: center; border-bottom: 1px solid #409eff; background: #304156; height: 60px; display: flex; align-items: center; justify-content: center; }
.logo h3 { margin: 0; color: #fff; font-size: 16px; }
.el-menu-vertical-demo { border-right: none; flex: 1; overflow-y: auto; }
.main-content { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
.header { background: #fff; border-bottom: 1px solid #e4e7ed; display: flex; justify-content: space-between; align-items: center; padding: 0 20px; }
.header-right { display: flex; align-items: center; gap: 16px; }
.el-main { flex: 1; padding: 20px; overflow-y: auto; background: #f5f7fa; }
</style>
