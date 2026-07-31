import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/rimi_colors.dart';
import '../../core/theme/rimi_typography.dart';

class BannerItem {
  const BannerItem({required this.title, required this.subtitle, required this.color, required this.icon});

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
}

class RimiBannerCarousel extends StatefulWidget {
  const RimiBannerCarousel({super.key, required this.items});

  final List<BannerItem> items;

  @override
  State<RimiBannerCarousel> createState() => _RimiBannerCarouselState();
}

class _RimiBannerCarouselState extends State<RimiBannerCarousel> {
  late final PageController _pageCtrl;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.92);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return false;
      final next = (_current + 1) % widget.items.length;
      _pageCtrl.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
      return mounted;
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageCtrl,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) {
              final item = widget.items[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: RimiColors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.title,
                                style: RimiTypography.headlineSmall.copyWith(
                                  color: RimiColors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.subtitle,
                                style: RimiTypography.bodyMedium.copyWith(
                                  color: RimiColors.black.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(item.icon, size: 56, color: RimiColors.black.withValues(alpha: 0.12)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Dots
          Positioned(
            bottom: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                widget.items.length,
                (i) => Container(
                  width: _current == i ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _current == i
                        ? RimiColors.secondary
                        : RimiColors.neutral.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
