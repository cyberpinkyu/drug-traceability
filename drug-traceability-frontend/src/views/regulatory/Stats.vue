<template>
  <div class="screen-wrap">
    <div class="screen-header panel-card">
      <div>
        <h2>监管态势大屏</h2>
        <p>地图 · 趋势 · 告警</p>
      </div>
      <div class="header-time">{{ nowText }}</div>
    </div>

    <div class="metric-grid">
      <div class="metric-box panel-card">
        <div class="metric-label">流通总量</div>
        <div class="metric-value">{{ circulationTotal }}</div>
      </div>
      <div class="metric-box panel-card">
        <div class="metric-label">库存总量</div>
        <div class="metric-value">{{ inventoryTotal }}</div>
      </div>
      <div class="metric-box panel-card">
        <div class="metric-label">风险总量</div>
        <div class="metric-value text-danger">{{ riskTotal }}</div>
      </div>
      <div class="metric-box panel-card">
        <div class="metric-label">追溯链路数</div>
        <div class="metric-value">{{ traceFlowCount }}</div>
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
        <div class="map-title">区域态势地图</div>
        <div ref="mapRef" class="map-canvas"></div>
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
            <div class="chart-title">告警列表</div>
          </template>
          <div class="alert-list">
            <div class="alert-item" v-for="(a, idx) in alertList" :key="idx">
              <div class="alert-level" :class="`lv-${a.level}`">{{ a.levelText }}</div>
              <div class="alert-body">
                <div class="alert-title">{{ a.title }}</div>
                <div class="alert-desc">{{ a.desc }}</div>
              </div>
              <div class="alert-time">{{ a.time }}</div>
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

