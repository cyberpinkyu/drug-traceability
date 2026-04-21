<template>
  <div class="page">
    <el-card>
      <template #header><span>AI 助手</span></template>
      <div class="chat-list">
        <div v-for="(m, idx) in messages" :key="idx" class="msg">
          <b>{{ m.role }}:</b> {{ m.content }}
        </div>
      </div>
      <div class="bar">
        <el-input v-model="text" placeholder="输入问题" @keyup.enter="send" />
        <el-button type="primary" @click="send">发送</el-button>
      </div>
    </el-card>
  </div>
</template>
<script>
import api from '@/api/client'
export default {
  name: 'AIChat',
  data() {
    return { text: '', messages: [], conversationId: '' }
  },
  methods: {
    send() {
      if (!this.text.trim()) return
      api.post('/api/ai/chat', { message: this.text, conversationId: this.conversationId || null })
        .then((r) => {
          const data = r.data.data || {}
          this.conversationId = data.conversationId || this.conversationId
          this.messages.push({ role: 'user', content: this.text })
          this.messages.push({ role: 'assistant', content: data.response || '无响应' })
          this.text = ''
        })
    }
  }
}
</script>
<style scoped>
.page{padding:20px}.chat-list{min-height:300px;max-height:420px;overflow:auto;margin-bottom:12px}.msg{padding:8px 0;border-bottom:1px solid #f3f4f6}.bar{display:flex;gap:8px}
</style>
