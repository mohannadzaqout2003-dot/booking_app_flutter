import 'package:dio/dio.dart';
import 'config.dart';

Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // IMPORTANT: Use the SAME names as your Postman Examples (exactly)
        final path = options.path;
        final method = options.method.toUpperCase();

        // services
        if (method == 'GET' && path == '/services') {
          options.headers['x-mock-response-name'] = '200 OK - services list';
        }

        // bookings list by user
        if (method == 'GET' && path == '/bookings') {
          options.headers['x-mock-response-name'] = '200 OK - user bookings';
        }

        // create booking
        if (method == 'POST' && path == '/bookings') {
          options.headers['x-mock-response-name'] = '201 Created - booking created';
        }

        handler.next(options);
      },
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
    ),
  );

  return dio;
}
