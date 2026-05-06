<template>
  <div class="page">
    <el-card>
      <template #header>
        <div class="head">
          <span>全链路追溯图谱</span>
          <div class="toolbar">
            <el-select v-model="batchId" filterable placeholder="选择批次" style="width: 220px">
              <el-option v-for="item in batches" :key="item.id" :label="item.batchNumber" :value="item.id" />
            </el-select>
            <el-button type="primary" @click="loadGraph">查询</el-button>
          </div>
        </div>
      </template>

      <el-row :gutter="12" class="summary">
        <el-col :span="6"><el-statistic title="节点数" :value="summary.nodeCount || 0" /></el-col>
        <el-col :span="6"><el-statistic title="关系数" :value="summary.edgeCount || 0" /></el-col>
        <el-col :span="6"><el-statistic title="高风险上报" :value="summary.highRiskReactionCount || 0" /></el-col>
        <el-col :span="6">
          <el-tag :type="summary.abnormal ? 'danger' : 'success'">
            {{ summary.abnormal ? '存在异常节点' : '未发现异常' }}
          </el-tag>
        </el-col>
      </el-row>

      <div v-if="graphNodes.length" class="chain-board">
        <div class="stage-flow">
          <div v-for="node in graphNodes" :key="node.id" class="flow-item">
            <div class="node-card" :class="[node.type, { abnormal: node.abnormal }]">
              <div class="node-type">{{ node.typeText }}</div>
              <div class="node-label">{{ node.label }}</div>
            </div>
            <div v-if="node.nextLabel" class="node-arrow">
              <span>{{ node.nextLabel }}</span>
            </div>
          </div>
        </div>

        <div class="relation-grid" v-if="riskNodes.length || terminalNodes.length">
          <div v-if="terminalNodes.length" class="relation-panel">
            <div class="panel-title">流通终端与库存机构</div>
            <div class="panel-list">
              <div v-for="node in terminalNodes" :key="node.id" class="panel-card inventory">
                <div class="node-type">{{ node.typeText }}</div>
                <div class="node-label">{{ node.label }}</div>
              </div>
            </div>
          </div>

          <div v-if="riskNodes.length" class="relation-panel">
            <div class="panel-title">风险与异常节点</div>
            <div class="panel-list">
              <div v-for="node in riskNodes" :key="node.id" class="panel-card risk" :class="{ abnormal: node.abnormal }">
                <div class="node-type">{{ node.typeText }}</div>
                <div class="node-label">{{ node.label }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>

    </el-card>
  </div>
</template>

<script>
import api from '@/api/client'

const TITLES = {
  drug: '药品',
  batch: '批次',
  producer: '生产企业',
  supplier: '供应方',
  buyer: '采购方',
  seller: '销售方',
  inventoryHolder: '库存机构',
  reaction: '风险监测'
}

const ORDER = ['drug', 'batch', 'producer', 'supplier', 'buyer', 'seller']

export default {
  name: 'TraceGraph',
  data() {
    return {
      batchId: '',
      batches: [],
      nodes: [],
      edges: [],
      summary: {}
    }
  },
  computed: {
    nodeMap() {
      return this.nodes.reduce((acc, item) => {
        acc[item.id] = item
        return acc
      }, {})
    },
    graphNodes() {
      return this.nodes
        .filter((node) => ORDER.includes(node.type))
        .sort((a, b) => ORDER.indexOf(a.type) - ORDER.indexOf(b.type))
        .map((node) => ({
          ...node,
          typeText: TITLES[node.type] || node.type,
          nextLabel: this.findNextEdgeLabel(node.id)
        }))
    },
    terminalNodes() {
      return this.nodes
        .filter((node) => node.type === 'inventoryHolder')
        .map((node) => ({ ...node, typeText: TITLES[node.type] || node.type }))
    },
    riskNodes() {
      return this.nodes
        .filter((node) => node.type === 'reaction')
        .map((node) => ({ ...node, typeText: TITLES[node.type] || node.type }))
    }
  },
  async mounted() {
    await this.loadBatches()
  },
  methods: {
    async loadBatches() {
      const res = await api.get('/api/trace/batch')
      this.batches = res.data.data || []
      if (this.batches.length) {
        this.batchId = this.batches[0].id
        await this.loadGraph()
      }
    },
    async loadGraph() {
      if (!this.batchId) {
        this.$message.error('请先选择批次')
        return
      }
      const res = await api.get(`/api/feature/trace/graph/${this.batchId}`)
      const data = res.data.data || {}
      this.nodes = data.nodes || []
      this.edges = data.edges || []
      this.summary = data.summary || {}
    },
    findNextEdgeLabel(nodeId) {
      const edge = this.edges.find((item) => item.from === nodeId && this.nodeMap[item.to] && ORDER.includes(this.nodeMap[item.to].type))
      return edge?.label || ''
    }
  }
}
</script>

<style scoped>
.page { padding: 20px; }
.head { display: flex; justify-content: space-between; align-items: center; }
.toolbar { display: flex; gap: 8px; align-items: center; }
.summary { margin-bottom: 12px; }
.chain-board { display: flex; flex-direction: column; gap: 18px; margin-bottom: 16px; }
.stage-flow { display: flex; flex-wrap: wrap; align-items: center; gap: 14px; padding: 18px; border: 1px solid #e5edf7; border-radius: 16px; background: linear-gradient(180deg, #fbfdff 0%, #f4f8ff 100%); }
.flow-item { display: flex; align-items: center; gap: 14px; }
.node-card, .panel-card { width: 180px; min-height: 94px; border-radius: 14px; padding: 12px; background: #fff; border: 1px solid #dbe7f6; box-shadow: 0 10px 20px rgba(15, 23, 42, 0.05); }
.node-card.abnormal, .panel-card.abnormal { border-color: rgba(220, 38, 38, 0.4); background: #fff6f6; }
.node-type { font-size: 12px; color: #64748b; margin-bottom: 8px; }
.node-label { font-size: 15px; font-weight: 700; line-height: 1.4; }
.node-card.drug { border-top: 4px solid #1d4ed8; }
.node-card.batch { border-top: 4px solid #7c3aed; }
.node-card.producer, .node-card.supplier, .node-card.seller { border-top: 4px solid #0f766e; }
.node-card.buyer { border-top: 4px solid #d97706; }
.node-arrow { display: flex; align-items: center; gap: 8px; color: #334155; font-size: 12px; font-weight: 700; }
.node-arrow::after { content: '->'; font-size: 16px; color: #93a6bf; }
.relation-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.relation-panel { border: 1px solid #e5edf7; border-radius: 16px; padding: 16px; background: #fff; }
.panel-title { font-size: 15px; font-weight: 700; color: #1e3a8a; margin-bottom: 12px; }
.panel-list { display: flex; flex-wrap: wrap; gap: 12px; }
.panel-card.inventory { border-top: 4px solid #d97706; }
.panel-card.risk { border-top: 4px solid #dc2626; }
@media (max-width: 1400px) {
  .relation-grid { grid-template-columns: 1fr; }
}
</style>
