import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ServiceSelectionScreen extends StatelessWidget {
  const ServiceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'اختر الخدمة',
                style: AppTextStyles.onboardingTitle().copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 6),
              Text(
                'ماذا تريد أن تفعل اليوم؟',
                style: AppTextStyles.onboardingSubtitle().copyWith(
                  color: Colors.grey.shade500,
                  fontSize: 15,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 32),


              _ServiceCard(
                title: 'Food Delivery',
                subtitle: 'توصيل الطعام',
                description: 'اطلب من مطاعمك المفضلة بسرعة وسهولة',
                icon: Icons.restaurant_menu_rounded,
                gradient: const [
                  AppColors.primaryBlue,
                  AppColors.primaryBlueLight,
                ],
                onTap: () => AppRouter.goToHome(context),
              ),
              const SizedBox(height: 20),
              _ServiceCard(
                title: 'Request a Ride',
                subtitle: 'طلب رحلة',
                description: 'احجز سيارة لتصل إلى وجهتك بأمان',
                icon: Icons.local_taxi_rounded,
                gradient: const [
                  Color(0xFF0F766E),
                  Color(0xFF14B8A6),
                ],
                onTap: () => AppRouter.goToTrip(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: widget.gradient.last.withValues(
                alpha: _pressed ? 0.25 : 0.35,
              ),
              blurRadius: _pressed ? 14 : 22,
              offset: Offset(0, _pressed ? 6 : 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onTap();
            },
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),
            borderRadius: BorderRadius.circular(26),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradient,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Stack(
                  children: [
                    // Decorative watermark icon
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Icon(
                          widget.icon,
                          size: 140,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon badge
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              widget.icon,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 18),

                          // Text content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.subtitle,
                                  style: AppTextStyles.splashSlogan()
                                      .copyWith(
                                    color: Colors.white.withValues(
                                      alpha: 0.85,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.title,
                                  style: AppTextStyles.splashBrand().copyWith(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.splashSlogan()
                                      .copyWith(
                                    color: Colors.white.withValues(
                                      alpha: 0.78,
                                    ),
                                    fontSize: 13,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: widget.gradient.first,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}