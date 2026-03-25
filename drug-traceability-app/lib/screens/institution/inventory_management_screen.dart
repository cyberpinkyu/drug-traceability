import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  final _apiService = ApiService();
  List<Map<String, dynamic>> _inventoryItems = [];
  bool _isLoading = true;
  String _searchText = '';
  String _selectedCategory = '全部';

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getInventoryList();

      if (response['code'] == 200) {
        setState(() {
          _inventoryItems =
              List<Map<String, dynamic>>.from(response['data'] ?? []);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredInventory {
    return _inventoryItems.where((item) {
      final nameMatch =
          item['drugName']?.toLowerCase().contains(_searchText.toLowerCase()) ??
              false;
      final categoryMatch =
          _selectedCategory == '全部' || item['category'] == _selectedCategory;
      return nameMatch && categoryMatch;
    }).toList();
  }

  String _getStockStatus(int quantity) {
    if (quantity == 0) return '缺货';
    if (quantity < 100) return '告警';
    return '正常';
  }

  Color _getStockStatusColor(int quantity) {
    if (quantity == 0) return Colors.red;
    if (quantity < 100) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('库存管理'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInventory,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(child: _buildInventoryList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStockDialog(),
        icon: const Icon(Icons.add),
        label: const Text('新增入库'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: '搜索药品名称...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      '全部',
      '抗生素',
      '解热镇痛',
      '心血管',
      '消化系统',
      '内分泌',
      '呼吸系统',
      '维生素'
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildInventoryList() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _filteredInventory.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredInventory.length,
                itemBuilder: (context, index) {
                  final item = _filteredInventory[index];
                  return _buildInventoryCard(item);
                },
              );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '暂无库存数据',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadInventory,
            icon: const Icon(Icons.refresh),
            label: const Text('重新加载'),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(Map<String, dynamic> item) {
    final quantity = item['quantity'] ?? 0;
    final stockStatus = _getStockStatus(quantity);
    final stockStatusColor = _getStockStatusColor(quantity);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal[100],
          child: Icon(
            Icons.medication,
            color: Colors.teal[700],
          ),
        ),
        title: Text(
          item['drugName'] ?? '未知药品',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('批号: ${item['batchNumber'] ?? '未知'}'),
            Text('规格: ${item['specification'] ?? '未知'}'),
            Text('生产日期: ${item['productionDate'] ?? '未知'}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$quantity',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: stockStatusColor,
              ),
            ),
            Text(
              stockStatus,
              style: TextStyle(
                fontSize: 12,
                color: stockStatusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showAddStockDialog() {
    final _drugNameController = TextEditingController();
    final _batchController = TextEditingController();
    final _quantityController = TextEditingController();
    final _specificationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增入库'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _drugNameController,
              decoration: InputDecoration(
                labelText: '药品名称',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _specificationController,
              decoration: InputDecoration(
                labelText: '规格',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _batchController,
              decoration: InputDecoration(
                labelText: '批号',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: '数量',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (_drugNameController.text.isEmpty ||
                  _batchController.text.isEmpty ||
                  _quantityController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请填写必填信息')),
                );
                return;
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('入库成功')),
              );
              _loadInventory();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
