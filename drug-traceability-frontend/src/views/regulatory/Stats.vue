<template>
  <div class="screen-wrap">
    <div class="screen-header panel-card">
      <div>
        <h2>监管态势大屏</h2>
        <p>采购、销售、生产、库存与区域流通态势</p>
      </div>
      <div class="header-time">{{ nowText }}</div>
    </div>

    <div class="metric-grid">
      <div class="metric-box panel-card">
        <div class="metric-label">采购总量</div>
        <div class="metric-value">{{ circulation.totalProcurementQuantity || 0 }}</div>
      </div>
      <div class="metric-box panel-card">
        <div class="metric-label">销售总量</div>
        <div class="metric-value">{{ circulation.totalSaleQuantity || 0 }}</div>
      </div>
      <div class="metric-box panel-card">
        <div class="metric-label">库存总量</div>
        <div class="metric-value">{{ inventory.totalQuantity || 0 }}</div>
      </div>
      <div class="metric-box panel-card">
        <div class="metric-label">风险上报数</div>
        <div class="metric-value text-danger">{{ riskTotal }}</div>
      </div>
    </div>

    <div class="content-grid">
      <div class="left-column">
        <el-card class="panel-card chart-card">
          <template #header>
            <div class="chart-title">流通趋势</div>
          </template>
          <div ref="trendRef" class="chart-lg"></div>
        </el-card>

        <el-card class="panel-card chart-card">
          <template #header>
            <div class="chart-title">库存结构</div>
          </template>
          <div ref="inventoryRef" class="chart-sm"></div>
        </el-card>
      </div>

      <div class="center-column panel-card">
        <div class="map-title">广东区域态势地图</div>
        <div ref="mapRef" class="map-board"></div>
        <div v-if="mapLoadError" class="map-error">{{ mapLoadError }}</div>
      </div>

      <div class="right-column">
        <el-card class="panel-card chart-card">
          <template #header>
            <div class="chart-title">风险分层</div>
          </template>
          <div ref="riskRef" class="chart-sm"></div>
        </el-card>

        <el-card class="panel-card alert-card">
          <template #header>
            <div class="chart-title">近期告警</div>
          </template>
          <div class="alert-list">
            <div class="alert-item" v-for="(a, idx) in alerts" :key="idx">
              <div class="alert-level" :class="`lv-${normalizeLevel(a.level)}`">
                {{ levelText(a.level) }}
              </div>
              <div class="alert-body">
                <div class="alert-title">{{ a.title }}</div>
                <div class="alert-desc">{{ a.desc }}</div>
              </div>
              <div class="alert-time">{{ formatTime(a.time) }}</div>
            </div>
          </div>
        </el-card>
      </div>
    </div>
  </div>
</template>

<script>
import api from '@/api/client'
import * as echarts from 'echarts'

const CITY_POINTS = {
  广州: [113.2644, 23.1291],
  深圳: [114.0579, 22.5431],
  佛山: [113.1214, 23.0215],
  东莞: [113.7518, 23.0207],
  珠海: [113.5767, 22.2707],
  惠州: [114.4168, 23.1115],
  中山: [113.3928, 22.5176],
  江门: [113.0819, 22.5787]
}

let amapScriptPromise = null

function loadAmapScript(key, securityJsCode) {
  if (window.AMap) return Promise.resolve(window.AMap)
  if (amapScriptPromise) return amapScriptPromise
  amapScriptPromise = new Promise((resolve, reject) => {
    if (securityJsCode) {
      window._AMapSecurityConfig = { securityJsCode }
    }
    const script = document.createElement('script')
    script.src = `https://webapi.amap.com/maps?v=2.0&key=${encodeURIComponent(key)}&plugin=AMap.DistrictSearch`
    script.async = true
    script.onload = () => window.AMap ? resolve(window.AMap) : reject(new Error('地图脚本加载失败'))
    script.onerror = () => reject(new Error('地图脚本加载失败'))
    document.head.appendChild(script)
  })
  return amapScriptPromise
}

