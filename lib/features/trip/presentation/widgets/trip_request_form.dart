import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/location_service.dart';
import '../../../../core/utils/places_search_service.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../cart/presentation/pages/location_picker_page.dart';
import 'trip_route_map.dart';

/// Trip request form with Google Maps, GPS pickup, and searchable dropoff.
class TripRequestForm extends StatefulWidget {
  const TripRequestForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  final ValueChanged<Map<String, dynamic>> onSubmit;
  final bool isLoading;

  @override
  State<TripRequestForm> createState() => _TripRequestFormState();
}

class _TripRequestFormState extends State<TripRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _pickupAddressController = TextEditingController();
  final _dropoffSearchController = TextEditingController();
  final _dropoffFocusNode = FocusNode();
  final _placesService = PlacesSearchService();

  double? _pickupLat;
  double? _pickupLng;
  double? _dropoffLat;
  double? _dropoffLng;
  String? _dropoffAddress;

  String _vehicleType = 'car';
  String _paymentMethod = 'cash';
  bool _isLocatingPickup = false;
  bool _isSearchingDropoff = false;
  bool _isResolvingDropoff = false;
  bool _suppressDropoffSearch = false;
  List<PlaceSuggestion> _dropoffSuggestions = const [];
  Timer? _dropoffDebounce;

  @override
  void initState() {
    super.initState();
    _dropoffSearchController.addListener(_onDropoffSearchChanged);
    _bootstrapPickupFromGps();
  }

  @override
  void dispose() {
    _dropoffDebounce?.cancel();
    _pickupAddressController.dispose();
    _dropoffSearchController
      ..removeListener(_onDropoffSearchChanged)
      ..dispose();
    _dropoffFocusNode.dispose();
    super.dispose();
  }

  bool get _hasPickup => _pickupLat != null && _pickupLng != null;

  bool get _hasDropoff => _dropoffLat != null && _dropoffLng != null;

  double? get _distanceKm {
    if (!_hasPickup || !_hasDropoff) return null;
    final meters = Geolocator.distanceBetween(
      _pickupLat!,
      _pickupLng!,
      _dropoffLat!,
      _dropoffLng!,
    );
    return meters / 1000;
  }

  double get _estimatedFare {
    final km = _distanceKm ?? 5;
    return (15 + (km * 8)).clamp(20, 500).toDouble();
  }

  int get _estimatedMinutes {
    final km = _distanceKm ?? 5;
    return (km * 2.2).round().clamp(5, 120);
  }

  void _onDropoffSearchChanged() {
    if (_suppressDropoffSearch) return;

    _dropoffDebounce?.cancel();
    final query = _dropoffSearchController.text.trim();

    // If the user starts a new search after selecting, clear pinned coords.
    if (_hasDropoff) {
      setState(() {
        _dropoffLat = null;
        _dropoffLng = null;
        _dropoffAddress = null;
      });
    }

    if (query.length < 2) {
      setState(() {
        _dropoffSuggestions = const [];
        _isSearchingDropoff = false;
      });
      return;
    }

    setState(() => _isSearchingDropoff = true);
    _dropoffDebounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await _placesService.autocomplete(
        query,
        latitude: _pickupLat ?? _dropoffLat,
        longitude: _pickupLng ?? _dropoffLng,
      );
      if (!mounted) return;
      setState(() {
        _dropoffSuggestions = results;
        _isSearchingDropoff = false;
      });
    });
  }

  void _setDropoffSearchText(String value) {
    _suppressDropoffSearch = true;
    _dropoffSearchController.text = value;
    _suppressDropoffSearch = false;
  }

  Future<void> _selectDropoffSuggestion(PlaceSuggestion suggestion) async {
    setState(() {
      _isResolvingDropoff = true;
      _dropoffSuggestions = const [];
    });
    _dropoffFocusNode.unfocus();

    final details = await _placesService.getPlaceDetails(suggestion.placeId);
    if (!mounted) return;
    setState(() => _isResolvingDropoff = false);

    if (details == null) {
      SnackbarUtils.showErrorSnackBar(context, 'تعذر تحديد موقع الوصول');
      return;
    }

    final label = details.name?.isNotEmpty == true
        ? details.name!
        : suggestion.mainText ?? suggestion.description;

    setState(() {
      _dropoffLat = details.latitude;
      _dropoffLng = details.longitude;
      _dropoffAddress = details.displayAddress;
    });
    _setDropoffSearchText(label);
    SnackbarUtils.showSuccessSnackBar(context, 'تم تحديد موقع الوصول');
  }

  void _clearDropoff() {
    _dropoffDebounce?.cancel();
    setState(() {
      _dropoffLat = null;
      _dropoffLng = null;
      _dropoffAddress = null;
      _dropoffSuggestions = const [];
      _isSearchingDropoff = false;
      _isResolvingDropoff = false;
    });
    _setDropoffSearchText('');
  }

  Future<void> _bootstrapPickupFromGps() async {
    setState(() => _isLocatingPickup = true);
    final result = await LocationService.getCurrentPosition();
    if (!mounted) return;
    setState(() => _isLocatingPickup = false);

    result.fold(
      (_) {},
      (coords) {
        setState(() {
          _pickupLat = coords.latitude;
          _pickupLng = coords.longitude;
          if (_pickupAddressController.text.trim().isEmpty) {
            _pickupAddressController.text = 'موقعي الحالي';
          }
        });
        // Focus destination search after pickup is ready.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_hasDropoff) {
            _dropoffFocusNode.requestFocus();
          }
        });
      },
    );
  }

  Future<void> _useCurrentLocationAsPickup() async {
    setState(() => _isLocatingPickup = true);
    final result = await LocationService.getCurrentPosition();
    if (!mounted) return;
    setState(() => _isLocatingPickup = false);

    result.fold(
      (failure) => SnackbarUtils.showErrorSnackBar(context, failure.message),
      (coords) {
        setState(() {
          _pickupLat = coords.latitude;
          _pickupLng = coords.longitude;
          if (_pickupAddressController.text.trim().isEmpty ||
              _pickupAddressController.text == 'موقعي الحالي') {
            _pickupAddressController.text = 'موقعي الحالي';
          }
        });
        SnackbarUtils.showSuccessSnackBar(context, 'تم تحديد موقع الانطلاق');
      },
    );
  }

  Future<void> _pickOnMap({required bool isPickup}) async {
    final initialLat = isPickup ? _pickupLat : (_dropoffLat ?? _pickupLat);
    final initialLng = isPickup ? _pickupLng : (_dropoffLng ?? _pickupLng);

    final selected = await Navigator.of(context).push<SelectedLocation>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          initialLatitude: initialLat,
          initialLongitude: initialLng,
          title: isPickup ? 'اختيار موقع الانطلاق' : 'اختيار موقع الوصول',
          hint: isPickup
              ? 'ابحث أو حرّك الخريطة لنقطة الانطلاق'
              : 'ابحث عن وجهتك أو حرّك الخريطة',
        ),
      ),
    );

    if (selected == null || !mounted) return;

    setState(() {
      if (isPickup) {
        _pickupLat = selected.latitude;
        _pickupLng = selected.longitude;
        if (selected.address != null && selected.address!.trim().isNotEmpty) {
          _pickupAddressController.text = selected.address!;
        } else if (_pickupAddressController.text.trim().isEmpty) {
          _pickupAddressController.text =
              '${selected.latitude.toStringAsFixed(4)}, '
              '${selected.longitude.toStringAsFixed(4)}';
        }
      } else {
        _dropoffLat = selected.latitude;
        _dropoffLng = selected.longitude;
        final label = (selected.address != null &&
                selected.address!.trim().isNotEmpty)
            ? selected.address!.trim()
            : 'موقع محدد على الخريطة';
        _dropoffAddress = label;
        _dropoffSuggestions = const [];
      }
    });
    if (!isPickup) {
      _setDropoffSearchText(_dropoffAddress ?? '');
    }
  }

  void _swapLocations() {
    if (!_hasPickup && !_hasDropoff) return;

    final pickupLat = _pickupLat;
    final pickupLng = _pickupLng;
    final pickupAddress = _pickupAddressController.text;

    final dropoffLat = _dropoffLat;
    final dropoffLng = _dropoffLng;
    final dropoffLabel = _dropoffSearchController.text.isNotEmpty
        ? _dropoffSearchController.text
        : (_dropoffAddress ?? '');

    setState(() {
      _pickupLat = dropoffLat;
      _pickupLng = dropoffLng;
      _pickupAddressController.text = dropoffLabel;

      _dropoffLat = pickupLat;
      _dropoffLng = pickupLng;
      _dropoffAddress = pickupAddress.isNotEmpty ? pickupAddress : null;
      _dropoffSuggestions = const [];
    });
    _setDropoffSearchText(pickupAddress);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (!_hasPickup) {
      SnackbarUtils.showErrorSnackBar(
        context,
        'يرجى تحديد موقع الانطلاق من الخريطة أو GPS',
      );
      return;
    }
    if (!_hasDropoff) {
      SnackbarUtils.showErrorSnackBar(
        context,
        'ابحث عن موقع الوصول أو اختره من الخريطة',
      );
      _dropoffFocusNode.requestFocus();
      return;
    }

    final dropoffLabel = _dropoffAddress?.trim().isNotEmpty == true
        ? _dropoffAddress!.trim()
        : _dropoffSearchController.text.trim();

    if (dropoffLabel.isEmpty) {
      SnackbarUtils.showErrorSnackBar(context, 'أدخل موقع الوصول');
      return;
    }

    final distanceKm = double.parse((_distanceKm ?? 0).toStringAsFixed(2));

    widget.onSubmit({
      'pickupLat': _pickupLat,
      'pickupLng': _pickupLng,
      'pickupAddress': _pickupAddressController.text.trim(),
      'dropoffLat': _dropoffLat,
      'dropoffLng': _dropoffLng,
      'dropoffAddress': dropoffLabel,
      'vehicleType': _vehicleType,
      'paymentMethod': _paymentMethod,
      'fareAmount': double.parse(_estimatedFare.toStringAsFixed(0)),
      'distanceKm': distanceKm,
      'durationMinutes': _estimatedMinutes,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'طلب رحلة جديدة',
            style: AppTextStyles.onboardingTitle(),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          Text(
            'حدد وجهتك — الانطلاق يُضبط تلقائياً من موقعك',
            style: AppTextStyles.onboardingSubtitle(),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          TripRouteMap(
            height: 220,
            pickupLat: _pickupLat,
            pickupLng: _pickupLng,
            dropoffLat: _dropoffLat,
            dropoffLng: _dropoffLng,
          ),
          const SizedBox(height: 16),
          _PickupCard(
            addressController: _pickupAddressController,
            hasCoordinates: _hasPickup,
            latitude: _pickupLat,
            longitude: _pickupLng,
            isLocating: _isLocatingPickup,
            onPickMap: () => _pickOnMap(isPickup: true),
            onUseGps: _useCurrentLocationAsPickup,
          ),
          if (_hasPickup && _hasDropoff) ...[
            const SizedBox(height: 8),
            Center(
              child: IconButton.filledTonal(
                tooltip: 'تبديل الانطلاق والوصول',
                onPressed: _swapLocations,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.reviewsBackground,
                  foregroundColor: AppColors.primaryBlue,
                ),
                icon: const Icon(Icons.swap_vert_rounded),
              ),
            ),
          ] else
            const SizedBox(height: 12),
          _DropoffCard(
            searchController: _dropoffSearchController,
            focusNode: _dropoffFocusNode,
            hasCoordinates: _hasDropoff,
            isSearching: _isSearchingDropoff,
            isResolving: _isResolvingDropoff,
            suggestions: _dropoffSuggestions,
            onSuggestionTap: _selectDropoffSuggestion,
            onPickMap: () => _pickOnMap(isPickup: false),
            onClear: _hasDropoff || _dropoffSearchController.text.isNotEmpty
                ? _clearDropoff
                : null,
          ),
          if (_distanceKm != null) ...[
            const SizedBox(height: 14),
            _TripEstimateBanner(
              distanceKm: _distanceKm!,
              fare: _estimatedFare,
              minutes: _estimatedMinutes,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DropdownField(
                  label: 'نوع المركبة',
                  value: _vehicleType,
                  items: const {
                    'car': 'سيارة',
                    'motorcycle': 'دراجة',
                  },
                  onChanged: (v) => setState(() => _vehicleType = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DropdownField(
                  label: 'طريقة الدفع',
                  value: _paymentMethod,
                  items: const {
                    'cash': 'نقداً',
                    'online': 'إلكتروني',
                  },
                  onChanged: (v) => setState(() => _paymentMethod = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: widget.isLoading ? 'جاري الطلب...' : 'طلب رحلة',
            isLoading: widget.isLoading,
            onPressed: widget.isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class _PickupCard extends StatelessWidget {
  const _PickupCard({
    required this.addressController,
    required this.hasCoordinates,
    required this.onPickMap,
    required this.onUseGps,
    required this.isLocating,
    this.latitude,
    this.longitude,
  });

  final TextEditingController addressController;
  final bool hasCoordinates;
  final double? latitude;
  final double? longitude;
  final bool isLocating;
  final VoidCallback onPickMap;
  final VoidCallback onUseGps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navBarBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'موقع الانطلاق',
                  style: AppTextStyles.skipButton(color: Colors.black87),
                ),
              ),
              if (hasCoordinates)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E9B5E),
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: addressController,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'وصف موقع الانطلاق',
              filled: true,
              fillColor: AppColors.searchBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'أدخل وصف الموقع' : null,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: isLocating ? null : onUseGps,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: isLocating
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.gps_fixed_rounded, size: 16),
                    label: Text(
                      'موقعي',
                      style: AppTextStyles.skipButton(
                        color: AppColors.primaryBlue,
                      ).copyWith(fontSize: 13),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: FilledButton.icon(
                    onPressed: onPickMap,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.map_rounded, size: 16),
                    label: Text(
                      'الخريطة',
                      style:
                          AppTextStyles.primaryButton().copyWith(fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DropoffCard extends StatelessWidget {
  const _DropoffCard({
    required this.searchController,
    required this.focusNode,
    required this.hasCoordinates,
    required this.isSearching,
    required this.isResolving,
    required this.suggestions,
    required this.onSuggestionTap,
    required this.onPickMap,
    this.onClear,
  });

  final TextEditingController searchController;
  final FocusNode focusNode;
  final bool hasCoordinates;
  final bool isSearching;
  final bool isResolving;
  final List<PlaceSuggestion> suggestions;
  final ValueChanged<PlaceSuggestion> onSuggestionTap;
  final VoidCallback onPickMap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFE53935);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasCoordinates
              ? const Color(0xFFB7E4C7)
              : accent.withValues(alpha: 0.35),
          width: hasCoordinates ? 1.2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إلى أين؟',
                      style: AppTextStyles.skipButton(color: Colors.black87)
                          .copyWith(fontSize: 16),
                    ),
                    Text(
                      'موقع الوصول',
                      style: AppTextStyles.onboardingSubtitle(
                        color: Colors.black45,
                      ).copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (hasCoordinates)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E9B5E),
                  size: 22,
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: searchController,
            focusNode: focusNode,
            textAlign: TextAlign.right,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'ابحث عن وجهتك (مول، منطقة، عنوان...)',
              hintStyle: AppTextStyles.onboardingSubtitle(
                color: Colors.black38,
              ).copyWith(fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFFFF5F5),
              prefixIcon: const Icon(Icons.search_rounded, color: accent),
              suffixIcon: isSearching || isResolving
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : onClear != null
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: onClear,
                        )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
            validator: (_) {
              if (!hasCoordinates) {
                return 'اختر موقع وصول من البحث أو الخريطة';
              }
              return null;
            },
          ),
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.searchBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.navBarBorder),
              ),
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: suggestions.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.place_outlined,
                      color: accent,
                      size: 20,
                    ),
                    title: Text(
                      suggestion.mainText ?? suggestion.description,
                      style: AppTextStyles.skipButton(color: Colors.black87)
                          .copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: suggestion.secondaryText == null
                        ? null
                        : Text(
                            suggestion.secondaryText!,
                            style: AppTextStyles.onboardingSubtitle(
                              color: Colors.black54,
                            ).copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    onTap: () => onSuggestionTap(suggestion),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: onPickMap,
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: const BorderSide(color: accent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.map_rounded, size: 18),
              label: Text(
                hasCoordinates
                    ? 'تعديل الوجهة على الخريطة'
                    : 'اختيار الوجهة من الخريطة',
                style: AppTextStyles.skipButton(color: accent)
                    .copyWith(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripEstimateBanner extends StatelessWidget {
  const _TripEstimateBanner({
    required this.distanceKm,
    required this.fare,
    required this.minutes,
  });

  final double distanceKm;
  final double fare;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.reviewsBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _EstimateChip(
            icon: Icons.straighten_rounded,
            label: '${distanceKm.toStringAsFixed(1)} كم',
          ),
          _EstimateChip(
            icon: Icons.schedule_rounded,
            label: '$minutes د',
          ),
          _EstimateChip(
            icon: Icons.payments_outlined,
            label: '${fare.toStringAsFixed(0)} ج.م',
          ),
        ],
      ),
    );
  }
}

class _EstimateChip extends StatelessWidget {
  const _EstimateChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryBlue),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.skipButton(color: Colors.black87)
                  .copyWith(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.searchBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.entries
              .map(
                (e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value, textAlign: TextAlign.right),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
