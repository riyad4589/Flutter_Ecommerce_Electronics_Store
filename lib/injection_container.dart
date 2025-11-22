import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'core/database/database_helper.dart';
import 'core/network/network_info.dart';
import 'core/utils/custom_dio_interceptor.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/cart_local_datasource.dart';
import 'data/datasources/favorites_local_datasource.dart';
import 'data/datasources/orders_local_datasource.dart';
import 'data/datasources/orders_remote_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/datasources/product_local_datasource.dart';
import 'data/datasources/user_local_datasource.dart';
import 'data/datasources/theme_local_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/favorites_repository_impl.dart';
import 'data/repositories/orders_repository_impl.dart';
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

final sl = GetIt.instance;

Future<void> init() async {
  // Use cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => GetOrders(sl()));
  sl.registerLazySingleton(() => CreateOrder(sl()));
  sl.registerLazySingleton(() => CancelOrder(sl()));
  sl.registerLazySingleton(() => DeleteOrder(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      userLocalDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(databaseHelper: sl()),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSource(databaseHelper: sl()),
  );
  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSource(databaseHelper: sl()),
  );
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(databaseHelper: sl()),
  );
  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(databaseHelper: sl()),
  );
  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<OrdersLocalDataSource>(
    () => OrdersLocalDataSourceImpl(databaseHelper: sl()),
  );
  sl.registerLazySingleton<ThemeLocalDataSource>(
    () => ThemeLocalDataSourceImpl(databaseHelper: sl()),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);

  // External - Dio
  sl.registerLazySingleton(() {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 3);
    dio.interceptors.add(CustomDioInterceptor(sl()));
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
        productLocalDataSource: sl(),
      ));
  sl.registerFactory(() => CartProvider(
        cartLocalDataSource: sl(),
      ));

  // Note: FavoritesProvider et OrdersProvider sont enregistrés dans main.dart
  // car ils dépendent de AuthProvider pour userId
}
