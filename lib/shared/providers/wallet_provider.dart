import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';

/// Live wallet balance from BE `/api/v1/wallet/`.
/// Shared across home, rewards, and profile pages.
final walletBalanceProvider = FutureProvider<int>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    final w = await api.getWallet();
    final v = w['balance'];
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  } catch (_) {
    return 0;
  }
});

/// Wallet transaction history.
final walletTransactionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    return await api.getWalletTransactions(limit: 20);
  } catch (_) {
    return <Map<String, dynamic>>[];
  }
});

String fmtPoints(int n) =>
    n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
