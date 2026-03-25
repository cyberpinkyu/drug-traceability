import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_service.dart';
import 'ai_assistant_profile.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  final AIAssistantProfile profile;

  const AIChatScreen({super.key, required this.profile});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final _apiService = ApiService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  late final String _clientSessionId;
  List<Map<String, dynamic>> _messages = [];
  String? _conversationId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _clientSessionId = '${widget.profile.key}-${DateTime.now().millisecondsSinceEpoch}';
    _messages = [
      {
        'role': 'assistant',
        'content': widget.profile.welcome,
      }
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage({String? preset}) async {
    final raw = (preset ?? _messageController.text).trim();
    if (raw.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'role': 'user', 'content': raw});
      _isLoading = true;
    });

    _messageController.clear();

    try {
      final scopedMessage = '${widget.profile.scopePrompt}\n\n用户问题：$raw';
      final response = await _apiService.aiChat({
        'message': scopedMessage,
        'conversationId': _conversationId,
        'scene': widget.profile.key,
        'clientSessionId': _clientSessionId,
      });

      if (response['code'] == 200 && response['data'] is Map) {
        final data = Map<String, dynamic>.from(response['data'] as Map);
        setState(() {
          _conversationId = data['conversationId']?.toString();
          _messages.add({
            'role': 'assistant',
            'content': data['response']?.toString() ?? '已收到，请稍后重试。',
          });
        });
      } else {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': '抱歉，AI服务暂时不可用，请稍后再试。',
          });
        });
      }
    } catch (_) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': '网络异常，请检查连接后重试。',
        });
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile.title),
      ),
      body: Column(
        children: [
          _buildQuickPrompts(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('AI 正在思考...'),
                ],
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.profile.quickPrompts
            .map(
              (prompt) => ActionChip(
                label: Text(prompt),
                onPressed: _isLoading ? null : () => _sendMessage(preset: prompt),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['role'] == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.smart_toy, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                message['content']?.toString() ?? '',
                style: TextStyle(color: isUser ? Colors.white : Colors.black87),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[400],
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: widget.profile.inputHint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isLoading ? null : () => _sendMessage(),
            style: IconButton.styleFrom(
              backgroundColor:
                  _isLoading ? Colors.grey[300] : Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
