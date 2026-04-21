<template>
  <div class="page">
    <el-card>
      <template #header>
        <div class="head">
          <span>多维报表中心</span>
          <div>
            <el-select v-model="filters.dimension" style="width: 140px; margin-right: 8px">
              <el-option label="时间" value="time" />
              <el-option label="企业" value="enterprise" />
              <el-option label="批次" value="batch" />
              <el-option label="地区" value="region" />
            </el-select>
            <el-date-picker v-model="range" type="daterange" value-format="YYYY-MM-DD" style="margin-right: 8px" />
            <el-button type="primary" @click="load">钻取分析</el-button>
          </div>
        </div>
      </template>

      <el-descriptions :column="4" border style="margin-bottom: 12px">
        <el-descriptions-item label="维度">{{ summary.dimension || '-' }}</el-descriptions-item>
        <el-descriptions-item label="起始">{{ summary.from || '-' }}</el-descriptions-item>
        <el-descriptions-item label="结束">{{ summary.to || '-' }}</el-descriptions-item>
        <el-descriptions-item label="记录数">{{ summary.count || 0 }}</el-descriptions-item>
      </el-descriptions>

      <el-table :data="rows" stripe>
        <el-table-column prop="key" label="维度键" min-width="180" />
        <el-table-column prop="name" label="名称" min-width="160" />
        <el-table-column prop="organization" label="地区/机构" min-width="160" />
        <el-table-column prop="productionQuantity" label="产量" min-width="120" />
        <el-table-column prop="procurementCount" label="采购笔数" min-width="120" />
        <el-table-column prop="saleCount" label="销售笔数" min-width="120" />
        <el-table-column prop="inventoryTotal" label="库存总量" min-width="120" />
        <el-table-column prop="batchCount" label="批次数" min-width="100" />
        <el-table-column prop="inventoryOrgCount" label="库存机构数" min-width="120" />
      </el-table>
    </el-card>
  </div>
</template>

<script>
import api from '@/api/client'

export default {
  name: 'ReportCenter',
  data() {
    return {
      filters: { dimension: 'time' },
      range: [],
      rows: [],
      summary: {}
    }
  },
  mounted() {
    this.load()
  },
  methods: {
    load() {
      const params = { dimension: this.filters.dimension }
      if (this.range?.length === 2) {
        params.startDate = this.range[0]
        params.endDate = this.range[1]
      }
      api.get('/api/feature/reports/drilldown', { params }).then((res) => {
        this.rows = res.data.data || []
        this.summary = res.data.summary || {}
      })
    }
  }
}
</script>

<style scoped>
.page { padding: 20px; }
.head { display:flex; justify-content:space-between; align-items:center; }
</style>
