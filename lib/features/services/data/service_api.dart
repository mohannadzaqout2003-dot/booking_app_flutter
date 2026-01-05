import 'dart:convert';

import 'package:dio/dio.dart';

class ServiceApi {
  ServiceApi(this._dio);
  final Dio _dio;

  Future<List<dynamic>> getServicesList() async {
    final res = await _dio.get('/services');
    final data = res.data;

    Map<String, dynamic> map;

    if (data is Map<String, dynamic>) {
      map = data;
    } else if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        map = decoded;
      } else {
        throw Exception('Invalid JSON response for /services');
      }
    } else {
      throw Exception('Invalid response type: ${data.runtimeType}');
    }

    final list = map['data'];
    if (list is List) return list;

    throw Exception('Missing "data" list in /services response');
  }
}