export default {
  name: 'Stats',
  data() {
    return {
      nowText: '',
      timer: null,
      circulation: {},
      inventory: {},
      risk: {},
      trendChart: null,
      inventoryChart: null,
      riskChart: null,
      map: null,
      mapMarkers: [],
      mapLabels: [],
      mapPolygons: [],
      mapLoadError: ''
    }
  },
  computed: {
    riskTotal() {
      return Number(this.risk.highRiskCount || 0) + Number(this.risk.mediumRiskCount || 0) + Number(this.risk.lowRiskCount || 0)
    },
    alerts() {
      return Array.isArray(this.risk.recentAlerts) ? this.risk.recentAlerts : []
    },
    regionStats() {
      return Array.isArray(this.circulation.regionStats) ? this.circulation.regionStats : []
    }
  },
  async mounted() {
    this.tickTime()
    this.timer = setInterval(this.tickTime, 1000)
    await this.load()
    await this.initMap()
    window.addEventListener('resize', this.onResize)
  },
  beforeUnmount() {
    clearInterval(this.timer)
    window.removeEventListener('resize', this.onResize)
    this.trendChart?.dispose()
    this.inventoryChart?.dispose()
    this.riskChart?.dispose()
    if (this.map) {
      this.map.destroy()
      this.map = null
    }
  },
  methods: {
    async load() {
      const [circulationRes, inventoryRes, riskRes] = await Promise.all([
        api.get('/api/regulatory/stats/circulation', { params: { timeRange: 'month', region: 'all' } }),
        api.get('/api/regulatory/stats/inventory'),
        api.get('/api/regulatory/stats/risk')
      ])
      this.circulation = circulationRes?.data?.data || {}
      this.inventory = inventoryRes?.data?.data || {}
      this.risk = riskRes?.data?.data || {}
      this.renderTrend()
      this.renderInventory()
      this.renderRisk()
      this.renderMapOverlay()
    },
    async initMap() {
      this.mapLoadError = ''
      const key = import.meta.env.VITE_AMAP_KEY
      const securityJsCode = import.meta.env.VITE_AMAP_SECURITY_CODE
      if (!key) {
        this.mapLoadError = '未配置高德地图 Key'
        return
      }

      try {
        const AMap = await loadAmapScript(key, securityJsCode)
        if (!this.$refs.mapRef) return
        this.map = new AMap.Map(this.$refs.mapRef, {
          center: [113.2665, 23.1322],
          zoom: 7,
          resizeEnable: true,
          mapStyle: 'amap://styles/whitesmoke',
          zooms: [6, 10]
        })

        const southWest = new AMap.LngLat(109.5, 20.0)
        const northEast = new AMap.LngLat(117.5, 25.7)
        this.map.setLimitBounds(new AMap.Bounds(southWest, northEast))

        const district = new AMap.DistrictSearch({
          level: 'province',
          subdistrict: 0,
          extensions: 'all'
        })

        district.search('广东省', (status, result) => {
          if (status !== 'complete' || !result?.districtList?.length) {
            this.mapLoadError = '广东省边界加载失败'
            this.renderMapOverlay()
            return
          }
          const info = result.districtList[0]
          const boundaries = info.boundaries || []
          this.mapPolygons.forEach((item) => this.map.remove(item))
          this.mapPolygons = boundaries.map((path) => new AMap.Polygon({
            path,
            strokeColor: '#2563eb',
            strokeWeight: 2,
            fillColor: '#93c5fd',
            fillOpacity: 0.18
          }))
          this.map.add(this.mapPolygons)
          this.map.setBounds(info.bounds)
          this.renderMapOverlay()
        })
      } catch (_) {
        this.mapLoadError = '地图服务加载失败，请检查 Key 配置'
      }
    },
    renderMapOverlay() {
      if (!this.map || !window.AMap) return
      const AMap = window.AMap
      this.mapMarkers.forEach((item) => this.map.remove(item))
      this.mapLabels.forEach((item) => this.map.remove(item))
      this.mapMarkers = []
      this.mapLabels = []

      const max = Math.max(...this.regionStats.map((x) => Number(x.value) || 0), 1)
      this.regionStats.forEach((item) => {
        const point = CITY_POINTS[item.name]
        if (!point) return
        const value = Number(item.value) || 0
        const marker = new AMap.CircleMarker({
          center: point,
          radius: 5,
          strokeColor: '#1d4ed8',
          strokeWeight: 1,
          strokeOpacity: 1,
          fillColor: '#2563eb',
          fillOpacity: 0.95,
          zIndex: 120
        })
        const label = new AMap.Text({
          text: `${item.name} ${value}`,
          position: point,
          anchor: 'top-center',
          offset: new AMap.Pixel(0, -14),
          style: {
            border: '1px solid #bfdbfe',
            background: 'rgba(255,255,255,0.96)',
            color: '#1e3a8a',
            borderRadius: '8px',
            padding: '4px 8px',
            fontSize: '12px',
            fontWeight: '700',
            boxShadow: '0 8px 20px rgba(37,99,235,0.14)'
          },
          zIndex: 130
        })
        label.on('mouseover', () => {
          label.setzIndex(300)
        })
        label.on('mouseout', () => {
          label.setzIndex(130)
        })
        this.map.add(marker)
        this.map.add(label)
        this.mapMarkers.push(marker)
        this.mapLabels.push(label)
      })
    },
    tickTime() {
      this.nowText = new Date().toLocaleString('zh-CN', { hour12: false })
    },
    renderTrend() {
      const rows = Array.isArray(this.circulation.trend) ? this.circulation.trend : []
      if (!this.trendChart) this.trendChart = echarts.init(this.$refs.trendRef)
      this.trendChart.setOption({
        tooltip: { trigger: 'axis' },
        legend: { top: 0 },
        grid: { left: 40, right: 18, top: 36, bottom: 30 },
        xAxis: { type: 'category', data: rows.map((x) => x.month) },
        yAxis: { type: 'value' },
        series: [
          { name: '采购量', type: 'line', smooth: true, data: rows.map((x) => x.procurement), itemStyle: { color: '#2563eb' } },
          { name: '销售量', type: 'line', smooth: true, data: rows.map((x) => x.sale), itemStyle: { color: '#0f766e' } },
          { name: '生产量', type: 'bar', data: rows.map((x) => x.production), itemStyle: { color: '#d97706' } }
        ]
      })
    },
    renderInventory() {
      const rows = Array.isArray(this.inventory.byCategory) ? this.inventory.byCategory : []
      if (!this.inventoryChart) this.inventoryChart = echarts.init(this.$refs.inventoryRef)
      this.inventoryChart.setOption({
        tooltip: { trigger: 'item' },
        series: [{ type: 'pie', radius: ['38%', '68%'], data: rows.map((x) => ({ name: x.name, value: x.value })) }]
      })
    },
    renderRisk() {
      if (!this.riskChart) this.riskChart = echarts.init(this.$refs.riskRef)
      this.riskChart.setOption({
        tooltip: { trigger: 'item' },
        series: [{
          type: 'pie',
          radius: ['42%', '72%'],
          data: [
            { name: '高风险', value: Number(this.risk.highRiskCount || 0), itemStyle: { color: '#dc2626' } },
            { name: '中风险', value: Number(this.risk.mediumRiskCount || 0), itemStyle: { color: '#d97706' } },
            { name: '低风险', value: Number(this.risk.lowRiskCount || 0), itemStyle: { color: '#2563eb' } }
          ]
        }]
      })
    },
    normalizeLevel(level) {
      if (level === 'high') return 'high'
      if (level === 'medium') return 'mid'
      return 'low'
    },
    levelText(level) {
      if (level === 'high') return '高'
      if (level === 'medium') return '中'
      return '低'
    },
    formatTime(value) {
      if (!value) return '-'
      return String(value).replace('T', ' ').slice(0, 16)
    },
    onResize() {
      this.trendChart?.resize()
      this.inventoryChart?.resize()
      this.riskChart?.resize()
      this.map?.resize()
    }
  }
}
</script>

