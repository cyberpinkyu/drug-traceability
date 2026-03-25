<template>
  <div class="regulatory-page">
    <el-tabs v-model="activeTab">
      <el-tab-pane label="待派发上报" name="reports">
        <el-card>
          <template #header>
            <div class="head">
              <span>公众问题上报池</span>
              <el-button @click="loadReports">刷新</el-button>
            </div>
          </template>
          <el-table :data="reports" stripe>
            <el-table-column prop="id" label="上报ID" width="90" />
            <el-table-column prop="drugId" label="药品ID" width="90" />
            <el-table-column prop="hospital" label="医疗机构" min-width="150" />
            <el-table-column prop="severity" label="严重级别" width="100" />
            <el-table-column prop="reactionDescription" label="问题描述" min-width="220" show-overflow-tooltip />
            <el-table-column label="状态" width="140">
              <template #default="scope">
                <el-tag :type="adverseStatusType(scope.row.status)">{{ adverseStatusText(scope.row.status) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="140" fixed="right">
              <template #default="scope">
                <el-button
                  type="primary"
                  size="small"
                  :disabled="scope.row.status !== 1"
                  @click="openDispatch(scope.row)"
                >
                  派发任务
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>

      <el-tab-pane label="监管任务" name="tasks">
        <el-card>
          <template #header>
            <div class="head">
              <span>任务列表</span>
              <div class="toolbar">
                <el-input
                  v-model="assigneeFilter"
                  placeholder="按监管员ID过滤"
                  clearable
                  style="width: 180px"
                />
                <el-button @click="loadTasks">刷新</el-button>
              </div>
            </div>
          </template>

          <el-table :data="filteredTasks" stripe>
            <el-table-column prop="id" label="任务ID" width="90" />
            <el-table-column prop="reportId" label="上报ID" width="90" />
            <el-table-column prop="assigneeId" label="监管员ID" width="100" />
            <el-table-column prop="suspectedSource" label="疑似来源" width="120">
              <template #default="scope">
                {{ sourceText(scope.row.suspectedSource) }}
              </template>
            </el-table-column>
            <el-table-column prop="conclusionSource" label="调查结论" width="120">
              <template #default="scope">
                {{ sourceText(scope.row.conclusionSource) }}
              </template>
            </el-table-column>
            <el-table-column prop="verified" label="是否属实" width="110">
              <template #default="scope">
                <el-tag :type="scope.row.verified === 1 ? 'danger' : 'info'">
                  {{ scope.row.verified === 1 ? '属实' : '待定/不属实' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="status" label="任务状态" width="120">
              <template #default="scope">
                <el-tag :type="taskStatusType(scope.row.status)">{{ taskStatusText(scope.row.status) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="investigationResult" label="调查说明" min-width="220" show-overflow-tooltip />
            <el-table-column label="操作" min-width="230" fixed="right">
              <template #default="scope">
                <el-button
                  size="small"
                  type="primary"
                  :disabled="scope.row.status !== 1"
                  @click="openInvestigation(scope.row)"
                >
                  提交调查
                </el-button>
                <el-button
                  size="small"
                  type="danger"
                  :disabled="!(scope.row.status === 2 && scope.row.verified === 1)"
                  @click="openEnforcement(scope.row)"
                >
                  处罚/警告
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>

      <el-tab-pane label="执法记录" name="enforcements">
        <el-card>
          <template #header>
            <div class="head">
              <span>处罚/警告记录</span>
              <el-button @click="loadEnforcements">刷新</el-button>
            </div>
          </template>
          <el-table :data="enforcements" stripe>
            <el-table-column prop="id" label="记录ID" width="90" />
            <el-table-column prop="inspectorId" label="监管员ID" width="100" />
            <el-table-column prop="organizationId" label="涉事单位ID" width="110" />
            <el-table-column prop="inspectionType" label="处理类型" width="120" />
            <el-table-column prop="inspectionResult" label="处理结果" min-width="180" />
            <el-table-column prop="description" label="说明" min-width="220" show-overflow-tooltip />
            <el-table-column prop="inspectionDate" label="执行时间" min-width="170" />
          </el-table>
        </el-card>
      </el-tab-pane>
    </el-tabs>

    <el-dialog v-model="dispatchVisible" title="派发监管任务" width="560px">
      <el-form :model="dispatchForm" label-width="120px">
        <el-form-item label="上报ID">
          <el-input v-model="dispatchForm.reportId" disabled />
        </el-form-item>
        <el-form-item label="监管员">
          <el-select v-model="dispatchForm.assigneeId" placeholder="选择监管员" style="width: 100%">
            <el-option v-for="u in inspectors" :key="u.id" :label="`${u.name} (ID:${u.id})`" :value="u.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="疑似来源">
          <el-select v-model="dispatchForm.suspectedSource" style="width: 100%">
            <el-option label="药厂" value="manufacturer" />
            <el-option label="医疗机构" value="institution" />
          </el-select>
        </el-form-item>
        <el-form-item label="疑似单位ID">
          <el-input v-model.number="dispatchForm.suspectedOrgId" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dispatchVisible = false">取消</el-button>
        <el-button type="primary" @click="submitDispatch">确认派发</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="investigationVisible" title="提交调查结论" width="620px">
      <el-form :model="investigationForm" label-width="130px">
        <el-form-item label="任务ID">
          <el-input v-model="investigationForm.taskId" disabled />
        </el-form-item>
        <el-form-item label="问题来源结论">
          <el-select v-model="investigationForm.conclusionSource" style="width: 100%">
            <el-option label="药厂" value="manufacturer" />
            <el-option label="医疗机构" value="institution" />
          </el-select>
        </el-form-item>
        <el-form-item label="责任单位ID">
          <el-input v-model.number="investigationForm.conclusionOrgId" />
        </el-form-item>
        <el-form-item label="是否属实">
          <el-radio-group v-model="investigationForm.verified">
            <el-radio :label="1">属实</el-radio>
            <el-radio :label="0">不属实</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="调查说明">
          <el-input v-model="investigationForm.investigationResult" type="textarea" :rows="4" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="investigationVisible = false">取消</el-button>
        <el-button type="primary" @click="submitInvestigation">提交结论</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="enforcementVisible" title="执行处罚/警告" width="620px">
      <el-form :model="enforcementForm" label-width="130px">
        <el-form-item label="任务ID">
          <el-input v-model="enforcementForm.taskId" disabled />
        </el-form-item>
        <el-form-item label="处理类型">
          <el-select v-model="enforcementForm.actionType" style="width: 100%">
            <el-option label="警告" value="warning" />
            <el-option label="处罚" value="penalty" />
          </el-select>
        </el-form-item>
        <el-form-item label="处理结果">
          <el-input v-model="enforcementForm.inspectionResult" />
        </el-form-item>
        <el-form-item label="处罚说明">
          <el-input v-model="enforcementForm.description" type="textarea" :rows="4" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="enforcementVisible = false">取消</el-button>
        <el-button type="danger" @click="submitEnforcement">确认执行</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import api from '@/api/client'

export default {
  name: 'EnforcementList',
  data() {
    return {
      activeTab: 'reports',
      reports: [],
      inspectors: [],
      tasks: [],
      enforcements: [],
      assigneeFilter: '',

      dispatchVisible: false,
      dispatchForm: {
        reportId: null,
        assigneeId: null,
        suspectedSource: 'manufacturer',
        suspectedOrgId: null
      },

      investigationVisible: false,
      investigationForm: {
        taskId: null,
        conclusionSource: 'manufacturer',
        conclusionOrgId: null,
        verified: 1,
        investigationResult: ''
      },

      enforcementVisible: false,
      enforcementForm: {
        taskId: null,
        actionType: 'warning',
        inspectionResult: '',
        description: ''
      }
    }
  },
  computed: {
    filteredTasks() {
      if (!this.assigneeFilter) return this.tasks
      return this.tasks.filter((t) => String(t.assigneeId) === String(this.assigneeFilter))
    }
  },
  mounted() {
    this.bootstrap()
  },
  methods: {
    bootstrap() {
      this.loadReports()
      this.loadInspectors()
      this.loadTasks()
      this.loadEnforcements()
    },
    loadReports() {
      api.get('/api/trace/adverse/records').then((r) => {
        this.reports = r.data.data || []
      })
    },
    loadInspectors() {
      api.get('/api/regulatory/inspectors').then((r) => {
        this.inspectors = r.data.data || []
      })
    },
    loadTasks() {
      api.get('/api/regulatory/tasks').then((r) => {
        this.tasks = r.data.data || []
      })
    },
    loadEnforcements() {
      api.get('/api/regulatory/enforcement').then((r) => {
        this.enforcements = r.data.data || []
      })
    },

    openDispatch(report) {
      this.dispatchForm = {
        reportId: report.id,
        assigneeId: null,
        suspectedSource: 'manufacturer',
        suspectedOrgId: null
      }
      this.dispatchVisible = true
    },
    submitDispatch() {
      if (!this.dispatchForm.assigneeId) {
        this.$message.error('请选择监管员')
        return
      }
      api.post('/api/regulatory/tasks/dispatch', this.dispatchForm).then(() => {
        this.$message.success('任务已派发')
        this.dispatchVisible = false
        this.bootstrap()
      })
    },

    openInvestigation(task) {
      this.investigationForm = {
        taskId: task.id,
        conclusionSource: task.suspectedSource || 'manufacturer',
        conclusionOrgId: task.suspectedOrgId || null,
        verified: 1,
        investigationResult: task.investigationResult || ''
      }
      this.investigationVisible = true
    },
    submitInvestigation() {
      const { taskId, ...payload } = this.investigationForm
      api.put(`/api/regulatory/tasks/${taskId}/investigation`, payload).then(() => {
        this.$message.success('调查结论已提交')
        this.investigationVisible = false
        this.bootstrap()
      })
    },

    openEnforcement(task) {
      this.enforcementForm = {
        taskId: task.id,
        actionType: 'warning',
        inspectionResult: '',
        description: ''
      }
      this.enforcementVisible = true
    },
    submitEnforcement() {
      if (!this.enforcementForm.inspectionResult) {
        this.$message.error('请填写处理结果')
        return
      }
      const { taskId, ...payload } = this.enforcementForm
      api.post(`/api/regulatory/tasks/${taskId}/enforcement`, payload).then(() => {
        this.$message.success('处罚/警告执行成功')
        this.enforcementVisible = false
        this.bootstrap()
      })
    },

    sourceText(v) {
      if (v === 'manufacturer') return '药厂'
      if (v === 'institution') return '医疗机构'
      return '-'
    },
    adverseStatusText(v) {
      const m = { 1: '待派发', 2: '待排查', 3: '属实待处置', 4: '已处置', 5: '不属实' }
      return m[v] || `未知(${v})`
    },
    taskStatusText(v) {
      const m = { 1: '已派发', 2: '已调查', 3: '已处置' }
      return m[v] || `未知(${v})`
    },
    adverseStatusType(v) {
      if (v === 4 || v === 3) return 'danger'
      if (v === 2) return 'warning'
      if (v === 5) return 'info'
      return 'success'
    },
    taskStatusType(v) {
      if (v === 3) return 'danger'
      if (v === 2) return 'warning'
      return 'success'
    }
  }
}
</script>

<style scoped>
.regulatory-page {
  padding: 20px;
}

.head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
}

.toolbar {
  display: flex;
  align-items: center;
  gap: 8px;
}
</style>
