import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/rimi_colors.dart';
import '../../core/theme/rimi_typography.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/widgets/shell_page.dart';

// Pages
import '../../features/auth/presentation/splash_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/product/presentation/product_detail_page.dart';
import '../../features/cart/presentation/cart_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/rewards/presentation/rewards_page.dart';
import '../../features/rewards/presentation/referral_page.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthRefreshNotifier(ref),
    redirect: (context, state) {
      final path = state.uri.path;

      // Allow splash to handle routing
      if (path == '/splash') return null;

      final loggedIn = auth.status == AuthStatus.authenticated;
      final isAuthPage = ['/login', '/register', '/onboarding'].contains(path);

      if (!loggedIn && !isAuthPage) return '/login';
      if (loggedIn && isAuthPage) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      GoRoute(path: '/onboarding', builder: (_, __) => const SplashPage()),

      // Shell routes (bottom nav)
      ShellRoute(
        builder: (_, state, child) => ShellPage(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, __) => const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(path: '/referral', pageBuilder: (_, __) => const NoTransitionPage(child: ReferralPage())),
          GoRoute(path: '/rewards', pageBuilder: (_, __) => const NoTransitionPage(child: RewardsPage())),
          GoRoute(path: '/profile', pageBuilder: (_, __) => const NoTransitionPage(child: ProfilePage())),
        ],
      ),

      // Full-screen routes (outside shell)
      GoRoute(path: '/cart', builder: (_, __) => const CartPage()),
      GoRoute(path: '/product/:id', builder: (_, state) => ProductDetailPage(productId: state.pathParameters['id']!)),
      GoRoute(path: '/orders', builder: (_, __) => const _OrdersPlaceholder()),
      GoRoute(path: '/checkout', builder: (_, __) => const _CheckoutPlaceholder()),
    ],
  );
});

/// Notifier that triggers router refresh on auth state changes.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }
  final ProviderRef _ref;
}

/// Placeholder orders page.
class _OrdersPlaceholder extends StatelessWidget {
  const _OrdersPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: Center(
        child: Text('Pesanan', style: RimiTypography.titleMedium),
      ),
    );
  }
}

/// Placeholder checkout page.
class _CheckoutPlaceholder extends StatelessWidget {
  const _CheckoutPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: Text('Checkout', style: RimiTypography.titleMedium),
      ),
    );
  }
}
