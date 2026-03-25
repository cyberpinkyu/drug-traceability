<template>
  <div class="page">
    <el-row :gutter="16">
      <el-col :span="8"><el-card><div class="k">流通统计</div><div class="v">{{ circulation }}</div></el-card></el-col>
      <el-col :span="8"><el-card><div class="k">库存统计</div><div class="v">{{ inventory }}</div></el-card></el-col>
      <el-col :span="8"><el-card><div class="k">风险统计</div><div class="v">{{ risk }}</div></el-card></el-col>
    </el-row>
  </div>
</template>
<script>
import api from '@/api/client'
export default {name:'Stats',data(){return{circulation:'-',inventory:'-',risk:'-'}},mounted(){api.get('/api/regulatory/stats/circulation',{params:{timeRange:'month',region:'all'}}).then(r=>{this.circulation=JSON.stringify(r.data.data)});api.get('/api/regulatory/stats/inventory').then(r=>{this.inventory=JSON.stringify(r.data.data)});api.get('/api/regulatory/stats/risk').then(r=>{this.risk=JSON.stringify(r.data.data)})}}
</script>
<style scoped>.page{padding:20px}.k{color:#6b7280}.v{margin-top:8px;font-weight:600;word-break:break-all}</style>
