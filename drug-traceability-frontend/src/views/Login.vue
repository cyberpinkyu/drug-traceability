<template>
  <div class="login-container">
    <div class="decor decor-a"></div>
    <div class="decor decor-b"></div>
    <div class="login-form panel-card">
      <h2>药品全流程追溯监管系统</h2>
      <p class="sub">智能追溯 · 风险预警 · 监管闭环</p>
      <el-tabs v-model="activeTab">
        <el-tab-pane label="登录" name="login">
          <el-form ref="loginFormRef" :model="loginForm" :rules="loginRules" label-width="80px">
            <el-form-item label="用户名" prop="username">
              <el-input v-model="loginForm.username" placeholder="请输入用户名" />
            </el-form-item>
            <el-form-item label="密码" prop="password">
              <el-input v-model="loginForm.password" type="password" placeholder="请输入密码" show-password />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" class="full" @click="login">登录</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <el-tab-pane label="注册" name="register">
          <el-form ref="registerFormRef" :model="registerForm" :rules="registerRules" label-width="80px">
            <el-form-item label="用户名" prop="username">
              <el-input v-model="registerForm.username" placeholder="请输入用户名" />
            </el-form-item>
            <el-form-item label="姓名" prop="name">
              <el-input v-model="registerForm.name" placeholder="请输入姓名" />
            </el-form-item>
            <el-form-item label="密码" prop="password">
              <el-input v-model="registerForm.password" type="password" placeholder="请输入密码" show-password />
            </el-form-item>
            <el-form-item label="邮箱" prop="email">
              <el-input v-model="registerForm.email" placeholder="请输入邮箱" />
            </el-form-item>
            <el-form-item label="电话" prop="phone">
              <el-input v-model="registerForm.phone" placeholder="请输入电话" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" class="full" @click="register">注册</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>
      </el-tabs>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import api from '@/api/client'

const router = useRouter()
const activeTab = ref('login')
const loginFormRef = ref(null)
const registerFormRef = ref(null)

const loginForm = reactive({
  username: '',
  password: ''
})

const registerForm = reactive({
  username: '',
  name: '',
  password: '',
  email: '',
  phone: ''
})

const loginRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const registerRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '邮箱格式不正确', trigger: 'blur' }
  ],
  phone: [{ required: true, message: '请输入电话', trigger: 'blur' }]
}

const login = async () => {
  if (!loginFormRef.value) return
  await loginFormRef.value.validate(async (valid) => {
    if (!valid) return
    try {
      const response = await api.post('/api/auth/login', loginForm)
      if (response.data.code === 200) {
        localStorage.setItem('user', JSON.stringify(response.data.data))
        localStorage.setItem('token', response.data.data.token)
        localStorage.setItem('refreshToken', response.data.data.refreshToken || '')
        router.push('/home')
      } else {
        ElMessage.error(response.data.message)
      }
    } catch (_) {
      ElMessage.error('登录失败，请稍后重试')
    }
  })
}

const register = async () => {
  if (!registerFormRef.value) return
  await registerFormRef.value.validate(async (valid) => {
    if (!valid) return
    try {
      const response = await api.post('/api/auth/register', registerForm)
      if (response.data.code === 200) {
        ElMessage.success('注册成功，请登录')
        activeTab.value = 'login'
      } else {
        ElMessage.error(response.data.message)
      }
    } catch (_) {
      ElMessage.error('注册失败，请稍后重试')
    }
  })
}
</script>

<style scoped>
.login-container {
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  padding: 20px;
  overflow: hidden;
}

.decor {
  position: absolute;
  border-radius: 999px;
  filter: blur(4px);
}

.decor-a {
  width: 380px;
  height: 380px;
  right: -90px;
  top: -100px;
  background: rgba(37, 99, 235, 0.2);
}

.decor-b {
  width: 320px;
  height: 320px;
  left: -90px;
  bottom: -70px;
  background: rgba(15, 118, 110, 0.2);
}

.login-form {
  position: relative;
  z-index: 1;
  width: 430px;
  padding: 28px;
}

.login-form h2 {
  text-align: center;
  margin: 0 0 8px;
  color: var(--text-main);
}

.sub {
  margin: 0 0 20px;
  text-align: center;
  color: var(--text-secondary);
  font-size: 13px;
}

.full {
  width: 100%;
}
</style>
