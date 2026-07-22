import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/location_service.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/confirm_order.dart';
import '../cubit/cart_cubit.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    super.key,
    required this.order,
  });

  final Order order;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const _deliveryFee = 0.0;
  static const _deliveryTime = '30 دقيقة';
  static const _paymentMethodLabel = 'الدفع عند الاستلام (COD)';

  double? _latitude;
  double? _longitude;
  bool _isLocating = false;
  bool _isSubmitting = false;

  double get _totalPrice => widget.order.totalPrice;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isLocating = true);

    final result = await LocationService.getCurrentPosition();

    if (!mounted) return;

    setState(() => _isLocating = false);

    result.fold(
      (failure) {
        setState(() {
          _latitude = null;
          _longitude = null;
        });
        SnackbarUtils.showErrorSnackBar(context, failure.message);
      },
      (coordinates) {
        setState(() {
          _latitude = coordinates.latitude;
          _longitude = coordinates.longitude;
        });
        SnackbarUtils.showSuccessSnackBar(context, 'تم تحديد موقعك');
      },
    );
  }

  Future<void> _submit() async {
    final latitude = _latitude;
    final longitude = _longitude;

    if (latitude == null || longitude == null) {
      SnackbarUtils.showErrorSnackBar(
        context,
        'يرجى تحديد موقعك الحالي قبل تأكيد الطلب',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    await context.read<CartCubit>().confirmOrder(
          ConfirmOrderParams(
            orderId: widget.order.id,
            latitude: latitude,
            longitude: longitude,
            deliveryFee: _deliveryFee,
            deliveryTime: _deliveryTime,
            totalPrice: _totalPrice,
          ),
        );

    if (!mounted) return;

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = _latitude != null && _longitude != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<CartCubit, CartState>(
        listener: (context, state) {
          if (state is CartActionError) {
            SnackbarUtils.showErrorSnackBar(context, state.message);
          } else if (state is CartOrderConfirmed) {
            SnackbarUtils.showSuccessSnackBar(context, state.message);
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.searchBackground,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            title: const Text('إتمام الطلب'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionCard(
                  title: 'ملخص الطلب',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ReadOnlyRow(
                        label: 'رقم الطلب',
                        value: '${widget.order.id}',
                      ),
                      if (widget.order.vendorName != null) ...[
                        const SizedBox(height: 12),
                        _ReadOnlyRow(
                          label: 'المطعم',
                          value: widget.order.vendorName!,
                        ),
                      ],
                      const SizedBox(height: 12),
                      _ReadOnlyRow(
                        label: 'إجمالي الطلب',
                        value: Formatters.formatPrice(_totalPrice),
                        valueColor: AppColors.primaryBlue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'موقع التوصيل',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isLocating)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else if (hasLocation) ...[
                        _ReadOnlyRow(
                          label: 'خط العرض',
                          value: _latitude!.toStringAsFixed(6),
                        ),
                        const SizedBox(height: 12),
                        _ReadOnlyRow(
                          label: 'خط الطول',
                          value: _longitude!.toStringAsFixed(6),
                        ),
                      ] else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'لم يتم تحديد الموقع بعد',
                            style: AppTextStyles.onboardingSubtitle(
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _isLocating ? null : _fetchLocation,
                        icon: const Icon(Icons.my_location),
                        label: Text(
                          hasLocation ? 'تحديث موقعي' : 'استخدام موقعي الحالي',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'تفاصيل التوصيل',
                  child: Column(
                    children: [
                      _ReadOnlyRow(
                        label: 'رسوم التوصيل',
                        value: Formatters.formatPrice(_deliveryFee),
                      ),
                      const SizedBox(height: 12),
                      _ReadOnlyRow(
                        label: 'مدة التوصيل',
                        value: _deliveryTime,
                      ),
                      const SizedBox(height: 12),
                      _ReadOnlyRow(
                        label: 'الإجمالي النهائي',
                        value: Formatters.formatPrice(_totalPrice),
                        valueColor: AppColors.primaryBlue,
                      ),
                      const SizedBox(height: 12),
                      _ReadOnlyRow(
                        label: 'طريقة الدفع',
                        value: _paymentMethodLabel,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed:
                        _isSubmitting || _isLocating || !hasLocation ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            'تأكيد الطلب',
                            style: AppTextStyles.primaryButton(),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.skipButton(color: Colors.black87),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.searchBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.onboardingSubtitle(color: Colors.black54),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: AppTextStyles.skipButton(
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