<style scoped>
.screen-wrap { padding: 12px; }
.screen-header { border: 1px solid var(--border); padding: 14px 16px; display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
.screen-header h2 { margin: 0; font-size: 24px; }
.screen-header p { margin: 4px 0 0; color: var(--text-secondary); }
.header-time { font-family: Consolas, Monaco, monospace; color: #1e3a8a; font-weight: 700; }
.metric-grid { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 12px; margin-bottom: 12px; }
.metric-box { padding: 12px 14px; border: 1px solid var(--border); }
.metric-label { color: var(--text-secondary); font-size: 13px; }
.metric-value { font-size: 28px; font-weight: 700; margin-top: 8px; }
.text-danger { color: #dc2626; }
.content-grid { display: grid; grid-template-columns: 1.1fr 1fr 0.95fr; gap: 12px; }
.left-column, .right-column { display: grid; grid-template-rows: 1fr 1fr; gap: 12px; }
.chart-card, .center-column, .alert-card { border: 1px solid var(--border); }
.chart-title, .map-title { font-weight: 700; }
.chart-lg { height: 300px; }
.chart-sm { height: 240px; }
.center-column { position: relative; padding: 14px; border-radius: 14px; background: linear-gradient(180deg, #f8fbff 0%, #eef6ff 100%); }
.map-board { height: calc(100% - 30px); min-height: 520px; margin-top: 12px; border-radius: 16px; overflow: hidden; border: 1px solid #dbe7f6; }
.map-error { position: absolute; left: 18px; right: 18px; bottom: 16px; padding: 10px 12px; background: rgba(220, 38, 38, 0.08); border: 1px solid rgba(220, 38, 38, 0.2); border-radius: 10px; color: #b91c1c; font-size: 12px; }
.alert-list { display: flex; flex-direction: column; gap: 10px; max-height: 238px; overflow: auto; }
.alert-item { display: grid; grid-template-columns: 38px 1fr auto; gap: 10px; align-items: center; padding: 8px; border: 1px solid #e3ebf6; border-radius: 10px; background: #f9fcff; }
.alert-level { width: 30px; height: 30px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 12px; font-weight: 700; }
.lv-high { background: #dc2626; }
.lv-mid { background: #d97706; }
.lv-low { background: #2563eb; }
.alert-title { font-weight: 700; font-size: 13px; }
.alert-desc { color: var(--text-secondary); font-size: 12px; margin-top: 2px; }
.alert-time { color: #64748b; font-size: 12px; font-family: Consolas, Monaco, monospace; }
@media (max-width: 1400px) {
  .metric-grid, .content-grid { grid-template-columns: 1fr; }
  .left-column, .right-column { grid-template-rows: auto; }
  .map-board { min-height: 360px; }
}
</style>
