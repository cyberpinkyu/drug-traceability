<template>
  <div class="page">
    <el-card>
      <template #header>
        <div class="head"><span>生产批次</span><el-button type="primary" @click="visible=true">新增批次</el-button></div>
      </template>
      <el-table :data="rows">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="batchNumber" label="批次号" />
        <el-table-column prop="drugId" label="药品ID" />
        <el-table-column prop="productionQuantity" label="产量" />
        <el-table-column prop="producerId" label="生产方" />
      </el-table>
    </el-card>
    <el-dialog v-model="visible" title="新增生产批次" width="520px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="批次号"><el-input v-model="form.batchNumber" /></el-form-item>
        <el-form-item label="药品ID"><el-input v-model.number="form.drugId" /></el-form-item>
        <el-form-item label="产量"><el-input v-model.number="form.productionQuantity" /></el-form-item>
        <el-form-item label="生产方"><el-input v-model.number="form.producerId" /></el-form-item>
      </el-form>
      <template #footer><el-button @click="visible=false">取消</el-button><el-button type="primary" @click="submit">确定</el-button></template>
    </el-dialog>
  </div>
</template>
<script>
import api from '@/api/client'
export default {name:'ProductionBatch',data(){return{rows:[],visible:false,form:{batchNumber:'',drugId:null,productionQuantity:1,producerId:null}}},mounted(){this.load()},methods:{load(){api.get('/api/trace/batch').then(r=>{this.rows=r.data.data||[]})},submit(){api.post('/api/trace/batch',this.form).then(()=>{this.$message.success('提交成功');this.visible=false;this.load()})}}}
</script>
<style scoped>.page{padding:20px}.head{display:flex;justify-content:space-between;align-items:center}</style>
