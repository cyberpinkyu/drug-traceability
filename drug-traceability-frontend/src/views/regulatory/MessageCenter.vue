<template>
  <div class="page">
    <el-tabs v-model="active">
      <el-tab-pane label="消息中心" name="messages">
        <el-card>
          <template #header>
            <div class="head">
              <span>站内信 / 短信 / 邮件</span>
              <el-button type="primary" @click="openMessage">发送消息</el-button>
            </div>
          </template>
          <el-table :data="messages" stripe>
            <el-table-column prop="id" label="ID" width="80" />
            <el-table-column prop="title" label="标题" min-width="180" />
            <el-table-column prop="channel" label="渠道" width="120" />
            <el-table-column prop="receiverId" label="接收人ID" width="110" />
            <el-table-column prop="status" label="状态" width="100">
              <template #default="scope">
                <el-tag :type="scope.row.status === 1 ? 'success' : 'warning'">
                  {{ scope.row.status === 1 ? '已读' : '未读' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="createdAt" label="创建时间" min-width="170" />
            <el-table-column label="操作" width="100">
              <template #default="scope">
                <el-button size="small" @click="markRead(scope.row.id)">已读</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>

      <el-tab-pane label="预警闭环工单" name="tickets">
        <el-card>
          <template #header>
            <div class="head">
              <span>工单列表</span>
              <el-button type="primary" @click="openTicket">新建工单</el-button>
            </div>
          </template>
          <el-table :data="tickets" stripe>
            <el-table-column prop="id" label="ID" width="80" />
            <el-table-column prop="title" label="标题" min-width="180" />
            <el-table-column prop="severity" label="级别" width="100" />
            <el-table-column prop="assigneeId" label="处理人" width="100" />
            <el-table-column prop="status" label="状态" width="120">
              <template #default="scope">
                <el-tag :type="scope.row.status === 2 ? 'success' : (scope.row.status === 1 ? 'warning' : 'info')">
                  {{ scope.row.status === 2 ? '已关闭' : (scope.row.status === 1 ? '处理中' : '待处理') }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="description" label="描述" min-width="220" />
            <el-table-column label="操作" min-width="200">
              <template #default="scope">
                <el-button size="small" @click="assign(scope.row)">派单</el-button>
                <el-button size="small" type="success" :disabled="scope.row.status===2" @click="closeTicket(scope.row)">关闭</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>
    </el-tabs>

    <el-dialog v-model="messageVisible" title="发送消息" width="560px">
      <el-form :model="messageForm" label-width="100px">
        <el-form-item label="标题"><el-input v-model="messageForm.title" /></el-form-item>
        <el-form-item label="内容"><el-input type="textarea" :rows="4" v-model="messageForm.content" /></el-form-item>
        <el-form-item label="渠道">
          <el-select v-model="messageForm.channel" style="width:100%">
            <el-option label="站内信" value="site" />
            <el-option label="短信" value="sms" />
            <el-option label="邮件" value="email" />
          </el-select>
        </el-form-item>
        <el-form-item label="接收人ID"><el-input v-model.number="messageForm.receiverId" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="messageVisible=false">取消</el-button>
        <el-button type="primary" @click="sendMessage">发送</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="ticketVisible" title="新建工单" width="560px">
      <el-form :model="ticketForm" label-width="100px">
        <el-form-item label="标题"><el-input v-model="ticketForm.title" /></el-form-item>
        <el-form-item label="级别">
          <el-select v-model="ticketForm.severity" style="width:100%">
            <el-option label="低" value="low" />
            <el-option label="中" value="medium" />
            <el-option label="高" value="high" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述"><el-input type="textarea" :rows="4" v-model="ticketForm.description" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="ticketVisible=false">取消</el-button>
        <el-button type="primary" @click="createTicket">创建</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import api from '@/api/client'

export default {
  name: 'MessageCenter',
  data() {
    return {
      active: 'messages',
      messages: [],
      tickets: [],
      messageVisible: false,
      ticketVisible: false,
      messageForm: { title: '', content: '', channel: 'site', receiverId: null },
      ticketForm: { title: '', severity: 'medium', description: '' }
    }
  },
  mounted() { this.bootstrap() },
  methods: {
    bootstrap() { this.loadMessages(); this.loadTickets() },
    loadMessages() { api.get('/api/feature/messages').then((r) => { this.messages = r.data.data || [] }) },
    loadTickets() { api.get('/api/feature/tickets').then((r) => { this.tickets = r.data.data || [] }) },
    openMessage() { this.messageVisible = true },
    openTicket() { this.ticketVisible = true },
    sendMessage() {
      api.post('/api/feature/messages', this.messageForm).then(() => {
        this.$message.success('发送成功'); this.messageVisible = false; this.loadMessages()
      })
    },
    markRead(id) { api.put(`/api/feature/messages/${id}/read`).then(() => this.loadMessages()) },
    createTicket() {
      api.post('/api/feature/tickets', this.ticketForm).then(() => {
        this.$message.success('工单已创建'); this.ticketVisible = false; this.loadTickets()
      })
    },
    assign(row) {
      this.$prompt('请输入处理人ID', '派单', { inputPattern: /^\d+$/, inputErrorMessage: '必须是数字' })
        .then(({ value }) => api.put(`/api/feature/tickets/${row.id}/assign`, { assigneeId: Number(value) }).then(() => this.loadTickets()))
        .catch(() => {})
    },
    closeTicket(row) {
      this.$prompt('请输入关闭结论', '关闭工单', { inputValue: row.closedResult || '' })
        .then(({ value }) => api.put(`/api/feature/tickets/${row.id}/close`, { closedResult: value }).then(() => this.loadTickets()))
        .catch(() => {})
    }
  }
}
</script>

<style scoped>
.page { padding: 20px; }
.head { display:flex; justify-content:space-between; align-items:center; }
</style>