const GD_CITY_POINTS = [
  { name: '广州', lnglat: [113.2644, 23.1291] },
  { name: '深圳', lnglat: [114.0579, 22.5431] },
  { name: '佛山', lnglat: [113.1214, 23.0215] },
  { name: '东莞', lnglat: [113.7518, 23.0207] },
  { name: '珠海', lnglat: [113.5767, 22.2707] }
]

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
    script.onload = () => {
      if (window.AMap) resolve(window.AMap)
      else reject(new Error('地图脚本加载失败'))
    }
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
      circulationRaw: {},
      inventoryRaw: {},
      riskRaw: {},
      circulationTotal: 0,
      inventoryTotal: 0,
      riskTotal: 0,
      traceFlowCount: 0,
      trendSeries: [],
      inventorySeries: [],
      regionStats: [],
      alertList: [],
      trendChart: null,
      inventoryChart: null,
      riskChart: null,
      map: null,
      mapPolygons: [],
      mapMarkers: [],
      mapLabels: [],
      mapLoadError: ''
    }
  },
  async mounted() {
    this.tickTime()
    this.timer = setInterval(this.tickTime, 1000)
    await this.load()
    this.initGuangdongMap()
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

      this.circulationRaw = circulationRes?.data?.data || {}
      this.inventoryRaw = inventoryRes?.data?.data || {}
      this.riskRaw = riskRes?.data?.data || {}

      const circulationEntries = this.collectNumericEntries(this.circulationRaw)
      const inventoryEntries = this.collectNumericEntries(this.inventoryRaw)
      const riskEntries = this.collectNumericEntries(this.riskRaw)

      this.circulationTotal = this.sumEntries(circulationEntries)
      this.inventoryTotal = this.sumEntries(inventoryEntries)
      this.riskTotal = this.sumEntries(riskEntries)
      this.traceFlowCount = Math.max(this.circulationTotal - this.riskTotal, 0)

      this.trendSeries = this.toTopEntries(circulationEntries, 6, 'T')
      this.inventorySeries = this.toTopEntries(inventoryEntries, 5, 'ORG')
      this.regionStats = this.toTopEntries(circulationEntries, 5, '区域').map((x) => ({
        name: x.label,
        value: x.value
      }))
      this.alertList = this.buildAlerts(riskEntries)

      this.renderTrend()
      this.renderInventory()
      this.renderRisk()
      this.renderMapOverlay()
    },
    async initGuangdongMap() {
      this.mapLoadError = ''
      const key = import.meta.env.VITE_AMAP_KEY
      const securityJsCode = import.meta.env.VITE_AMAP_SECURITY_CODE
      if (!key) {
        this.mapLoadError = '未配置 VITE_AMAP_KEY，无法加载地图'
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
          zooms: [6, 11]
        })
        // 强制限定在广东视野范围，避免初始落到北京等默认城市
        const gdSouthWest = new AMap.LngLat(109.6, 20.1)
        const gdNorthEast = new AMap.LngLat(117.4, 25.6)
        this.map.setLimitBounds(new AMap.Bounds(gdSouthWest, gdNorthEast))
        this.map.setCenter([113.2665, 23.1322])
        this.map.setZoom(7)

        const district = new AMap.DistrictSearch({
          level: 'province',
          subdistrict: 0,
          extensions: 'all'
        })

        district.search('广东省', (status, result) => {
          if (status !== 'complete' || !result?.districtList?.length) {
            this.mapLoadError = '广东区域边界加载失败，已切换为广东点位模式'
            this.map.setCenter([113.2665, 23.1322])
            this.map.setZoom(7)
            this.renderMapOverlay()
            return
          }

          const districtInfo = result.districtList[0]
          const boundaries = districtInfo.boundaries || []

          this.mapPolygons.forEach((p) => this.map.remove(p))
          this.mapPolygons = boundaries.map((path) => new AMap.Polygon({
            path,
            strokeColor: '#2563eb',
            strokeWeight: 2,
            fillColor: '#93c5fd',
            fillOpacity: 0.2
          }))
          this.map.add(this.mapPolygons)
          this.map.setBounds(districtInfo.bounds)
          this.map.setCenter([113.2665, 23.1322])
          this.map.setZoom(7)
          this.renderMapOverlay()
        })
      } catch (_) {
        this.mapLoadError = '地图服务加载失败，请检查 key 与安全密钥配置'
      }
    },
    renderMapOverlay() {
      if (!this.map || !window.AMap) return
      const AMap = window.AMap

      this.mapMarkers.forEach((m) => this.map.remove(m))
      this.mapLabels.forEach((l) => this.map.remove(l))
      this.mapMarkers = []
      this.mapLabels = []

      const fallbackValues = [120, 98, 86, 75, 66]
      const values = this.regionStats.length
        ? this.regionStats.map((x) => Number(x.value) || 0)
        : fallbackValues
      const max = Math.max(...values, 1)

      GD_CITY_POINTS.forEach((city, idx) => {
        const value = values[idx] ?? 0
        const radius = 10 + Math.round((value / max) * 18)

        const marker = new AMap.CircleMarker({
          center: city.lnglat,
          radius,
          strokeColor: '#1d4ed8',
          strokeWeight: 2,
          strokeOpacity: 0.9,
          fillColor: '#60a5fa',
          fillOpacity: 0.55
        })
        this.map.add(marker)
        this.mapMarkers.push(marker)

        const label = new AMap.Text({
          text: `${city.name} ${value}`,
          anchor: 'top-center',
          position: city.lnglat,
          offset: new AMap.Pixel(0, -radius - 8),
          style: {
            border: '1px solid #bfdbfe',
            background: '#eff6ff',
            color: '#1e3a8a',
            borderRadius: '6px',
            padding: '2px 6px',
            fontSize: '12px'
          }
        })
        this.map.add(label)
        this.mapLabels.push(label)
      })
    },
    tickTime() {
      const now = new Date()
      this.nowText = now.toLocaleString('zh-CN', { hour12: false })
    },
    collectNumericEntries(obj, parent = '') {
      const result = []
      if (obj == null) return result
      if (typeof obj === 'number' && Number.isFinite(obj)) {
        result.push({ key: parent || 'value', value: obj })
        return result
      }
      if (Array.isArray(obj)) {
        obj.forEach((v, idx) => {
          result.push(...this.collectNumericEntries(v, parent ? `${parent}-${idx + 1}` : `${idx + 1}`))
        })
        return result
      }
      if (typeof obj === 'object') {
        Object.keys(obj).forEach((k) => {
          const childKey = parent ? `${parent}-${k}` : k
          result.push(...this.collectNumericEntries(obj[k], childKey))
        })
      }
      return result
    },
    sumEntries(entries) {
      if (!entries.length) return 0
      return entries.reduce((s, x) => s + (Number(x.value) || 0), 0)
    },
    toTopEntries(entries, limit, fallbackPrefix) {
      if (!entries.length) {
        return Array.from({ length: Math.min(limit, 3) }).map((_, idx) => ({
          label: `${fallbackPrefix}${idx + 1}`,
          value: 0
        }))
      }
      return [...entries]
        .sort((a, b) => b.value - a.value)
        .slice(0, limit)
        .map((x, idx) => ({
          label: this.compactLabel(x.key, `${fallbackPrefix}${idx + 1}`),
          value: Number(x.value) || 0
        }))
    },
    compactLabel(label, fallback) {
      if (!label) return fallback
      const pieces = String(label).split('-')
      return pieces[pieces.length - 1].slice(0, 10) || fallback
    },
    buildAlerts(riskEntries) {
      const base = this.toTopEntries(riskEntries, 6, '风险项')
      const now = new Date()
      return base.map((x, idx) => {
        const level = idx < 1 ? 'high' : idx < 3 ? 'mid' : 'low'
        const d = new Date(now.getTime() - idx * 3600 * 1000)
        return {
          level,
          levelText: level === 'high' ? '高' : level === 'mid' ? '中' : '低',
          title: `${x.label} 告警`,
          desc: `风险值 ${x.value}，建议人工复核流通与库存记录`,
          time: d.toLocaleTimeString('zh-CN', { hour12: false })
        }
      })
    },
    renderTrend() {
      if (!this.$refs.trendRef) return
      if (!this.trendChart) this.trendChart = echarts.init(this.$refs.trendRef)

      this.trendChart.setOption({
        tooltip: { trigger: 'axis' },
        grid: { left: 36, right: 20, top: 20, bottom: 30 },
        xAxis: {
          type: 'category',
          data: this.trendSeries.map((x) => x.label),
          axisLabel: { color: '#5b6b84' }
        },
        yAxis: {
          type: 'value',
          axisLabel: { color: '#5b6b84' },
          splitLine: { lineStyle: { color: '#e6edf7' } }
        },
        series: [
          {
            type: 'line',
            smooth: true,
            symbolSize: 8,
            areaStyle: {
              color: 'rgba(37,99,235,0.18)'
            },
            lineStyle: { width: 3, color: '#2563eb' },
            itemStyle: { color: '#2563eb' },
            data: this.trendSeries.map((x) => x.value)
          }
        ]
      })
    },
    renderInventory() {
      if (!this.$refs.inventoryRef) return
      if (!this.inventoryChart) this.inventoryChart = echarts.init(this.$refs.inventoryRef)

      this.inventoryChart.setOption({
        tooltip: { trigger: 'axis' },
        grid: { left: 54, right: 18, top: 16, bottom: 20 },
        xAxis: {
          type: 'value',
          axisLabel: { color: '#5b6b84' },
          splitLine: { lineStyle: { color: '#e6edf7' } }
        },
        yAxis: {
          type: 'category',
          axisLabel: { color: '#5b6b84' },
          data: this.inventorySeries.map((x) => x.label)
        },
        series: [
          {
            type: 'bar',
            data: this.inventorySeries.map((x) => x.value),
            itemStyle: {
              color: '#0f766e',
              borderRadius: [0, 8, 8, 0]
            }
          }
        ]
      })
    },
    renderRisk() {
      if (!this.$refs.riskRef) return
      if (!this.riskChart) this.riskChart = echarts.init(this.$refs.riskRef)

      const high = Math.ceil(this.riskTotal * 0.22)
      const mid = Math.ceil(this.riskTotal * 0.33)
      const low = Math.max(this.riskTotal - high - mid, 0)

      this.riskChart.setOption({
        tooltip: { trigger: 'item' },
        legend: { bottom: 0, textStyle: { color: '#5b6b84' } },
        series: [
          {
            type: 'pie',
            radius: ['45%', '72%'],
            itemStyle: {
              borderColor: '#fff',
              borderWidth: 2,
              borderRadius: 6
            },
            label: { formatter: '{b}: {c}' },
            data: [
              { value: high, name: '高风险', itemStyle: { color: '#dc2626' } },
              { value: mid, name: '中风险', itemStyle: { color: '#d97706' } },
              { value: low, name: '低风险', itemStyle: { color: '#2563eb' } }
            ]
          }
        ]
      })
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
.screen-wrap {
  padding: 12px;
}

.screen-header {
  border: 1px solid var(--border);
  padding: 14px 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.screen-header h2 {
  margin: 0;
  font-size: 24px;
  letter-spacing: 1px;
}

.screen-header p {
  margin: 4px 0 0;
  color: var(--text-secondary);
  font-size: 13px;
}

.header-time {
  font-family: Consolas, Monaco, monospace;
  color: #1e3a8a;
  font-size: 14px;
  font-weight: 700;
}

.metric-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 12px;
  margin-bottom: 12px;
}

.metric-box {
  border: 1px solid var(--border);
  padding: 12px 14px;
}

.text-danger {
  color: #dc2626;
}

.content-grid {
  display: grid;
  grid-template-columns: 1.05fr 1.2fr 0.95fr;
  gap: 12px;
  min-height: calc(100vh - 250px);
}

.left-column,
.right-column {
  display: grid;
  grid-template-rows: 1fr 1fr;
  gap: 12px;
}

.chart-card {
  border: 1px solid var(--border);
}

.chart-title {
  font-weight: 700;
  color: var(--text-main);
}

.chart-lg {
  height: 290px;
}

.chart-sm {
  height: 240px;
}

.center-column {
  position: relative;
  border: 1px solid var(--border);
  border-radius: 14px;
  overflow: hidden;
  background:
    radial-gradient(circle at 20% 25%, rgba(37,99,235,0.12), transparent 40%),
    radial-gradient(circle at 80% 80%, rgba(15,118,110,0.14), transparent 46%),
    #f8fbff;
}

.map-title {
  padding: 14px 14px 0;
  font-weight: 700;
}

.map-canvas {
  height: calc(100% - 40px);
  margin: 8px;
  border-radius: 12px;
  border: 1px solid #dbe7f6;
  overflow: hidden;
}

.map-error {
  position: absolute;
  left: 16px;
  right: 16px;
  bottom: 14px;
  background: rgba(220, 38, 38, 0.08);
  color: #b91c1c;
  border: 1px solid rgba(220, 38, 38, 0.25);
  border-radius: 8px;
  font-size: 12px;
  padding: 8px 10px;
}

.alert-card {
  border: 1px solid var(--border);
}

.alert-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  max-height: 238px;
  overflow: auto;
}

.alert-item {
  display: grid;
  grid-template-columns: 38px 1fr auto;
  gap: 10px;
  align-items: center;
  padding: 8px;
  border: 1px solid #e3ebf6;
  border-radius: 10px;
  background: #f9fcff;
}

.alert-level {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 12px;
  font-weight: 700;
}

.lv-high { background: #dc2626; }
.lv-mid { background: #d97706; }
.lv-low { background: #2563eb; }

.alert-title {
  font-weight: 700;
  font-size: 13px;
}

.alert-desc {
  color: var(--text-secondary);
  font-size: 12px;
  margin-top: 2px;
}

.alert-time {
  color: #64748b;
  font-size: 12px;
  font-family: Consolas, Monaco, monospace;
}

@media (max-width: 1400px) {
  .content-grid {
    grid-template-columns: 1fr;
    min-height: auto;
  }

  .left-column,
  .right-column {
    grid-template-rows: auto;
  }
}
</style>
