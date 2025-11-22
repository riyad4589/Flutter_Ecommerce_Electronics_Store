class ApiConstants {
  static const String baseUrl =
      'http://10.0.2.2:3000/api/v1'; // Pour émulateur Android
  // static const String baseUrl = 'http://localhost:3000/api/v1'; // Pour iOS simulateur / Web

  // Auth Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  // Product Endpoints
  static const String products = '/products';
  static const String categories = '/categories';

  // Cart Endpoints
  static const String cart = '/cart';

  // Order Endpoints
  static const String orders = '/orders';
}
