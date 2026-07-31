import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../auth/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), _go);
  }

  void _go() {
    if (!mounted) return;
    final auth = ref.read(authProvider);
    switch (auth.status) {
      case AuthStatus.authenticated:
        context.go('/home');
      case AuthStatus.unauthenticated:
        context.go('/login');
      case AuthStatus.unknown:
        // wait a bit more — provider still booting
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          final a = ref.read(authProvider);
          if (a.status == AuthStatus.authenticated) {
            context.go('/home');
          } else {
            context.go('/login');
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RimiColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: RimiColors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: RimiColors.primaryDeep.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🍼', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Rimi',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            Text(
              'Baby Shop & Rewards',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: RimiColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
