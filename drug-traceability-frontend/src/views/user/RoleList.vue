<template>
  <div class="role-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>角色管理</span>
          <el-button type="primary" @click="handleAdd">新增角色</el-button>
        </div>
      </template>

      <el-table :data="roles" style="width: 100%">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="角色名称" />
        <el-table-column prop="description" label="角色描述" />
        <el-table-column prop="createTime" label="创建时间" />
      </el-table>
    </el-card>

    <el-dialog
      v-model="dialogVisible"
      :title="dialogType === 'add' ? '新增角色' : '编辑角色'"
      width="500px"
    >
      <el-form ref="formRef" :model="form" :rules="rules">
        <el-form-item label="角色名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入角色名称" />
        </el-form-item>
        <el-form-item label="角色描述" prop="description">
          <el-input v-model="form.description" type="textarea" placeholder="请输入角色描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSubmit">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import api from '@/api/client'

export default {
  name: 'RoleList',
  data() {
    return {
      roles: [],
      dialogVisible: false,
      dialogType: 'add',
      form: {
        id: '',
        name: '',
        description: ''
      },
      rules: {
        name: [{ required: true, message: '请输入角色名称', trigger: 'blur' }],
        description: [{ required: true, message: '请输入角色描述', trigger: 'blur' }]
      }
    }
  },
  mounted() {
    this.getRoles()
  },
  methods: {
    getRoles() {
      api.get('/api/auth/roles')
        .then((response) => {
          this.roles = response.data.data || []
        })
    },
    handleAdd() {
      this.dialogType = 'add'
      this.form = { id: '', name: '', description: '' }
      this.dialogVisible = true
    },
    handleSubmit() {
      this.$refs.formRef.validate((valid) => {
        if (!valid) return
        this.$message.success(this.dialogType === 'add' ? '新增成功' : '更新成功')
        this.dialogVisible = false
      })
    }
  }
}
</script>

<style scoped>
.role-list {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
