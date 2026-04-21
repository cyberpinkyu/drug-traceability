<template>
  <div class="page">
    <el-card>
      <template #header><span>库存</span></template>
      <el-table :data="rows">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="batchId" label="批次ID" />
        <el-table-column prop="organizationId" label="机构ID" />
        <el-table-column prop="quantity" label="库存数量" />
        <el-table-column prop="lastUpdateDate" label="最后更新时间" />
      </el-table>
    </el-card>
  </div>
</template>
<script>
import api from '@/api/client'
export default {name:'Inventory',data(){return{rows:[]}},mounted(){api.get('/api/trace/inventory').then(r=>{this.rows=r.data.data||[]})}}
</script>
<style scoped>.page{padding:20px}</style>
