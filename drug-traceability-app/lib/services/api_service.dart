import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_model.dart';

class ApiException implements Exception {
  final int? code;
  final String message;

  ApiException(this.message, {this.code});

  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  static String _webToken = '';

  final String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _readToken();
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          _handleUnauthorized();
        }
        handler.next(error);
      },
    ));
  }

  void setWebToken(String token) {
    _webToken = token;
  }

  Future<String> _readToken() async {
    if (kIsWeb) {
      return _webToken;
    }
    final userBox = await Hive.openBox<User>('userBox');
    final user = userBox.get('currentUser');
    return user?.token ?? '';
  }

  Future<void> _handleUnauthorized() async {
    if (kIsWeb) {
      _webToken = '';
      return;
    }
    final userBox = await Hive.openBox<User>('userBox');
    await userBox.delete('currentUser');
  }

  Future<Map<String, dynamic>> _request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: query,
        options: Options(method: method),
      );
      final payload = Map<String, dynamic>.from(response.data as Map);
      final code = payload['code'];
      if (code != null && code != 200) {
        throw ApiException(
          payload['message']?.toString() ?? 'request failed',
          code: code is int ? code : null,
        );
      }
      return payload;
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['message']?.toString() ?? 'network request failed')
          : (e.message ?? 'network request failed');
      throw ApiException(msg, code: e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) {
    return _request('/auth/login', method: 'POST', data: {
      'username': username,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) {
    return _request('/auth/register', method: 'POST', data: data);
  }

  Future<Map<String, dynamic>> getDrugTrace(String batchId) {
    return _request('/trace/batch/$batchId');
  }

  Future<Map<String, dynamic>> getPublicTrace(String code) {
    return _request('/trace/public/$code');
  }

  Future<Map<String, dynamic>> getBatchByNumber(String batchNumber) {
    return _request('/trace/batch/number/$batchNumber');
  }

  Future<Map<String, dynamic>> getDrugByCode(String code) {
    return _request('/drug/info/code/$code');
  }

  Future<Map<String, dynamic>> searchDrug(String keyword) {
    return _request('/drug/info/search', query: {'keyword': keyword});
  }

  String normalizeScanCode(String raw) {
    String code = raw.trim();
    if (code.isEmpty) return code;

    if (code.contains('?')) {
      code = code.split('?').first;
    }
    if (code.contains('#')) {
      code = code.split('#').first;
    }
    if (code.contains('/')) {
      final parts = code.split('/').where((e) => e.isNotEmpty).toList();
      if (parts.isNotEmpty) {
        code = parts.last;
      }
    }
    return code.trim();
  }

  Future<Map<String, dynamic>> resolveTraceByScanCode(String rawCode) async {
    final code = normalizeScanCode(rawCode);
    if (code.isEmpty) {
      throw ApiException('empty scan code');
    }

    try {
      final trace = await getPublicTrace(code);
      return {
        'type': 'trace',
        'code': code,
        'data': trace['data'],
      };
    } catch (_) {
      // fallback
    }

    try {
      final batch = await getBatchByNumber(code);
      return {
        'type': 'batch',
        'code': code,
        'data': batch['data'],
      };
    } catch (_) {
      // fallback
    }

    try {
      final drug = await getDrugByCode(code);
      return {
        'type': 'drug',
        'code': code,
        'data': drug['data'],
      };
    } catch (_) {
      // fallback
    }

    final search = await searchDrug(code);
    final list = (search['data'] is List) ? List.from(search['data']) : <dynamic>[];
    if (list.isNotEmpty) {
      return {
        'type': 'drug',
        'code': code,
        'data': list.first,
      };
    }

    throw ApiException('no matching drug or trace record found for $code');
  }

  Future<Map<String, dynamic>> resolveDrugForUsageByScanCode(String rawCode) async {
    final code = normalizeScanCode(rawCode);
    if (code.isEmpty) {
      throw ApiException('empty scan code');
    }

    try {
      final drug = await getDrugByCode(code);
      return {
        'code': code,
        'data': drug['data'],
      };
    } catch (_) {
      final search = await searchDrug(code);
      final list = (search['data'] is List) ? List.from(search['data']) : <dynamic>[];
      if (list.isNotEmpty) {
        return {
          'code': code,
          'data': list.first,
        };
      }
      throw ApiException('no matching drug found for $code');
    }
  }

  Future<Map<String, dynamic>> warehouseIn(Map<String, dynamic> data) {
    return _request('/trace/procurement', method: 'POST', data: data);
  }

  Future<Map<String, dynamic>> warehouseOut(Map<String, dynamic> data) {
    return _request('/trace/sale', method: 'POST', data: data);
  }

  Future<Map<String, dynamic>> getInventory() {
    return _request('/trace/inventory');
  }

  Future<Map<String, dynamic>> submitUsageRecord(Map<String, dynamic> data) {
    return _request('/trace/usage/record', method: 'POST', data: data);
  }

  Future<Map<String, dynamic>> submitAdverseReaction(Map<String, dynamic> data) {
    return _request('/trace/adverse/submit', method: 'POST', data: data);
  }

  Future<Map<String, dynamic>> submitEnforcementRecord(Map<String, dynamic> data) {
    return _request('/regulatory/enforcement', method: 'POST', data: data);
  }

  Future<Map<String, dynamic>> getRiskMap() {
    return _request('/regulatory/stats/risk-map');
  }

  Future<Map<String, dynamic>> aiChat(Map<String, dynamic> data) {
    return _request('/api/ai/chat', method: 'POST', data: data);
  }

  Future<Map<String, dynamic>> getConversations() {
    return _request('/api/ai/conversations');
  }

  Future<Map<String, dynamic>> getMessages(String conversationId) {
    return _request('/api/ai/conversations/$conversationId/messages');
  }

  Future<Map<String, dynamic>> uploadKnowledge(Map<String, dynamic> data) {
    return _request('/api/ai/knowledge/upload', method: 'POST', data: data);
  }

  Future<Map<String, dynamic>> getCirculationStats(Map<String, dynamic> params) {
    return _request('/regulatory/stats/circulation', query: params);
  }

  Future<Map<String, dynamic>> getHistoryRecords() {
    return _request('/trace/usage/records');
  }

  Future<Map<String, dynamic>> getInventoryList() {
    return _request('/trace/inventory');
  }
}
