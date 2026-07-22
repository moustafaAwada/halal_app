import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/location_service.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/confirm_order.dart';
import '../constants/checkout_defaults.dart';
import '../cubit/cart_cubit.dart';
import '../widgets/checkout_bottom_bar.dart';
import '../widgets/checkout_delivery_details_card.dart';
import '../widgets/checkout_hint_banner.dart';
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
  double? _latitude;
  double? _longitude;
  bool _isLocating = false;
  bool _isSubmitting = false;

  double get _totalPrice => widget.order.totalPrice;
  bool get _hasLocation => _latitude != null && _longitude != null;
  bool get _isProcessing => _isLocating || _isSubmitting;

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
    });
    SnackbarUtils.showSuccessSnackBar(context, 'تم اختيار موقع التوصيل');
  }

  Future<void> _submit() async {
    if (!_hasLocation) {
      SnackbarUtils.showErrorSnackBar(
        context,
        'يرجى تحديد موقع التوصيل قبل تأكيد الطلب',
      );
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
            paymentMethod: CheckoutDefaults.paymentMethod,
          ),
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
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
            centerTitle: true,
            title: Text(
              'إتمام الطلب',
              style: AppTextStyles.skipButton(color: Colors.black87)
                  .copyWith(fontSize: 18),
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
                  latitude: _latitude,
                  longitude: _longitude,
                  onSelectOnMap: _isProcessing ? null : _openLocationPicker,
                  onUseGps: _isProcessing ? null : _fetchLocation,
                ),
                const SizedBox(height: 16),
                CheckoutDeliveryDetailsCard(
                  deliveryFee: CheckoutDefaults.deliveryFee,
                  deliveryTime: CheckoutDefaults.deliveryTime,
                  paymentMethod: CheckoutDefaults.paymentMethodLabel,
                  totalPrice: _totalPrice,
                ),
                const SizedBox(height: 12),
                CheckoutHintBanner(
                  text: _hasLocation
                      ? 'يمكنك تغيير موقع التوصيل من الخريطة أو عبر GPS.'
                      : 'اختر موقع التوصيل من الخريطة أو استخدم موقعك الحالي.',
                  isWarning: !_hasLocation,
                ),
              ],
            ),
          ),
          bottomNavigationBar: CheckoutBottomBar(
            total: _totalPrice,
            isSubmitting: _isSubmitting,
            enabled: !_isProcessing && _hasLocation,
            onConfirm: _submit,
          ),
        ),
      ),
    );
  }
}
