import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myecomerceapp/core/constants/app_colors.dart';
import 'package:myecomerceapp/core/utils/app_responsive.dart';

class PromotionBanner extends StatefulWidget {
  const PromotionBanner({super.key});

  @override
  State<PromotionBanner> createState() => _PromotionBannerState();
}

class _PromotionBannerState extends State<PromotionBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  static const _banners = [
    _BannerData(
      title: 'Flash Sale',
      subtitle: 'Up to 50% off on Electronics',
      icon: Icons.flash_on,
      gradient: [Color(0xFFFF6B35), Color(0xFFFF8F66)],
    ),
    _BannerData(
      title: 'New Arrivals',
      subtitle: 'Check out latest fashion trends',
      icon: Icons.new_releases,
      gradient: [Color(0xFF6C63FF), Color(0xFF9D97FF)],
    ),
    _BannerData(
      title: 'Free Shipping',
      subtitle: 'On orders above \$50',
      icon: Icons.local_shipping,
      gradient: [Color(0xFF00C853), Color(0xFF69F0AE)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % _banners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final bannerHeight = R.wp(context, 140).clamp(120.0, 180.0);
    final pad = R.hp(context);

    return Column(
      children: [
        SizedBox(
          height: bannerHeight,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final b = _banners[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: pad),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: b.gradient),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            b.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: R.sp(context, 22),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            b.subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: R.sp(context, 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      b.icon,
                      size: R.wp(context, 56),
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: _currentPage == i ? 20 : 6,
              decoration: BoxDecoration(
                color: _currentPage == i ? AppColors.accent : c.textHint,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });
}
