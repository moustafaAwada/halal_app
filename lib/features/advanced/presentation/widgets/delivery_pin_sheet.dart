import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/advanced_cubit.dart';

/// Shows PIN sheet only for Visa/Card; otherwise completes without PIN.
Future<bool> completeDeliveryWithPinGate(
  BuildContext context, {
  required int orderId,
  required String paymentMethod,
}) async {
  if (!AdvancedCubit.requiresDeliveryPin(paymentMethod)) {
    final cubit = sl<AdvancedCubit>();
    await cubit.completeDelivery(
      orderId: orderId,
      paymentMethod: paymentMethod,
    );
    if (!context.mounted) return false;
    final state = cubit.state;
    if (state is AdvancedActionSuccess) {
      SnackbarUtils.showSuccessSnackBar(context, state.message);
      return true;
    }
    if (state is AdvancedError) {
      SnackbarUtils.showErrorSnackBar(context, state.message);
    }
    return false;
  }

  final result = await showDeliveryPinSheet(
    context,
    orderId: orderId,
    paymentMethod: paymentMethod,
  );
  return result == true;
}

Future<bool?> showDeliveryPinSheet(
  BuildContext context, {
  required int orderId,
  required String paymentMethod,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) => sl<AdvancedCubit>(),
      child: _DeliveryPinSheet(
        orderId: orderId,
        paymentMethod: paymentMethod,
      ),
    ),
  );
}

class _DeliveryPinSheet extends StatefulWidget {
  const _DeliveryPinSheet({
    required this.orderId,
    required this.paymentMethod,
  });

  final int orderId;
  final String paymentMethod;

  @override
  State<_DeliveryPinSheet> createState() => _DeliveryPinSheetState();
}

class _DeliveryPinSheetState extends State<_DeliveryPinSheet> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<AdvancedCubit>().completeDelivery(
          orderId: widget.orderId,
          paymentMethod: widget.paymentMethod,
          pin: _pinController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<AdvancedCubit, AdvancedState>(
        listener: (context, state) {
          if (state is AdvancedActionSuccess) {
            SnackbarUtils.showSuccessSnackBar(context, state.message);
            Navigator.of(context).pop(true);
          } else if (state is AdvancedError) {
            SnackbarUtils.showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AdvancedLoading;

          return Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.inactiveDot,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'تأكيد التسليم',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.onboardingTitle(
                          color: AppColors.primaryBlue,
                        ).copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'أدخل الرقم السري المكون من 4 أرقام لإتمام الطلب المدفوع ببطاقة',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.onboardingSubtitle(),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _pinController,
                        enabled: !isLoading,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 4,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: AppTextStyles.onboardingTitle().copyWith(
                          letterSpacing: 8,
                          fontSize: 28,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '••••',
                          filled: true,
                          fillColor: AppColors.searchBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => isLoading ? null : _submit(),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'تأكيد التسليم',
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
