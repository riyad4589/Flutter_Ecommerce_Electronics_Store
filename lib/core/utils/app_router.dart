import 'package:go_router/go_router.dart';
import '../../presentation/pages/auth/welcome_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/admin_login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/admin/admin_dashboard_page.dart';
import '../../presentation/pages/cart/cart_page.dart';
import '../../presentation/pages/checkout/checkout_page.dart';
import '../../presentation/pages/favorites/favorites_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/orders/orders_page.dart';
import '../../presentation/pages/orders/order_tracking_page.dart';
import '../../presentation/pages/product/product_details_page.dart';
import '../../presentation/pages/product/product_listing_page.dart';
import '../../presentation/pages/profile/change_password_page.dart';
import '../../presentation/pages/profile/edit_profile_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/support/contact_support_page.dart';
import '../../presentation/widgets/layout/custom_bottom_nav_bar.dart';

enum AppRoute {
  welcome,
  login,
  adminLogin,
  adminDashboard,
  register,
  home,
  categories,
  productDetails,
  cart,
  checkout,
  profile,
  editProfile,
  changePassword,
  orders,
  orderTracking,
  favorites,
  settings,
  contactSupport,
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    GoRoute(
      name: AppRoute.welcome.name,
      path: '/welcome',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      name: AppRoute.login.name,
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      name: AppRoute.adminLogin.name,
      path: '/admin-login',
      builder: (context, state) => const AdminLoginPage(),
    ),
    GoRoute(
      name: AppRoute.adminDashboard.name,
      path: '/admin-dashboard',
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      name: AppRoute.register.name,
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          name: AppRoute.home.name,
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          name: AppRoute.categories.name,
          path: '/categories',
          builder: (context, state) => const ProductListingPage(),
        ),
        GoRoute(
          name: AppRoute.cart.name,
          path: '/cart',
          builder: (context, state) => const CartPage(),
        ),
        GoRoute(
          name: AppRoute.checkout.name,
          path: '/checkout',
          builder: (context, state) => const CheckoutPage(),
        ),
        GoRoute(
          name: AppRoute.profile.name,
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          name: AppRoute.orders.name,
          path: '/orders',
          builder: (context, state) => const OrdersPage(),
        ),
      ],
    ),
    GoRoute(
      name: AppRoute.productDetails.name,
      path: '/product/:productId',
      builder: (context, state) {
        final productId = state.pathParameters['productId'];
        return ProductDetailsPage(productId: productId!);
      },
    ),
    GoRoute(
      name: AppRoute.orderTracking.name,
      path: '/order-tracking/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId'];
        return OrderTrackingPage(orderId: orderId!);
      },
    ),
    GoRoute(
      name: AppRoute.favorites.name,
      path: '/favorites',
      builder: (context, state) => const FavoritesPage(),
    ),
    GoRoute(
      name: AppRoute.settings.name,
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      name: AppRoute.editProfile.name,
      path: '/edit-profile',
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      name: AppRoute.changePassword.name,
      path: '/change-password',
      builder: (context, state) => const ChangePasswordPage(),
    ),
    GoRoute(
      name: AppRoute.contactSupport.name,
      path: '/contact-support',
      builder: (context, state) => const ContactSupportPage(),
    ),
  ],
);
