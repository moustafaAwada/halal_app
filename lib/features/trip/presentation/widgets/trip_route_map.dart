import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_colors.dart';

/// Live Google Map showing pickup and/or dropoff markers for a trip.
class TripRouteMap extends StatefulWidget {
  const TripRouteMap({
    super.key,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    this.height = 220,
    this.onMapTap,
  });

  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final double height;
  final ValueChanged<LatLng>? onMapTap;

  @override
  State<TripRouteMap> createState() => _TripRouteMapState();
}

class _TripRouteMapState extends State<TripRouteMap> {
  static const _fallback = LatLng(30.0444, 31.2357);

  GoogleMapController? _controller;
  String? _lastBoundsKey;

  bool get _hasPickup =>
      widget.pickupLat != null && widget.pickupLng != null;

  bool get _hasDropoff =>
      widget.dropoffLat != null && widget.dropoffLng != null;

  LatLng get _pickup => LatLng(widget.pickupLat!, widget.pickupLng!);

  LatLng get _dropoff => LatLng(widget.dropoffLat!, widget.dropoffLng!);

  LatLng get _initialTarget {
    if (_hasPickup) return _pickup;
    if (_hasDropoff) return _dropoff;
    return _fallback;
  }

  Set<Marker> get _markers {
    final markers = <Marker>{};
    if (_hasPickup) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: _pickup,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(title: 'الانطلاق'),
        ),
      );
    }
    if (_hasDropoff) {
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: _dropoff,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
          infoWindow: const InfoWindow(title: 'الوصول'),
        ),
      );
    }
    return markers;
  }

  Set<Polyline> get _polylines {
    if (!_hasPickup || !_hasDropoff) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [_pickup, _dropoff],
        color: AppColors.primaryBlue,
        width: 4,
        patterns: [PatternItem.dash(16), PatternItem.gap(10)],
      ),
    };
  }

  @override
  void didUpdateWidget(covariant TripRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fitBoundsIfNeeded();
  }

  Future<void> _fitBoundsIfNeeded() async {
    final controller = _controller;
    if (controller == null) return;

    final key =
        '${widget.pickupLat},${widget.pickupLng}|${widget.dropoffLat},${widget.dropoffLng}';
    if (key == _lastBoundsKey) return;
    _lastBoundsKey = key;

    if (_hasPickup && _hasDropoff) {
      // Pad slightly so identical/near points don't create a zero-size bounds.
      const pad = 0.002;
      final south = (_pickup.latitude < _dropoff.latitude
              ? _pickup.latitude
              : _dropoff.latitude) -
          pad;
      final north = (_pickup.latitude > _dropoff.latitude
              ? _pickup.latitude
              : _dropoff.latitude) +
          pad;
      final west = (_pickup.longitude < _dropoff.longitude
              ? _pickup.longitude
              : _dropoff.longitude) -
          pad;
      final east = (_pickup.longitude > _dropoff.longitude
              ? _pickup.longitude
              : _dropoff.longitude) +
          pad;

      final bounds = LatLngBounds(
        southwest: LatLng(south, west),
        northeast: LatLng(north, east),
      );
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 56),
      );
    } else if (_hasPickup) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(_pickup, 15),
      );
    } else if (_hasDropoff) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(_dropoff, 15),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialTarget,
            zoom: 14,
          ),
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          onMapCreated: (controller) {
            _controller = controller;
            _fitBoundsIfNeeded();
          },
          onTap: widget.onMapTap,
        ),
      ),
    );
  }
}
