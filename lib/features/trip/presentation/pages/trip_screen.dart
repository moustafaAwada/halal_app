import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../advanced/presentation/cubit/advanced_cubit.dart';
import '../cubit/trip_cubit.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_status.dart';
import '../widgets/trip_driver_card.dart';
import '../widgets/trip_rating_dialog.dart';
import '../widgets/trip_request_form.dart';
import '../widgets/trip_status_panel.dart';

class TripScreen extends StatelessWidget {
  const TripScreen({super.key});

  Future<void> _cancelTrip(BuildContext context) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: 'تغيير الخطط');
        return AlertDialog(
          title: Text(
            'إلغاء الرحلة',
            style: AppTextStyles.onboardingTitle().copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: controller,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              labelText: 'سبب الإلغاء',
              filled: true,
              fillColor: AppColors.searchBackground,
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('رجوع'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(
                'تأكيد الإلغاء',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        );
      },
    );

    if (reason != null && reason.isNotEmpty && context.mounted) {
      context.read<TripCubit>().cancelCurrentTrip(reason);
    }
  }

  Future<void> _rateTrip(BuildContext context) async {
    final data = await showTripRatingDialog(context);
    if (data != null && context.mounted) {
      context.read<TripCubit>().rateCompletedTrip(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.searchBackground,
      appBar: AppBar(
        title: Text(
          'طلب رحلة',
          style: AppTextStyles.onboardingTitle().copyWith(fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<TripCubit, TripState>(
              listenWhen: (previous, current) {
                if (current is TripError) return true;
                if (current.successMessage != null) return true;
                if (current is TripCompleted &&
                    current.ratingSuccessMessage != null) {
                  return true;
                }
                if (current is TripCancelled &&
                    current.successMessage != null &&
                    current.successMessage!.contains('سائق')) {
                  return true;
                }
                return false;
              },
              listener: (context, state) {
                if (state is TripError) {
                  SnackbarUtils.showErrorSnackBar(context, state.message);
                  return;
                }
                if (state is TripCompleted &&
                    state.ratingSuccessMessage != null) {
                  SnackbarUtils.showSuccessSnackBar(
                      context, state.ratingSuccessMessage!);
                  return;
                }
                final msg = state.successMessage;
                if (msg != null && msg.isNotEmpty) {
                  SnackbarUtils.showSuccessSnackBar(context, msg);
                }
              },
            ),
            BlocListener<AdvancedCubit, AdvancedState>(
              listener: (context, state) {
                if (state is AdvancedError) {
                  SnackbarUtils.showErrorSnackBar(context, state.message);
                } else if (state is AdvancedRebookSuccess) {
                  SnackbarUtils.showSuccessSnackBar(context, state.message);
                  context.read<TripCubit>().applyRebookedTrip(state.trip);
                }
              },
            ),
          ],
          child: Stack(
            children: [
              BlocBuilder<TripCubit, TripState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: _buildBody(context, state),
                  );
                },
              ),
              // Full-screen loading overlay (only for explicit actions).
              BlocBuilder<TripCubit, TripState>(
                buildWhen: (previous, current) =>
                    current is TripLoading || previous is TripLoading,
                builder: (context, state) {
                  if (state is! TripLoading) return const SizedBox.shrink();
                  return const AbsorbPointer(
                    child: ColoredBox(
                      color: Color(0x33000000),
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryBlue),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TripState state) {
    return switch (state) {
      // ── Form / error states ──────────────────────────────────────────────
      TripInitial() || TripLoading() || TripError() => _TripRequestSection(
          state: state,
          onSubmit: (data) => context.read<TripCubit>().requestNewTrip(data),
        ),

      // ── Searching state — pulsing animation ──────────────────────────────
      TripSearchingForDriver(:final trip) || TripRequested(:final trip) =>
        _SearchingForDriverPanel(
          trip: trip,
          onCancel: () => _cancelTrip(context),
        ),

      // ── No driver found ──────────────────────────────────────────────────
      NoDriverFound(:final trip) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TripStatusPanel(
              trip: trip,
              title: TripStatus.noDriverFound.labelAr,
              subtitle:
                  'لم نتمكن من العثور على سائق متاح حالياً، حاول مرة أخرى',
              icon: Icons.person_off_outlined,
              showCancel: false,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'طلب رحلة جديدة',
              onPressed: () => context.read<TripCubit>().reset(),
            ),
          ],
        ),

      // ── Driver accepted — show driver card ───────────────────────────────
      DriverAccepted(:final trip) => TripDriverCard(
          trip: trip,
          statusLabel: 'تم قبول الرحلة',
          statusSubtitle: 'السائق في الطريق إليك',
          statusColor: AppColors.primaryBlue,
          statusIcon: Icons.directions_car_filled_rounded,
          showCancel: true,
          onCancel: () => _cancelTrip(context),
        ),

      // ── Driver arrived — show driver card ────────────────────────────────
      DriverArrived(:final trip) => TripDriverCard(
          trip: trip,
          statusLabel: 'وصل السائق',
          statusSubtitle: 'السائق بالخارج — توجه إليه الآن',
          statusColor: const Color(0xFF059669), // emerald
          statusIcon: Icons.place_rounded,
          showCancel: true,
          onCancel: () => _cancelTrip(context),
        ),

      // ── Trip in progress ─────────────────────────────────────────────────
      TripInProgress(:final trip) => TripDriverCard(
          trip: trip,
          statusLabel: 'الرحلة جارية',
          statusSubtitle: 'أنت في الطريق إلى وجهتك',
          statusColor: const Color(0xFFF59E0B), // amber
          statusIcon: Icons.navigation_rounded,
          showCancel: false,
        ),

      // ── Trip completed ───────────────────────────────────────────────────
      TripCompleted(:final trip, :final payment) =>
        BlocBuilder<AdvancedCubit, AdvancedState>(
          builder: (context, advancedState) => TripCompletedPanel(
            trip: trip,
            paymentAmount: payment.amount,
            paymentMethod: payment.method,
            paymentStatus: payment.status,
            onRate: () => _rateTrip(context),
            onNewTrip: () => context.read<TripCubit>().reset(),
            isRebooking: advancedState is AdvancedLoading,
            onRebook: () =>
                context.read<AdvancedCubit>().rebookTrip(trip.id),
          ),
        ),

      // ── Trip cancelled ───────────────────────────────────────────────────
      TripCancelled(:final trip) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TripStatusPanel(
              trip: trip,
              title: 'تم إلغاء الرحلة',
              subtitle: 'يمكنك طلب رحلة جديدة في أي وقت',
              icon: Icons.cancel_outlined,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => context.read<TripCubit>().reset(),
              child: Text('طلب رحلة جديدة',
                  style: AppTextStyles.skipButton()),
            ),
          ],
        ),
    };
  }
}

// ─── Searching for Driver panel (pulsing animation) ───────────────────────────

class _SearchingForDriverPanel extends StatefulWidget {
  const _SearchingForDriverPanel({
    required this.trip,
    required this.onCancel,
  });

  final Trip trip;
  final VoidCallback onCancel;

  @override
  State<_SearchingForDriverPanel> createState() =>
      _SearchingForDriverPanelState();
}

class _SearchingForDriverPanelState extends State<_SearchingForDriverPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        // Pulsing icon
        Center(
          child: ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_rounded,
                  size: 56, color: AppColors.primaryBlue),
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Info card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 16,
                  offset: Offset(0, 6)),
            ],
          ),
          child: Column(
            children: [
              Text(
                'جاري البحث عن سائق...',
                style:
                    AppTextStyles.onboardingTitle().copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'نبحث عن أقرب سائق متاح لك.\nيُرجى الانتظار لحظة.',
                style: AppTextStyles.onboardingSubtitle(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const _BouncingDots(),
              const SizedBox(height: 20),
              if (widget.trip.pickupAddress != null ||
                  widget.trip.dropoffAddress != null) ...[
                const Divider(),
                const SizedBox(height: 12),
                if (widget.trip.pickupAddress != null)
                  _InfoRow(
                      icon: Icons.my_location,
                      label: widget.trip.pickupAddress!),
                if (widget.trip.dropoffAddress != null) ...[
                  const SizedBox(height: 8),
                  _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: widget.trip.dropoffAddress!),
                ],
                if (widget.trip.fareAmount != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'الأجرة المتوقعة: ${widget.trip.fareAmount!.toStringAsFixed(0)} ج.م',
                    style: AppTextStyles.skipButton(),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: widget.onCancel,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade700,
            side: BorderSide(color: Colors.red.shade300),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('إلغاء الطلب',
              style:
                  AppTextStyles.primaryButton(color: Colors.red.shade700)),
        ),
      ],
    );
  }
}

