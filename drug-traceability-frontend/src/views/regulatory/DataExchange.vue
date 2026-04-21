<template>
  <div class="page">
    <el-card>
      <template #header>
        <div class="head">
          <span>数据导入导出中心</span>
        </div>
      </template>

      <el-space wrap>
        <el-button @click="downloadTemplate('csv')">下载CSV模板</el-button>
        <el-button @click="downloadTemplate('xlsx')">下载Excel模板</el-button>
        <el-button type="success" @click="exportData('csv')">导出CSV</el-button>
        <el-button type="success" @click="exportData('xlsx')">导出Excel</el-button>
      </el-space>

      <el-divider />

      <el-upload
        ref="uploader"
        drag
        :auto-upload="false"
        :on-change="onFileChange"
        :limit="1"
        accept=".csv,.xlsx"
      >
        <el-icon><upload-filled /></el-icon>
        <div>拖拽文件到此，或点击上传（CSV/XLSX）</div>
      </el-upload>

      <el-button style="margin-top:12px" type="primary" :disabled="!file" @click="importData">开始导入</el-button>

      <el-descriptions v-if="receipt" :column="4" border style="margin-top:12px">
        <el-descriptions-item label="总行数">{{ receipt.total }}</el-descriptions-item>
        <el-descriptions-item label="成功">{{ receipt.success }}</el-descriptions-item>
        <el-descriptions-item label="失败">{{ receipt.failed }}</el-descriptions-item>
        <el-descriptions-item label="异常条数">{{ (receipt.errors || []).length }}</el-descriptions-item>
      </el-descriptions>

      <el-table v-if="receipt && receipt.errors && receipt.errors.length" :data="receipt.errors.map(e => ({ e }))" style="margin-top:12px">
        <el-table-column prop="e" label="异常回执" min-width="480" />
      </el-table>
    </el-card>
  </div>
</template>

<script>
import api from '@/api/client'
import { UploadFilled } from '@element-plus/icons-vue'

export default {
  name: 'DataExchange',
  components: { UploadFilled },
  data() {
    return { file: null, receipt: null }
  },
  methods: {
    onFileChange(f) { this.file = f.raw; this.receipt = null },
    downloadTemplate(format) {
      window.open(`/api/feature/data/template/drug?format=${format}`, '_blank')
    },
    exportData(format) {
      window.open(`/api/feature/data/export/drug?format=${format}`, '_blank')
    },
    importData() {
      const fd = new FormData()
      fd.append('file', this.file)
      api.post('/api/feature/data/import/drug', fd, {
        headers: { 'Content-Type': 'multipart/form-data' }
      }).then((res) => {
        this.receipt = res.data.data
        this.$message.success('导入完成')
      })
    }
  }
}
</script>

<style scoped>
.page { padding: 20px; }
.head { display:flex; justify-content:space-between; align-items:center; }
</style>
