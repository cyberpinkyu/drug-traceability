<template>
  <div class="user-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>用户管理</span>
          <el-button type="primary" @click="handleAdd">新增用户</el-button>
        </div>
      </template>

      <el-table :data="users" style="width: 100%">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" />
        <el-table-column prop="name" label="姓名" />
        <el-table-column prop="email" label="邮箱" />
        <el-table-column prop="phone" label="电话" />
        <el-table-column prop="roleId" label="角色ID" width="100" />
        <el-table-column label="状态" width="120">
          <template #default="scope">
            <el-switch
              :model-value="scope.row.status"
              :active-value="1"
              :inactive-value="0"
              @change="(v) => handleStatusChange(scope.row, v)"
            />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180">
          <template #default="scope">
            <el-button type="primary" size="small" @click="handleEdit(scope.row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(scope.row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="dialogType === 'add' ? '新增用户' : '编辑用户'" width="520px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="姓名" prop="name">
          <el-input v-model="form.name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item v-if="dialogType === 'add'" label="密码" prop="password">
          <el-input v-model="form.password" type="password" placeholder="请输入密码" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="form.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="电话" prop="phone">
          <el-input v-model="form.phone" placeholder="请输入电话" />
        </el-form-item>
        <el-form-item label="角色" prop="roleId">
          <el-select v-model="form.roleId" placeholder="请选择角色" style="width: 100%">
            <el-option v-for="role in roles" :key="role.id" :label="role.name" :value="role.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-switch v-model="form.status" :active-value="1" :inactive-value="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import api from '@/api/client'

export default {
  name: 'UserList',
  data() {
    return {
      users: [],
      roles: [],
      dialogVisible: false,
      dialogType: 'add',
      form: {
        id: '',
        username: '',
        name: '',
        password: '',
        email: '',
        phone: '',
        roleId: '',
        status: 1
      },
      rules: {
        username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
        name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
        password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
        roleId: [{ required: true, message: '请选择角色', trigger: 'change' }]
      }
    }
  },
  mounted() {
    this.getUsers()
    this.getRoles()
  },
  methods: {
    getUsers() {
      api.get('/api/auth/users').then((response) => {
        this.users = response.data.data || []
      })
    },
    getRoles() {
      api.get('/api/auth/roles').then((response) => {
        this.roles = response.data.data || []
      })
    },
    handleAdd() {
      this.dialogType = 'add'
      this.form = { id: '', username: '', name: '', password: '', email: '', phone: '', roleId: '', status: 1 }
      this.dialogVisible = true
    },
    handleEdit(row) {
      this.dialogType = 'edit'
      this.form = { ...row, password: '' }
      this.dialogVisible = true
    },
    handleSubmit() {
      this.$refs.formRef.validate((valid) => {
        if (!valid) return
        const req = this.dialogType === 'add'
          ? api.post('/api/auth/users', this.form)
          : api.put(`/api/auth/users/${this.form.id}`, this.form)
        req.then(() => {
          this.$message.success(this.dialogType === 'add' ? '新增成功' : '更新成功')
          this.dialogVisible = false
          this.getUsers()
        })
      })
    },
    handleDelete(id) {
      this.$confirm('确定删除该用户吗？', '提示', { type: 'warning' })
        .then(() => api.delete(`/api/auth/users/${id}`))
        .then(() => {
          this.$message.success('删除成功')
          this.getUsers()
        })
    },
    handleStatusChange(row, status) {
      api.put(`/api/auth/users/${row.id}/status`, { status })
        .then(() => {
          this.$message.success('状态更新成功')
          this.getUsers()
        })
    }
  }
}
</script>

<style scoped>
.user-list {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
