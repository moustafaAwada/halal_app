import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/location_service.dart';
import '../../../../core/utils/places_search_service.dart';
import '../../../../core/utils/snackbar_utils.dart';

class SelectedLocation {
  const SelectedLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  final double latitude;
  final double longitude;
  final String? address;
}

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.title = 'اختيار موقع التوصيل',
    this.hint = 'ابحث أو حرّك الخريطة لاختيار الموقع',
  });

  final double? initialLatitude;
  final double? initialLongitude;
  final String title;
  final String hint;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  static const _fallbackCenter = LatLng(30.0444, 31.2357);
  static const _markerId = MarkerId('selected_location');

  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _placesService = PlacesSearchService();

  GoogleMapController? _mapController;
  late LatLng _selectedPoint;
  String? _selectedAddress;
  bool _isLocating = false;
  bool _isProgrammaticMove = false;
  bool _isSearching = false;
  bool _isResolvingPlace = false;
  List<PlaceSuggestion> _suggestions = const [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selectedPoint = LatLng(
      widget.initialLatitude ?? _fallbackCenter.latitude,
      widget.initialLongitude ?? _fallbackCenter.longitude,
    );
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _searchFocusNode.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> get _markers => {
        Marker(
          markerId: _markerId,
          position: _selectedPoint,
          draggable: true,
          onDragEnd: (position) {
            setState(() {
              _selectedPoint = position;
              _selectedAddress = null;
            });
          },
        ),
      };

  void _onSearchChanged() {
    _debounce?.cancel();
    final query = _searchController.text.trim();
    if (query.length < 2) {
      setState(() {
        _suggestions = const [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await _placesService.autocomplete(
        query,
        latitude: _selectedPoint.latitude,
        longitude: _selectedPoint.longitude,
      );
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _isSearching = false;
      });
    });
  }

  Future<void> _selectSuggestion(PlaceSuggestion suggestion) async {
    setState(() {
      _isResolvingPlace = true;
      _suggestions = const [];
    });
    _searchFocusNode.unfocus();

    final details = await _placesService.getPlaceDetails(suggestion.placeId);
    if (!mounted) return;

    setState(() => _isResolvingPlace = false);

    if (details == null) {
      SnackbarUtils.showErrorSnackBar(context, 'تعذر تحديد الموقع المختار');
      return;
    }

    final point = LatLng(details.latitude, details.longitude);
    setState(() {
      _selectedPoint = point;
      _selectedAddress = details.displayAddress;
      _searchController.text =
          details.name?.isNotEmpty == true
              ? details.name!
              : suggestion.mainText ?? suggestion.description;
    });

    _isProgrammaticMove = true;
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(point, 16),
    );
    _isProgrammaticMove = false;
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);

    final result = await LocationService.getCurrentPosition();

    if (!mounted) return;
    setState(() => _isLocating = false);

    result.fold(
      (failure) => SnackbarUtils.showErrorSnackBar(context, failure.message),
      (coordinates) async {
        final point = LatLng(coordinates.latitude, coordinates.longitude);
        setState(() {
          _selectedPoint = point;
          _selectedAddress = 'موقعي الحالي';
          _suggestions = const [];
        });
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
        address: _selectedAddress,
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _suggestions = const [];
      _isSearching = false;
    });
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
            widget.title,
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
                _searchFocusNode.unfocus();
                setState(() {
                  _selectedPoint = position;
                  _selectedAddress = null;
                  _suggestions = const [];
                });
              },
              onCameraMove: (position) {
                if (_isProgrammaticMove) return;
                setState(() {
                  _selectedPoint = position.target;
                  _selectedAddress = null;
                });
              },
            ),
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Material(
                    elevation: 4,
                    shadowColor: AppColors.cardShadow,
                    borderRadius: BorderRadius.circular(14),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن مكان أو عنوان...',
                        hintStyle: AppTextStyles.onboardingSubtitle(
                          color: Colors.black45,
                        ).copyWith(fontSize: 14),
                        filled: true,
                        fillColor: AppColors.white,
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primaryBlue,
                        ),
                        suffixIcon: _isSearching || _isResolvingPlace
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed: _clearSearch,
                                  )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  if (_suggestions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Material(
                      elevation: 4,
                      shadowColor: AppColors.cardShadow,
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.white,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 260),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          itemCount: _suggestions.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final suggestion = _suggestions[index];
                            return ListTile(
                              dense: true,
                              leading: const Icon(
                                Icons.place_outlined,
                                color: AppColors.primaryBlue,
                              ),
                              title: Text(
                                suggestion.mainText ?? suggestion.description,
                                style: AppTextStyles.skipButton(
                                  color: Colors.black87,
                                ).copyWith(fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: suggestion.secondaryText == null
                                  ? null
                                  : Text(
                                      suggestion.secondaryText!,
                                      style: AppTextStyles.onboardingSubtitle(
                                        color: Colors.black54,
                                      ).copyWith(fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              onTap: () => _selectSuggestion(suggestion),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.hint,
                      style: AppTextStyles.onboardingSubtitle(
                        color: Colors.black54,
                      ).copyWith(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
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
                if (_selectedAddress != null &&
                    _selectedAddress!.trim().isNotEmpty) ...[
                  Text(
                    _selectedAddress!,
                    style: AppTextStyles.skipButton(color: Colors.black87)
                        .copyWith(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  '${_selectedPoint.latitude.toStringAsFixed(5)}, '
                  '${_selectedPoint.longitude.toStringAsFixed(5)}',
                  style: AppTextStyles.onboardingSubtitle(
                    color: Colors.black45,
                  ).copyWith(fontSize: 12),
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
