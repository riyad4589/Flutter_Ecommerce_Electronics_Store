import 'package:dio/dio.dart';
import '../../data/datasources/auth_local_datasource.dart';

class CustomDioInterceptor extends Interceptor {
  final AuthLocalDataSource authLocalDataSource;

  CustomDioInterceptor(this.authLocalDataSource);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await authLocalDataSource.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      print('Authentication error: ${err.response?.statusCode}');
    }
    super.onError(err, handler);
  }
}
