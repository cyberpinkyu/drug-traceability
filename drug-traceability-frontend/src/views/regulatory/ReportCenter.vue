<template>
  <div class="page">
    <el-card>
      <template #header>
        <div class="head">
          <span>多维报表中心</span>
          <div class="toolbar">
            <el-select v-model="filters.dimension" style="width: 140px">
              <el-option label="时间" value="time" />
              <el-option label="企业" value="enterprise" />
              <el-option label="批次" value="batch" />
              <el-option label="区域" value="region" />
            </el-select>
            <el-date-picker v-model="range" type="daterange" value-format="YYYY-MM-DD" />
            <el-button type="primary" @click="load">获取分析</el-button>
          </div>
        </div>
      </template>

      <el-descriptions :column="4" border class="summary">
        <el-descriptions-item label="维度">{{ summary.dimension || '-' }}</el-descriptions-item>
        <el-descriptions-item label="开始">{{ summary.from || '-' }}</el-descriptions-item>
        <el-descriptions-item label="结束">{{ summary.to || '-' }}</el-descriptions-item>
        <el-descriptions-item label="记录数">{{ summary.count || 0 }}</el-descriptions-item>
      </el-descriptions>

      <div class="chart-grid">
        <div ref="mainChartRef" class="chart"></div>
        <div ref="subChartRef" class="chart"></div>
      </div>

      <el-table :data="rows" stripe>
        <el-table-column prop="key" label="维度值" min-width="140" />
        <el-table-column prop="name" label="名称" min-width="150" />
        <el-table-column prop="organization" label="机构/区域" min-width="180" />
        <el-table-column prop="phone" label="电话" min-width="130" />
        <el-table-column prop="email" label="邮箱" min-width="180" />
        <el-table-column prop="productionQuantity" label="生产量" min-width="100" />
        <el-table-column prop="procurementQuantity" label="采购量" min-width="100" />
        <el-table-column prop="saleQuantity" label="销售量" min-width="100" />
        <el-table-column prop="inventoryTotal" label="库存量" min-width="100" />
        <el-table-column prop="batchCount" label="批次数" min-width="100" />
      </el-table>
    </el-card>
  </div>
</template>

<script>
import api from '@/api/client'
import * as echarts from 'echarts'

export default {
  name: 'ReportCenter',
  data() {
    return {
      filters: { dimension: 'time' },
      range: [],
      rows: [],
      summary: {},
      charts: {},
      mainChart: null,
      subChart: null
    }
  },
  mounted() {
    this.load()
    window.addEventListener('resize', this.onResize)
  },
  beforeUnmount() {
    window.removeEventListener('resize', this.onResize)
    this.mainChart?.dispose()
    this.subChart?.dispose()
  },
  methods: {
    async load() {
      const params = { dimension: this.filters.dimension }
      if (this.range?.length === 2) {
        params.startDate = this.range[0]
        params.endDate = this.range[1]
      }
      const res = await api.get('/api/feature/reports/drilldown', { params })
      this.rows = res.data.data || []
      this.summary = res.data.summary || {}
      this.charts = res.data.charts || {}
      this.renderCharts()
    },
    renderCharts() {
      const labels = this.charts.labels || []
      if (!this.mainChart) this.mainChart = echarts.init(this.$refs.mainChartRef)
      if (!this.subChart) this.subChart = echarts.init(this.$refs.subChartRef)

      this.mainChart.setOption({
        tooltip: { trigger: 'axis' },
        legend: { top: 0 },
        grid: { left: 40, right: 16, top: 36, bottom: 30 },
        xAxis: { type: 'category', data: labels },
        yAxis: { type: 'value' },
        series: [
          { name: '生产量', type: 'bar', data: this.charts.production || [] },
          { name: '采购量', type: 'line', smooth: true, data: this.charts.procurement || [] },
          { name: '销售量', type: 'line', smooth: true, data: this.charts.sale || [] }
        ]
      })

      this.subChart.setOption({
        tooltip: { trigger: 'item' },
        series: [
          {
            type: 'pie',
            radius: ['35%', '68%'],
            data: labels.map((label, index) => ({
              name: label,
              value: (this.charts.inventory || [])[index] || (this.charts.batchCount || [])[index] || 0
            }))
          }
        ]
      })
    },
    onResize() {
      this.mainChart?.resize()
      this.subChart?.resize()
    }
  }
}
</script>

<style scoped>
.page { padding: 20px; }
.head { display: flex; justify-content: space-between; align-items: center; }
.toolbar { display: flex; gap: 8px; align-items: center; }
.summary { margin-bottom: 12px; }
.chart-grid { display: grid; grid-template-columns: 1.2fr 0.8fr; gap: 12px; margin-bottom: 16px; }
.chart { height: 320px; border: 1px solid #e5edf7; border-radius: 12px; padding: 8px; background: #fff; }
@media (max-width: 1200px) {
  .head, .toolbar, .chart-grid { grid-template-columns: 1fr; display: grid; }
}
</style>
