import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/rimi_colors.dart';
import '../../../core/theme/rimi_typography.dart';
import '../../../shared/models/product.dart';
import '../../../shared/widgets/product_card.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';
  List<Product> _results = [];
  bool _loading = false;
  bool _searched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _doSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _query = query.trim();
      _searched = true;
    });
    try {
      final api = ref.read(apiClientProvider);
      final products = await api.searchProducts(_query, limit: 30);
      if (mounted) setState(() => _results = products);
    } catch (_) {
      if (mounted) setState(() => _results = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  final _suggestions = [
    'Susu Formula', 'Biskuit', 'Bedak Bayi', 'Minyak Telon', 'Sabun Bayi',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RimiColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: RimiColors.neutral),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          onSubmitted: _doSearch,
          textInputAction: TextInputAction.search,
          style: RimiTypography.bodyMedium.copyWith(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Cari produk Rimi...',
            hintStyle: RimiTypography.bodyMedium.copyWith(color: RimiColors.neutralMuted),
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: RimiColors.neutralMuted),
                    onPressed: () {
                      _controller.clear();
                      _doSearch('');
                    },
                  )
                : null,
          ),
          onChanged: (v) => setState(() {}),
        ),
        actions: [
          TextButton(
            onPressed: () => _doSearch(_controller.text),
            child: Text('Cari', style: RimiTypography.labelLarge.copyWith(color: RimiColors.secondary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: !_searched
          ? _buildSuggestions()
          : _loading
              ? const Center(child: CircularProgressIndicator())
              : _results.isEmpty
                  ? _buildNoResults()
                  : _buildResults(),
    );
  }

  Widget _buildSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pencarian Populer', style: RimiTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((s) {
              return ActionChip(
                label: Text(s, style: RimiTypography.labelMedium.copyWith(color: RimiColors.primary)),
                backgroundColor: RimiColors.cloud,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onPressed: () {
                  _controller.text = s;
                  _doSearch(s);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 72, color: RimiColors.neutralMuted),
            const SizedBox(height: 16),
            Text('Tidak ditemukan', style: RimiTypography.headlineSmall),
            const SizedBox(height: 4),
            Text('Coba kata kunci lain untuk "$_query"', style: RimiTypography.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text(
              '${_results.length} produk ditemukan',
              style: RimiTypography.bodySmall.copyWith(color: RimiColors.textSecondary),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.66,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => ProductCard(
                product: _results[i],
                cashbackColor: RimiColors.secondary,
                onTap: () => context.push('/product/${_results[i].id}'),
              ),
              childCount: _results.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}
