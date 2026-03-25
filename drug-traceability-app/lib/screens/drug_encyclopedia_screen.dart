import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';

class DrugEncyclopediaScreen extends ConsumerStatefulWidget {
  const DrugEncyclopediaScreen({super.key});

  @override
  ConsumerState<DrugEncyclopediaScreen> createState() =>
      _DrugEncyclopediaScreenState();
}

class _DrugEncyclopediaScreenState
    extends ConsumerState<DrugEncyclopediaScreen> {
  final _apiService = ApiService();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _drugs = [];
  List<Map<String, dynamic>> _filteredDrugs = [];
  bool _isLoading = false;
  String? _selectedCategory;
  final List<String> _categories = [
    '全部',
    '抗生素',
    '解热镇痛',
    '心血管',
    '消化系统',
    '呼吸系统',
    '内分泌'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadMockDrugs();
  }

  void _loadMockDrugs() {
    _drugs = [
      {
        'name': '阿莫西林胶囊',
        'genericName': '阿莫西林',
        'approvalNumber': '国药准字H20053456',
        'manufacturer': '华北制药集团',
        'ingredients': '阿莫西林',
        'indications': '用于敏感菌引起的感染',
        'category': '抗生素',
        'description': '白色或类白色粉末',
        'pharmacology': '抑制细菌细胞壁合成',
        'pharmacokinetics': '口服吸收良好',
        'adultDosage': '一次0.5g，一日3次',
        'pediatricDosage': '按体重计算',
        'usage': '口服',
        'adverseReactions': '恶心、腹泻',
        'seriousAdverseReactions': '过敏性休克',
        'contraindications': '青霉素皮试阳性者禁用',
        'precautions': '青霉素过敏者慎用',
        'specialPopulation': '孕妇及哺乳期妇女慎用',
      },
      {
        'name': '布洛芬缓释胶囊',
        'genericName': '布洛芬',
        'approvalNumber': '国药准字H20012345',
        'manufacturer': '强生制药',
        'ingredients': '布洛芬',
        'indications': '用于缓解轻至中度疼痛',
        'category': '解热镇痛',
        'description': '淡黄色缓释胶囊',
        'pharmacology': '抑制前列腺素合成',
        'pharmacokinetics': '口服吸收快',
        'adultDosage': '一次0.3g，一日2次',
        'pediatricDosage': '按体重计算',
        'usage': '口服',
        'adverseReactions': '胃肠道不适',
        'seriousAdverseReactions': '消化道出血',
        'contraindications': '对本品过敏者禁用',
        'precautions': '胃溃疡患者慎用',
        'specialPopulation': '孕妇晚期慎用',
      },
      {
        'name': '硝苯地平片',
        'genericName': '硝苯地平',
        'approvalNumber': '国药准字H20026789',
        'manufacturer': '拜耳制药',
        'ingredients': '硝苯地平',
        'indications': '用于高血压、心绞痛',
        'category': '心血管',
        'description': '黄色片剂',
        'pharmacology': '钙通道阻滞剂',
        'pharmacokinetics': '口服吸收快',
        'adultDosage': '一次10mg，一日3次',
        'pediatricDosage': '儿童慎用',
        'usage': '口服',
        'adverseReactions': '头痛、面部潮红',
        'seriousAdverseReactions': '低血压',
        'contraindications': '心源性休克禁用',
        'precautions': '肝功能不全者慎用',
        'specialPopulation': '孕妇慎用',
      },
      {
        'name': '奥美拉唑肠溶胶囊',
        'genericName': '奥美拉唑',
        'approvalNumber': '国药准字H20031234',
        'manufacturer': '阿斯利康',
        'ingredients': '奥美拉唑',
        'indications': '用于胃溃疡、反流性食管炎',
        'category': '消化系统',
        'description': '肠溶胶囊',
        'pharmacology': '质子泵抑制剂',
        'pharmacokinetics': '口服吸收快',
        'adultDosage': '一次20mg，一日1次',
        'pediatricDosage': '儿童慎用',
        'usage': '口服',
        'adverseReactions': '头痛、便秘',
        'seriousAdverseReactions': '维生素B12缺乏',
        'contraindications': '对本品过敏者禁用',
        'precautions': '长期服用需监测',
        'specialPopulation': '孕妇慎用',
      },
      {
        'name': '沙美特罗替卡松吸入剂',
        'genericName': '沙美特罗/氟替卡松',
        'approvalNumber': '国药准字H20045678',
        'manufacturer': '葛兰素史克',
        'ingredients': '沙美特罗、氟替卡松',
        'indications': '用于哮喘、COPD',
        'category': '呼吸系统',
        'description': '吸入剂',
        'pharmacology': 'β2受体激动剂+糖皮质激素',
        'pharmacokinetics': '肺部吸收',
        'adultDosage': '一次2吸，一日2次',
        'pediatricDosage': '儿童剂量需调整',
        'usage': '吸入',
        'adverseReactions': '口干、咳嗽',
        'seriousAdverseReactions': ' paradoxical bronchospasm',
        'contraindications': '对本品过敏者禁用',
        'precautions': '不得用于缓解急性症状',
        'specialPopulation': '孕妇慎用',
      },
      {
        'name': '二甲双胍片',
        'genericName': '二甲双胍',
        'approvalNumber': '国药准字H20059012',
        'manufacturer': '默克制药',
        'ingredients': '二甲双胍',
        'indications': '用于2型糖尿病',
        'category': '内分泌',
        'description': '白色片剂',
        'pharmacology': '双胍类降糖药',
        'pharmacokinetics': '口服吸收快',
        'adultDosage': '一次0.5g，一日2-3次',
        'pediatricDosage': '儿童慎用',
        'usage': '口服',
        'adverseReactions': '胃肠道反应',
        'seriousAdverseReactions': '乳酸酸中毒',
        'contraindications': '肾功能不全禁用',
        'precautions': '避免饮酒',
        'specialPopulation': '孕妇慎用',
      },
    ];
    _filteredDrugs = _drugs;
  }

  void _filterDrugs() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty && _selectedCategory == null) {
        _filteredDrugs = _drugs;
      } else {
        _filteredDrugs = _drugs.where((drug) {
          final matchesSearch = query.isEmpty ||
              (drug['name']?.toLowerCase().contains(query) ?? false) ||
              (drug['genericName']?.toLowerCase().contains(query) ?? false);
          final matchesCategory = _selectedCategory == null ||
              _selectedCategory == '全部' ||
              (drug['category'] == _selectedCategory);
          return matchesSearch && matchesCategory;
        }).toList();
      }
    });
  }

  void _selectCategory(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterDrugs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('药品百科'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () => _showCategoryDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDrugs.isEmpty
                    ? _buildEmptyState()
                    : _buildDrugList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索药品名称或通用名...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (_) => _filterDrugs(),
        onSubmitted: (_) => _filterDrugs(),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return FilterChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (selected) =>
                _selectCategory(selected ? category : null),
            backgroundColor: Colors.grey[100],
            selectedColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无药品数据',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请尝试搜索其他药品或选择其他分类',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredDrugs.length,
      itemBuilder: (context, index) {
        final drug = _filteredDrugs[index];
        return _buildDrugCard(drug);
      },
    );
  }

  Widget _buildDrugCard(Map<String, dynamic> drug) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showDrugDetail(drug),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.medication,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drug['name'] ?? '未知药品',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          drug['genericName'] ?? '通用名：未知',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDrugInfoRow('批准文号', drug['approvalNumber'] ?? '未知'),
              _buildDrugInfoRow('生产企业', drug['manufacturer'] ?? '未知'),
              _buildDrugInfoRow('成分', drug['ingredients'] ?? '未知'),
              _buildDrugInfoRow('适应症', drug['indications'] ?? '未知'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrugInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label：',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDrugDetail(Map<String, dynamic> drug) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
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
                    Text(
                      drug['name'] ?? '药品详情',
                      style: const TextStyle(
                        fontSize: 20,
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
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildDetailSection('药品信息', [
                      _buildDetailRow('药品名称', drug['name'] ?? '未知'),
                      _buildDetailRow('通用名', drug['genericName'] ?? '未知'),
                      _buildDetailRow('批准文号', drug['approvalNumber'] ?? '未知'),
                      _buildDetailRow('生产企业', drug['manufacturer'] ?? '未知'),
                      _buildDetailRow('成分', drug['ingredients'] ?? '未知'),
                      _buildDetailRow('性状', drug['description'] ?? '未知'),
                    ]),
                    const SizedBox(height: 16),
                    _buildDetailSection('药理作用', [
                      _buildDetailRow('药理作用', drug['pharmacology'] ?? '未知'),
                      _buildDetailRow(
                          '药代动力学', drug['pharmacokinetics'] ?? '未知'),
                    ]),
                    const SizedBox(height: 16),
                    _buildDetailSection('用法用量', [
                      _buildDetailRow('成人用量', drug['adultDosage'] ?? '未知'),
                      _buildDetailRow('儿童用量', drug['pediatricDosage'] ?? '未知'),
                      _buildDetailRow('用法', drug['usage'] ?? '未知'),
                    ]),
                    const SizedBox(height: 16),
                    _buildDetailSection('不良反应', [
                      _buildDetailRow(
                          '常见不良反应', drug['adverseReactions'] ?? '未知'),
                      _buildDetailRow(
                          '严重不良反应', drug['seriousAdverseReactions'] ?? '未知'),
                    ]),
                    const SizedBox(height: 16),
                    _buildDetailSection('注意事项', [
                      _buildDetailRow('禁忌症', drug['contraindications'] ?? '未知'),
                      _buildDetailRow('注意事项', drug['precautions'] ?? '未知'),
                      _buildDetailRow(
                          '特殊人群用药', drug['specialPopulation'] ?? '未知'),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label：',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择分类'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _categories.map((category) {
              return ListTile(
                title: Text(category),
                selected: _selectedCategory == category,
                selectedTileColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                  _filterDrugs();
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
