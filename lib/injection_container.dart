import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'core/network/network_info.dart';
import 'core/services/firebase_service.dart';
import 'core/utils/custom_dio_interceptor.dart';
import 'data/datasources/auth_firebase_datasource.dart';
import 'data/datasources/cart_firebase_datasource.dart';
import 'data/datasources/favorites_firebase_datasource.dart';
import 'data/datasources/orders_firebase_datasource.dart';
import 'data/datasources/product_firebase_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/datasources/theme_firebase_datasource.dart';
import 'data/repositories/auth_repository_firebase_impl.dart';
import 'data/repositories/favorites_repository_firebase_impl.dart';
import 'data/repositories/orders_repository_firebase_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/favorites_repository.dart';
import 'domain/repositories/orders_repository.dart';
import 'domain/usecases/auth/login_user.dart';
import 'domain/usecases/auth/register_user.dart';
import 'domain/usecases/orders/create_order.dart';
import 'domain/usecases/orders/get_orders.dart';
import 'domain/usecases/orders/cancel_order.dart';
import 'domain/usecases/orders/delete_order.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/providers/category_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Firebase Service
  sl.registerLazySingleton<FirebaseService>(() => FirebaseService.instance);

  // Use cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => GetOrders(sl()));
  sl.registerLazySingleton(() => CreateOrder(sl()));
  sl.registerLazySingleton(() => CancelOrder(sl()));
  sl.registerLazySingleton(() => DeleteOrder(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryFirebaseImpl(
      firebaseDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryFirebaseImpl(
      firebaseDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryFirebaseImpl(
      firebaseDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Firebase Data sources
  sl.registerLazySingleton<AuthFirebaseDataSource>(
    () => AuthFirebaseDataSourceImpl(),
  );
  sl.registerLazySingleton<CartFirebaseDataSource>(
    () => CartFirebaseDataSourceImpl(),
  );
  sl.registerLazySingleton<FavoritesFirebaseDataSource>(
    () => FavoritesFirebaseDataSourceImpl(),
  );
  sl.registerLazySingleton<OrdersFirebaseDataSource>(
    () => OrdersFirebaseDataSourceImpl(),
  );
  sl.registerLazySingleton<ProductFirebaseDataSource>(
    () => ProductFirebaseDataSourceImpl(),
  );
  sl.registerLazySingleton<ThemeFirebaseDataSource>(
    () => ThemeFirebaseDataSourceImpl(),
  );

  // Remote Data sources (pour API Mock si encore nécessaire)
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(dio: sl()),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // External - Dio (gardé pour compatibilité avec API externe)
  sl.registerLazySingleton(() {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 3);
    dio.interceptors.add(CustomDioInterceptor());
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));
    return dio;
  });

  // Providers
  sl.registerFactory(() => AuthProvider(
        loginUser: sl(),
        registerUser: sl(),
        authRepository: sl(),
      ));
  sl.registerFactory(() => ProductProvider(
        productRemoteDataSource: sl(),
        productFirebaseDataSource: sl(),
      ));
  sl.registerFactory(() => CartProvider(
        cartFirebaseDataSource: sl(),
      ));
  sl.registerFactory(() => CategoryProvider(
        productFirebaseDataSource: sl(),
      ));

  // Note: FavoritesProvider et OrdersProvider sont enregistrés dans main.dart
  // car ils dépendent de AuthProvider pour userId
}
