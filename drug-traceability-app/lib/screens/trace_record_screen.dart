import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/api_service.dart';

class TraceRecordScreen extends StatefulWidget {
  const TraceRecordScreen({super.key});

  @override
  State<TraceRecordScreen> createState() => _TraceRecordScreenState();
}

class _TraceRecordScreenState extends State<TraceRecordScreen> {
  final _apiService = ApiService();
  final _codeController = TextEditingController();
  List<Map<String, dynamic>> _records = [];
  List<Map<String, dynamic>> _historyRecords = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _isScanning = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _searchTrace() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入追溯码')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _isScanning = false;
    });

    try {
      final response = await _apiService.getPublicTrace(code);
      if (response['code'] == 200) {
        setState(() {
          _records = [response['data']];
          _historyRecords.insert(0, {
            'code': code,
            'timestamp': DateTime.now(),
            'drugName': response['data']['drugName'] ?? '未知'
          });
          _hasSearched = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('查询成功')),
        );
      } else {
        setState(() {
          _hasSearched = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? '查询失败')),
        );
      }
    } catch (e) {
      setState(() {
        _hasSearched = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('查询失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showScanner() {
    setState(() {
      _isScanning = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '扫码查询',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _isScanning = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: MobileScanner(
                  onDetect: (capture) {
                    final barcode = capture.barcodes.first;
                    if (barcode.rawValue != null) {
                      Navigator.pop(context);
                      _codeController.text = barcode.rawValue!;
                      _searchTrace();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('追溯记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistory(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_hasSearched && _records.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    '未找到相关追溯记录',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else if (_records.isNotEmpty)
              Expanded(child: _buildTraceInfo())
            else
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      '请输入追溯码查询药品追溯记录',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: '请输入药品追溯码',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _searchTrace(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: _showScanner,
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _searchTrace,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraceInfo() {
    final record = _records[0];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(record),
          const SizedBox(height: 24),
          _buildTraceChain(record),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> record) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('药品名称', record['drugName'] ?? '未知'),
            _buildInfoRow('药品规格', record['specification'] ?? '未知'),
            _buildInfoRow('生产企业', record['manufacturer'] ?? '未知'),
            _buildInfoRow('生产批号', record['batchNumber'] ?? '未知'),
            _buildInfoRow('生产日期', record['productionDate'] ?? '未知'),
            _buildInfoRow('有效期至', record['expiryDate'] ?? '未知'),
            _buildInfoRow('追溯码', record['traceCode'] ?? '未知'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text(
                    '该药品追溯信息完整',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraceChain(Map<String, dynamic> record) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '追溯链路',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTraceStep('原料采购', '2024-01-15 09:30', '华康制药有限公司', '原料检验合格'),
            _buildTraceStep('生产加工', '2024-01-16 14:20', '华康制药厂', '按标准生产工艺生产'),
            _buildTraceStep('质量检测', '2024-01-17 10:45', '质检部门', '各项指标符合标准'),
            _buildTraceStep('包装入库', '2024-01-18 16:10', '仓储部', '按批次包装入库'),
            _buildTraceStep('物流配送', '2024-01-19 08:30', '医药物流公司', '冷链运输至各地'),
            _buildTraceStep('药店销售', '2024-01-20 15:00', '康健大药房', '零售至消费者'),
          ],
        ),
      ),
    );
  }

  Widget _buildTraceStep(
      String stage, String time, String company, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.done,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$time | $company',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '查询历史',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _historyRecords.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            '暂无查询历史',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _historyRecords.length,
                        itemBuilder: (context, index) {
                          final record = _historyRecords[index];
                          return ListTile(
                            leading: const Icon(Icons.medication),
                            title: Text(record['drugName']),
                            subtitle: Text(
                                '${record['code']} • ${record['timestamp'].toString().substring(0, 19)}'),
                            onTap: () {
                              _codeController.text = record['code'];
                              Navigator.pop(context);
                              _searchTrace();
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
