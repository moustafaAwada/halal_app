import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/location_service.dart';
import '../../../../core/utils/snackbar_utils.dart';

class SelectedLocation {
  const SelectedLocation({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  static const _fallbackCenter = LatLng(30.0444, 31.2357);
  static const _markerId = MarkerId('selected_location');

  GoogleMapController? _mapController;
  late LatLng _selectedPoint;
  bool _isLocating = false;
  bool _isProgrammaticMove = false;

  @override
  void initState() {
    super.initState();
    _selectedPoint = LatLng(
      widget.initialLatitude ?? _fallbackCenter.latitude,
      widget.initialLongitude ?? _fallbackCenter.longitude,
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> get _markers => {
        Marker(
          markerId: _markerId,
          position: _selectedPoint,
          draggable: true,
          onDragEnd: (position) {
            setState(() => _selectedPoint = position);
          },
        ),
      };

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);

    final result = await LocationService.getCurrentPosition();

    if (!mounted) return;
    setState(() => _isLocating = false);

    result.fold(
      (failure) => SnackbarUtils.showErrorSnackBar(context, failure.message),
      (coordinates) async {
        final point = LatLng(coordinates.latitude, coordinates.longitude);
        setState(() => _selectedPoint = point);
        _isProgrammaticMove = true;
        await _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(point, 16),
        );
        _isProgrammaticMove = false;
        if (!mounted) return;
        SnackbarUtils.showSuccessSnackBar(context, 'تم نقل المؤشر إلى موقعك');
      },
    );
  }

  void _confirm() {
    Navigator.of(context).pop(
      SelectedLocation(
        latitude: _selectedPoint.latitude,
        longitude: _selectedPoint.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.searchBackground,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            color: Colors.black87,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'اختيار موقع التوصيل',
            style: AppTextStyles.skipButton(color: Colors.black87)
                .copyWith(fontSize: 18),
          ),
        ),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedPoint,
                zoom: 15,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onTap: (position) {
                setState(() => _selectedPoint = position);
              },
              onCameraMove: (position) {
                if (_isProgrammaticMove) return;
                setState(() => _selectedPoint = position.target);
              },
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'حرّك الخريطة أو اضغط لاختيار موقع التوصيل',
                        style: AppTextStyles.onboardingSubtitle(
                          color: Colors.black54,
                        ).copyWith(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 110,
              child: FloatingActionButton.small(
                heroTag: 'checkout_gps_fab',
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primaryBlue,
                onPressed: _isLocating ? null : _useCurrentLocation,
                child: _isLocating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_rounded),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'الموقع المحدد',
                  style: AppTextStyles.onboardingSubtitle(
                    color: Colors.black54,
                  ).copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedPoint.latitude.toStringAsFixed(5)}, '
                  '${_selectedPoint.longitude.toStringAsFixed(5)}',
                  style: AppTextStyles.skipButton(color: Colors.black87),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _confirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'تأكيد الموقع',
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
