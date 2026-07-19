import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../widgets/splash_hero_image.dart';
import '../widgets/splash_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const Duration minSplashDuration = Duration(seconds: 3);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _sloganFade;
  late final Animation<Offset> _sloganSlide;
  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;

  @override
  void initState() {
    super.initState();
    // Slightly longer duration for a more premium, buttery-smooth feel
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _initializeAnimations();

    _controller.forward();
    _initializeApp();
  }

  void _initializeAnimations() {
    // Using fastOutSlowIn for a more modern, "Apple/Google" native feel
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    // Added a more pronounced, playful bounce to the logo
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _sloganFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
    );

    _sloganSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.fastOutSlowIn),
      ),
    );

    _heroFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
    );

    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // UX IMPROVEMENT: Wait for BOTH the minimum delay AND the auth check.
      // This prevents the app from stuttering if the auth check takes longer than 3 seconds,
      // while guaranteeing the user gets to see your beautiful animations.
      final results = await Future.wait([
        sl<AuthRepository>().isLoggedIn(),
        Future.delayed(SplashPage.minSplashDuration),
      ]);

      if (!mounted) return;

      final isLoggedIn = results[0] as bool;

      if (isLoggedIn) {
        AppRouter.goToHome(context);
      } else {
        AppRouter.goToOnboarding(context);
      }
    } catch (e) {
      if (mounted) AppRouter.goToOnboarding(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(

            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.white,
                Color(0xFFF3F7FF),
                Color(0xFFDCE7FF),
              ],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.12),
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: const SplashLogo(),
                  ),
                ),
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: _sloganFade,
                  child: SlideTransition(
                    position: _sloganSlide,
                    child: Text(
                      'طلبك... يوصلك',
                      style: AppTextStyles.splashSlogan(
                        color: AppColors.subtitleGrey,
                      ).copyWith(
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                FadeTransition(
                  opacity: _heroFade,
                  child: SlideTransition(
                    position: _heroSlide,
                    child: SplashHeroImage(
                      maxHeight: screenHeight * 0.45,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.paddingOf(context).bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}