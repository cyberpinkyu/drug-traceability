<template>
  <div class="page">
    <el-card>
      <template #header>
        <div class="head">
          <span>扫码溯源增强</span>
          <el-button @click="loadLogs">刷新日志</el-button>
        </div>
      </template>

      <el-form :model="form" inline>
        <el-form-item label="追溯码">
          <el-input v-model="form.traceCode" style="width: 180px" />
        </el-form-item>
        <el-form-item label="设备ID">
          <el-input v-model="form.deviceId" style="width: 160px" />
        </el-form-item>
        <el-form-item label="离线缓存">
          <el-switch v-model="form.offline" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="verify">验签并记录</el-button>
        </el-form-item>
      </el-form>

      <el-alert
        v-if="result"
        :title="result.valid ? '验签通过' : '验签失败'"
        :type="result.valid ? 'success' : 'error'"
        show-icon
        style="margin: 12px 0"
      >
        <template #default>
          traceFound={{ result.traceFound }} batchId={{ result.batchId }}
        </template>
      </el-alert>

      <el-table :data="logs" stripe>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="traceCode" label="追溯码" min-width="160" />
        <el-table-column prop="deviceId" label="设备" min-width="120" />
        <el-table-column prop="verifyPassed" label="验签" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.verifyPassed === 1 ? 'success' : 'danger'">
              {{ scope.row.verifyPassed === 1 ? '通过' : '失败' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="offlineFlag" label="离线" width="90" />
        <el-table-column prop="sourceIp" label="来源IP" min-width="120" />
        <el-table-column prop="createdAt" label="时间" min-width="170" />
      </el-table>
    </el-card>
  </div>
</template>

<script>
import api from '@/api/client'

export default {
  name: 'ScanEnhance',
  data() {
    return {
      form: { traceCode: '', deviceId: 'web', offline: false },
      result: null,
      logs: []
    }
  },
  mounted() {
    this.loadLogs()
  },
  methods: {
    loadLogs() {
      api.get('/api/feature/scan/logs').then((r) => {
        this.logs = r.data.data || []
      })
    },
    verify() {
      if (!this.form.traceCode) {
        this.$message.error('请输入追溯码')
        return
      }
      const ts = Date.now()
      api.get('/api/feature/scan/sign', {
        params: { traceCode: this.form.traceCode, ts }
      }).then((signRes) => {
        const signature = signRes.data?.data?.signature || ''
        return api.post('/api/feature/scan/verify', {
          traceCode: this.form.traceCode,
          deviceId: this.form.deviceId,
          offline: this.form.offline,
          ts,
          signature
        })
      }).then((r) => {
        this.result = r.data.data || {}
        this.loadLogs()
      })
    }
  }
}
</script>

<style scoped>
.page { padding: 20px; }
.head { display: flex; justify-content: space-between; align-items: center; }
</style>
