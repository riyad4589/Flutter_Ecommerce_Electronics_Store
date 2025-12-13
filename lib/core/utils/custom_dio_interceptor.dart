import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomDioInterceptor extends Interceptor {
  CustomDioInterceptor();

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Récupérer le token depuis Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    super.onRequest(options, handler);
  }


  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      print('Authentication error: ${err.response?.statusCode}');
    }
    super.onError(err, handler);
  }
}
