import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/app_router.dart';
import 'presentation/themes/app_theme.dart';
import 'injection_container.dart' as di;
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/favorites_provider.dart';
import 'presentation/providers/orders_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ProductProvider>()),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => di.sl<CartProvider>(),
          update: (_, auth, cart) {
            if (auth.user != null && cart != null) {
              cart.setUserId(auth.user!.id);
            }
            return cart!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, FavoritesProvider>(
          create: (context) {
            final auth = context.read<AuthProvider>();
            return FavoritesProvider(
              repository: di.sl(),
              userId: auth.user?.id ?? '',
            );
          },
          update: (_, auth, previous) {
            if (auth.user != null) {
              return FavoritesProvider(
                repository: di.sl(),
                userId: auth.user!.id,
              );
            }
            return previous ??
                FavoritesProvider(repository: di.sl(), userId: '');
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
          create: (context) {
            final auth = context.read<AuthProvider>();
            return OrdersProvider(
              getOrdersUseCase: di.sl(),
              createOrderUseCase: di.sl(),
              cancelOrderUseCase: di.sl(),
              deleteOrderUseCase: di.sl(),
              userId: auth.user?.id ?? '',
            );
          },
          update: (_, auth, previous) {
            if (auth.user != null) {
              return OrdersProvider(
                getOrdersUseCase: di.sl(),
                createOrderUseCase: di.sl(),
                cancelOrderUseCase: di.sl(),
                deleteOrderUseCase: di.sl(),
                userId: auth.user!.id,
              );
            }
            return previous ??
                OrdersProvider(
                  getOrdersUseCase: di.sl(),
                  createOrderUseCase: di.sl(),
                  cancelOrderUseCase: di.sl(),
                  deleteOrderUseCase: di.sl(),
                  userId: '',
                );
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ThemeProvider>(
          create: (context) {
            final auth = context.read<AuthProvider>();
            return ThemeProvider(
              themeLocalDataSource: di.sl(),
            )..setUserId(auth.user?.id ?? '');
          },
          update: (_, auth, previous) {
            if (previous != null && auth.user != null) {
              previous.setUserId(auth.user!.id);
            }
            return previous ??
                ThemeProvider(
                  themeLocalDataSource: di.sl(),
                );
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.materialThemeMode,
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
