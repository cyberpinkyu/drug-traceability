<template>
  <div class="drug-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>药品管理</span>
          <el-button type="primary" @click="openAdd">新增药品</el-button>
        </div>
      </template>

      <el-table :data="drugs" style="width: 100%">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="drugCode" label="药品编码" />
        <el-table-column prop="name" label="药品名称" />
        <el-table-column prop="manufacturer" label="生产企业" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-switch
              :model-value="scope.row.status"
              :active-value="1"
              :inactive-value="0"
              @change="(v) => changeStatus(scope.row, v)"
            />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180">
          <template #default="scope">
            <el-button size="small" type="primary" @click="openEdit(scope.row)">编辑</el-button>
            <el-button size="small" type="danger" @click="remove(scope.row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="mode === 'add' ? '新增药品' : '编辑药品'" width="560px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="药品编码" prop="drugCode">
          <el-input v-model="form.drugCode" />
        </el-form-item>
        <el-form-item label="药品名称" prop="name">
          <el-input v-model="form.name" />
        </el-form-item>
        <el-form-item label="生产企业" prop="manufacturer">
          <el-input v-model="form.manufacturer" />
        </el-form-item>
        <el-form-item label="规格">
          <el-input v-model="form.specification" />
        </el-form-item>
        <el-form-item label="分类">
          <el-input v-model="form.category" />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="form.status" :active-value="1" :inactive-value="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import api from '@/api/client'

export default {
  name: 'DrugList',
  data() {
    return {
      drugs: [],
      dialogVisible: false,
      mode: 'add',
      form: {
        id: '',
        drugCode: '',
        name: '',
        manufacturer: '',
        specification: '',
        category: '',
        status: 1
      },
      rules: {
        drugCode: [{ required: true, message: '请输入药品编码', trigger: 'blur' }],
        name: [{ required: true, message: '请输入药品名称', trigger: 'blur' }],
        manufacturer: [{ required: true, message: '请输入生产企业', trigger: 'blur' }]
      }
    }
  },
  mounted() {
    this.fetchList()
  },
  methods: {
    fetchList() {
      api.get('/api/drug/info').then((res) => {
        this.drugs = res.data.data || []
      })
    },
    openAdd() {
      this.mode = 'add'
      this.form = { id: '', drugCode: '', name: '', manufacturer: '', specification: '', category: '', status: 1 }
      this.dialogVisible = true
    },
    openEdit(row) {
      this.mode = 'edit'
      this.form = { ...row }
      this.dialogVisible = true
    },
    submit() {
      this.$refs.formRef.validate((valid) => {
        if (!valid) return
        const req = this.mode === 'add'
          ? api.post('/api/drug/info', this.form)
          : api.put(`/api/drug/info/${this.form.id}`, this.form)
        req.then(() => {
          this.$message.success(this.mode === 'add' ? '新增成功' : '更新成功')
          this.dialogVisible = false
          this.fetchList()
        })
      })
    },
    remove(id) {
      this.$confirm('确定删除该药品吗？', '提示', { type: 'warning' })
        .then(() => api.delete(`/api/drug/info/${id}`))
        .then(() => {
          this.$message.success('删除成功')
          this.fetchList()
        })
    },
    changeStatus(row, status) {
      api.put(`/api/drug/info/${row.id}/status`, { status }).then(() => this.fetchList())
    }
  }
}
</script>

<style scoped>
.drug-list { padding: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
