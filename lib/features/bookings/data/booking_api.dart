import 'package:dio/dio.dart';

class BookingApi {
  BookingApi(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> getBookings({required String userId}) async {
    final res = await _dio.get('/bookings', queryParameters: {'userId': userId});
    if (res.data is Map<String, dynamic>) return res.data as Map<String, dynamic>;
    throw Exception('Invalid response for /bookings');
  }

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> body) async {
    final res = await _dio.post('/bookings', data: body);
    if (res.data is Map<String, dynamic>) return res.data as Map<String, dynamic>;
    throw Exception('Invalid response for POST /bookings');
  }
}