// ─── Bouncing dots animation ──────────────────────────────────────────────────

class _BouncingDots extends StatefulWidget {
  const _BouncingDots();

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _anims;

  static const _dotCount = 3;
  static const _dotDelay = Duration(milliseconds: 200);
  static const _dotDuration = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _dotCount,
      (_) => AnimationController(vsync: this, duration: _dotDuration),
    );
    _anims = _controllers
        .map(
          (c) => Tween<double>(begin: 0, end: -10).animate(
            CurvedAnimation(parent: c, curve: Curves.easeInOut),
          ),
        )
        .toList();
    for (var i = 0; i < _dotCount; i++) {
      Future.delayed(_dotDelay * i, () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_dotCount, (i) {
        return AnimatedBuilder(
          animation: _anims[i],
          builder: (_, _) => Transform.translate(
            offset: Offset(0, _anims[i].value),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.onboardingSubtitle(),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _TripRequestSection extends StatelessWidget {
  const _TripRequestSection({
    required this.state,
    required this.onSubmit,
  });

  final TripState state;
  final ValueChanged<Map<String, dynamic>> onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state is TripError) ...[
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 12),
          Text(
            (state as TripError).message,
            style: AppTextStyles.onboardingSubtitle(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],
        TripRequestForm(
          key: const ValueKey('trip_request_form'),
          isLoading: state is TripLoading,
          onSubmit: onSubmit,
        ),
      ],
    );
  }
}
