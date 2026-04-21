<template>
  <div class="page">
    <el-card>
      <template #header>
        <div class="head">
          <span>销售记录</span>
          <el-button type="primary" @click="openAdd">新增记录</el-button>
        </div>
      </template>
      <el-table :data="rows">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="batchId" label="批次ID" />
        <el-table-column prop="sellerId" label="销售方" />
        <el-table-column prop="buyerId" label="购买方" />
        <el-table-column prop="quantity" label="数量" />
      </el-table>
    </el-card>

    <el-dialog v-model="visible" title="新增销售记录" width="520px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="批次ID"><el-input v-model.number="form.batchId" /></el-form-item>
        <el-form-item label="销售方"><el-input v-model.number="form.sellerId" /></el-form-item>
        <el-form-item label="购买方"><el-input v-model.number="form.buyerId" /></el-form-item>
        <el-form-item label="数量"><el-input v-model.number="form.quantity" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="visible=false">取消</el-button>
        <el-button type="primary" @click="submit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import api from '@/api/client'
export default {
  name: 'SaleRecord',
  data() {
    return { rows: [], visible: false, form: { batchId: null, sellerId: null, buyerId: null, quantity: 1 } }
  },
  mounted() { this.load() },
  methods: {
    load() { api.get('/api/trace/sale').then(r => { this.rows = r.data.data || [] }) },
    openAdd() { this.visible = true },
    submit() {
      api.post('/api/trace/sale', this.form).then(() => {
        this.$message.success('提交成功')
        this.visible = false
        this.load()
      })
    }
  }
}
</script>

<style scoped>
.page{padding:20px}.head{display:flex;justify-content:space-between;align-items:center}
</style>
