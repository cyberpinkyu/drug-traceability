<template>
  <div class="page">
    <el-card>
      <template #header>
        <div class="head"><span>采购记录</span><el-button type="primary" @click="visible=true">新增记录</el-button></div>
      </template>
      <el-table :data="rows">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="batchId" label="批次ID" />
        <el-table-column prop="supplierId" label="供应方" />
        <el-table-column prop="buyerId" label="采购方" />
        <el-table-column prop="quantity" label="数量" />
      </el-table>
    </el-card>
    <el-dialog v-model="visible" title="新增采购记录" width="520px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="批次ID"><el-input v-model.number="form.batchId" /></el-form-item>
        <el-form-item label="供应方"><el-input v-model.number="form.supplierId" /></el-form-item>
        <el-form-item label="采购方"><el-input v-model.number="form.buyerId" /></el-form-item>
        <el-form-item label="数量"><el-input v-model.number="form.quantity" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="visible=false">取消</el-button><el-button type="primary" @click="submit">确定</el-button></template>
    </el-dialog>
  </div>
</template>
<script>
import api from '@/api/client'
export default {name:'ProcurementRecord',data(){return{rows:[],visible:false,form:{batchId:null,supplierId:null,buyerId:null,quantity:1}}},mounted(){this.load()},methods:{load(){api.get('/api/trace/procurement').then(r=>{this.rows=r.data.data||[]})},submit(){api.post('/api/trace/procurement',this.form).then(()=>{this.$message.success('提交成功');this.visible=false;this.load()})}}}
</script>
<style scoped>.page{padding:20px}.head{display:flex;justify-content:space-between;align-items:center}</style>
