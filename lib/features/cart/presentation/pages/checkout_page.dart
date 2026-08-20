import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/location_service.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/confirm_order.dart';
import '../../../wallet/presentation/cubit/wallet_cubit.dart';
import '../../../wallet/presentation/cubit/wallet_state.dart';
import '../constants/checkout_defaults.dart';
import '../cubit/cart_cubit.dart';
import '../widgets/checkout_location_card.dart';
import '../widgets/checkout_order_hero_card.dart';
import 'location_picker_page.dart';

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
  late final WalletCubit _walletCubit;

  // Location state
  double? _latitude;
  double? _longitude;
  String? _address;
  bool _isLocating = false;

  // Submission state
  bool _isSubmitting = false;

  // Payment state: 1=Wallet | 2=Card(disabled) | 3=Cash on Delivery | 4=Points
  int _selectedPaymentMethod = 3;

  double get _totalPrice => widget.order.totalPrice;
  bool get _hasLocation => _latitude != null && _longitude != null;
  bool get _isProcessing => _isLocating || _isSubmitting;
  
  double get _currentBalance => _walletCubit.state.balance;
  bool get _hasSufficientBalance => _currentBalance >= _totalPrice;
  double get _remainingBalance => _currentBalance - _totalPrice;

  String get _paymentMethodString => switch (_selectedPaymentMethod) {
        1 => 'wallet',
        3 => 'cod',
        4 => 'points',
        _ => CheckoutDefaults.paymentMethod,
      };

  @override
  void initState() {
    super.initState();
    _walletCubit = sl<WalletCubit>()..loadWalletData();
    _fetchLocation();
  }

  @override
  void dispose() {
    _walletCubit.close();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isLocating = true);
    final result = await LocationService.getCurrentPosition();
    if (!mounted) return;
    setState(() => _isLocating = false);
    result.fold(
      (failure) {
        setState(() { _latitude = null; _longitude = null; _address = null; });
        SnackbarUtils.showErrorSnackBar(context, failure.message);
      },
      (coordinates) {
        setState(() {
          _latitude = coordinates.latitude;
          _longitude = coordinates.longitude;
          _address = 'موقعي الحالي';
        });
        SnackbarUtils.showSuccessSnackBar(context, 'تم تحديد موقعك بنجاح');
      },
    );
  }

  Future<void> _openLocationPicker() async {
    final selected = await Navigator.of(context).push<SelectedLocation>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
        ),
      ),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _latitude = selected.latitude;
      _longitude = selected.longitude;
      _address = selected.address;
    });
    SnackbarUtils.showSuccessSnackBar(context, 'تم اختيار موقع التوصيل');
  }

  Future<void> _submit() async {
    if (!_hasLocation) {
      SnackbarUtils.showErrorSnackBar(context, 'يرجى تحديد موقع التوصيل قبل تأكيد الطلب');
      return;
    }
    if (_selectedPaymentMethod == 1 && !_hasSufficientBalance) {
      SnackbarUtils.showErrorSnackBar(context, 'رصيد المحفظة غير كافٍ');
      return;
    }
    setState(() => _isSubmitting = true);
    await context.read<CartCubit>().confirmOrder(
          ConfirmOrderParams(
            orderId: widget.order.id,
            latitude: _latitude!,
            longitude: _longitude!,
            deliveryFee: CheckoutDefaults.deliveryFee,
            deliveryTime: CheckoutDefaults.deliveryTime,
            totalPrice: _totalPrice,
            paymentMethod: _paymentMethodString,
          ),
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider.value(
        value: _walletCubit,
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
              centerTitle: true,
              title: Text(
                'إتمام الطلب',
                style: AppTextStyles.skipButton(color: Colors.black87).copyWith(fontSize: 18),
              ),
            ),
            body: IgnorePointer(
              ignoring: _isSubmitting,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  CheckoutOrderHeroCard(
                    orderId: widget.order.id,
                    vendorName: widget.order.vendorName,
                    totalPrice: _totalPrice,
                  ),
                  const SizedBox(height: 16),
                  CheckoutLocationCard(
                    isLocating: _isLocating,
                    hasLocation: _hasLocation,
                    address: _address,
                    onSelectOnMap: _isProcessing ? null : _openLocationPicker,
                    onUseGps: _isProcessing ? null : _fetchLocation,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'طريقة الدفع',
                    style: AppTextStyles.skipButton(color: Colors.black87).copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  _buildWalletOption(),
                  const SizedBox(height: 12),
                  _buildCardOption(),
                  const SizedBox(height: 12),
                  _buildCashOnDeliveryOption(),
                  const SizedBox(height: 12),
                  _buildPointsOption(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            bottomNavigationBar: _buildBottomBar(),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletOption() {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, walletState) {
        final bool isSelected = _selectedPaymentMethod == 1;
        final double currentBalance = walletState.balance;
        final bool hasSufficientBalance = currentBalance >= _totalPrice;
        final double remainingBalance = currentBalance - _totalPrice;
        final bool isLoading = walletState.status == WalletStatus.loading;

        return GestureDetector(
          onTap: () => setState(() => _selectedPaymentMethod = 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEEF2FF) : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF818CF8) : const Color(0xFFE5E7EB),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: const Color(0xFF818CF8).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]
                  : [],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4338CA) : const Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.account_balance_wallet_outlined, color: isSelected ? AppColors.white : const Color(0xFF6B7280)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('محفظتي', style: AppTextStyles.skipButton(color: Colors.black87).copyWith(fontSize: 16)),
                          const SizedBox(height: 4),
                          if (isLoading)
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Row(
                              children: [
                                Icon(
                                  hasSufficientBalance ? Icons.check_circle_outline : Icons.error_outline,
                                  size: 14,
                                  color: hasSufficientBalance ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  hasSufficientBalance ? 'رصيد كافٍ' : 'رصيد غير كافٍ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: hasSufficientBalance ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isSelected ? const Color(0xFF4338CA) : const Color(0xFFD1D5DB),
                    ),
                  ],
                ),
                if (isSelected) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: Color(0xFFC7D2FE)),
                  ),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('الرصيد الحالي', style: AppTextStyles.onboardingSubtitle(color: const Color(0xFF6B7280)).copyWith(fontSize: 12)),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Color(0xFF111827)),
                                children: [
                                  TextSpan(text: '${currentBalance.toStringAsFixed(0)} ', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  const TextSpan(text: 'ج.م', style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('بعد الدفع', style: AppTextStyles.onboardingSubtitle(color: const Color(0xFF6B7280)).copyWith(fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              hasSufficientBalance ? '${remainingBalance.toStringAsFixed(0)} ج.م' : 'غير متاح',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: hasSufficientBalance ? const Color(0xFF059669) : const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  if (!isLoading && !hasSufficientBalance) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'رصيد المحفظة غير كافٍ.\nيرجى شحن المحفظة للمتابعة.',
                                  style: TextStyle(fontSize: 13, color: Color(0xFF991B1B)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton(
                            onPressed: () => Navigator.pushNamed(context, '/wallet-top-up'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFDC2626),
                              side: const BorderSide(color: Color(0xFFDC2626)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('شحن المحفظة'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardOption() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Opacity(
        opacity: 0.6,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Color(0xFFE5E7EB), shape: BoxShape.circle),
              child: const Icon(Icons.credit_card_outlined, color: Color(0xFF6B7280)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'بطاقة ائتمانية / مدى',
                style: AppTextStyles.skipButton(color: const Color(0xFF6B7280)).copyWith(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(20)),
              child: const Text('قريباً', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashOnDeliveryOption() {
    final bool isSelected = _selectedPaymentMethod == 3;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = 3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF818CF8) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4338CA) : const Color(0xFFE0E7FF),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delivery_dining_outlined, color: isSelected ? AppColors.white : const Color(0xFF4338CA)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'الدفع عند الاستلام',
                style: AppTextStyles.skipButton(color: Colors.black87).copyWith(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF4338CA) : const Color(0xFFD1D5DB),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsOption() {
    final bool isSelected = _selectedPaymentMethod == 4;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF818CF8) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4338CA) : const Color(0xFFE0E7FF),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.stars_rounded, color: isSelected ? AppColors.white : const Color(0xFF4338CA)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('نقاطي', style: AppTextStyles.skipButton(color: Colors.black87).copyWith(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('ادفع باستخدام نقاطك المكتسبة', style: AppTextStyles.onboardingSubtitle(color: const Color(0xFF6B7280)).copyWith(fontSize: 12)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF4338CA) : const Color(0xFFD1D5DB),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الإجمالي', style: AppTextStyles.onboardingSubtitle(color: const Color(0xFF4B5563)).copyWith(fontSize: 16)),
              Text('${_totalPrice.toStringAsFixed(0)} ج.م', style: AppTextStyles.skipButton(color: const Color(0xFF111827)).copyWith(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (_isSubmitting || _isLocating) ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: const Color(0xFF9CA3AF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: _isSubmitting ? 0 : 2,
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_hasLocation ? Icons.lock : Icons.lock_open, size: 18),
                        const SizedBox(width: 8),
                        const Text('تأكيد الطلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
