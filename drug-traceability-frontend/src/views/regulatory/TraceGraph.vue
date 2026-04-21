<template>
  <div class="page">
    <el-card>
      <template #header>
        <div class="head">
          <span>全链路追溯图谱</span>
          <div>
            <el-input v-model="batchId" placeholder="输入批次ID" style="width: 180px; margin-right: 8px" />
            <el-button type="primary" @click="loadGraph">查询</el-button>
          </div>
        </div>
      </template>

      <el-row :gutter="12" style="margin-bottom: 12px">
        <el-col :span="6"><el-statistic title="节点数" :value="summary.nodeCount || 0" /></el-col>
        <el-col :span="6"><el-statistic title="边数" :value="summary.edgeCount || 0" /></el-col>
        <el-col :span="6"><el-statistic title="高风险上报" :value="summary.highRiskReactionCount || 0" /></el-col>
        <el-col :span="6">
          <el-tag :type="summary.abnormal ? 'danger' : 'success'">
            {{ summary.abnormal ? '存在异常节点' : '未发现异常' }}
          </el-tag>
        </el-col>
      </el-row>

      <el-divider content-position="left">节点（异常高亮）</el-divider>
      <el-table :data="nodes" stripe>
        <el-table-column prop="id" label="ID" min-width="180" />
        <el-table-column prop="type" label="类型" width="120" />
        <el-table-column prop="label" label="名称" min-width="180" />
        <el-table-column label="状态" width="120">
          <template #default="scope">
            <el-tag :type="scope.row.abnormal ? 'danger' : 'success'">
              {{ scope.row.abnormal ? '异常' : '正常' }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>

      <el-divider content-position="left">流向边</el-divider>
      <el-table :data="edges" stripe>
        <el-table-column prop="from" label="起点" min-width="180" />
        <el-table-column prop="to" label="终点" min-width="180" />
        <el-table-column prop="label" label="关系" min-width="200" />
      </el-table>
    </el-card>
  </div>
</template>

<script>
import api from '@/api/client'

export default {
  name: 'TraceGraph',
  data() {
    return {
      batchId: '',
      nodes: [],
      edges: [],
      summary: {}
    }
  },
  methods: {
    loadGraph() {
      if (!this.batchId) {
        this.$message.error('请先输入批次ID')
        return
      }
      api.get(`/api/feature/trace/graph/${this.batchId}`).then((res) => {
        const data = res.data.data || {}
        this.nodes = data.nodes || []
        this.edges = data.edges || []
        this.summary = data.summary || {}
      })
    }
  }
}
</script>

<style scoped>
.page { padding: 20px; }
.head { display:flex; justify-content:space-between; align-items:center; }
</style>
