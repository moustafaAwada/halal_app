import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../cubit/trip_cubit.dart';
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
      backgroundColor: AppColors.white,
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
        child: BlocListener<TripCubit, TripState>(
          listenWhen: (previous, current) {
            if (current is TripError) return true;
            if (current.successMessage != null) return true;
            if (current is TripCompleted &&
                current.ratingSuccessMessage != null) {
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
                context,
                state.ratingSuccessMessage!,
              );
              return;
            }
            final message = state.successMessage;
            if (message != null && message.isNotEmpty) {
              SnackbarUtils.showSuccessSnackBar(context, message);
            }
          },
          child: Stack(
            children: [
              // Skip TripLoading so the previous panel stays under the overlay.
              BlocBuilder<TripCubit, TripState>(
                buildWhen: (previous, current) => current is! TripLoading,
                builder: (context, state) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildBody(context, state),
                  );
                },
              ),
              BlocBuilder<TripCubit, TripState>(
                buildWhen: (previous, current) =>
                    current is TripLoading || previous is TripLoading,
                builder: (context, state) {
                  if (state is! TripLoading) {
                    return const SizedBox.shrink();
                  }
                  return const ColoredBox(
                    color: Color(0x33000000),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
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
      TripInitial() || TripLoading() => TripRequestForm(
          onSubmit: (data) => context.read<TripCubit>().requestNewTrip(data),
        ),
      TripError(:final message) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.onboardingSubtitle(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TripRequestForm(
              onSubmit: (data) =>
                  context.read<TripCubit>().requestNewTrip(data),
            ),
          ],
        ),
      TripRequested(:final trip) => TripStatusPanel(
          trip: trip,
          title: 'بانتظار السائق',
          subtitle: 'تم طلب الرحلة بنجاح، جاري البحث عن سائق قريب',
          icon: Icons.hourglass_top_rounded,
          showCancel: true,
          onCancel: () => _cancelTrip(context),
        ),
      DriverAccepted(:final trip) => TripStatusPanel(
          trip: trip,
          title: 'تم قبول الرحلة',
          subtitle: 'السائق في الطريق إليك',
          icon: Icons.directions_car_filled,
          showCancel: true,
          onCancel: () => _cancelTrip(context),
        ),
      DriverArrived(:final trip) => TripStatusPanel(
          trip: trip,
          title: 'وصل السائق',
          subtitle: 'السائق في موقع الانطلاق — انتظر لحظة',
          icon: Icons.place,
          showCancel: true,
          onCancel: () => _cancelTrip(context),
        ),
      TripInProgress(:final trip) => TripStatusPanel(
          trip: trip,
          title: 'الرحلة جارية',
          subtitle: 'أنت في الطريق إلى وجهتك',
          icon: Icons.navigation,
          showCancel: false,
        ),
      TripCompleted(
        :final trip,
        :final payment,
      ) =>
        TripCompletedPanel(
          trip: trip,
          paymentAmount: payment.amount,
          paymentMethod: payment.method,
          paymentStatus: payment.status,
          onRate: () => _rateTrip(context),
          onNewTrip: () => context.read<TripCubit>().reset(),
        ),
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
              child: Text(
                'طلب رحلة جديدة',
                style: AppTextStyles.skipButton(),
              ),
            ),
          ],
        ),
    };
  }
}
