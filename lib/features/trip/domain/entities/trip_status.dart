enum TripStatus {
  requested,
  accepted,
  driverArrived,
  inProgress,
  completed,
  cancelledByCustomer,
  cancelledByDriver,
  noDriverFound;

  String get apiValue => switch (this) {
        TripStatus.requested => 'requested',
        TripStatus.accepted => 'accepted',
        TripStatus.driverArrived => 'driver_arrived',
        TripStatus.inProgress => 'in_progress',
        TripStatus.completed => 'completed',
        TripStatus.cancelledByCustomer => 'cancelled_by_customer',
        TripStatus.cancelledByDriver => 'cancelled_by_driver',
        TripStatus.noDriverFound => 'no_driver_found',
      };

  String get labelAr => switch (this) {
        TripStatus.requested => 'بانتظار السائق',
        TripStatus.accepted => 'تم قبول الرحلة',
        TripStatus.driverArrived => 'وصل السائق',
        TripStatus.inProgress => 'الرحلة جارية',
        TripStatus.completed => 'مكتملة',
        TripStatus.cancelledByCustomer => 'ملغاة من العميل',
        TripStatus.cancelledByDriver => 'ملغاة من السائق',
        TripStatus.noDriverFound => 'لم يُعثر على سائق',
      };

  static TripStatus fromApi(String? value) {
    return switch (value) {
      'requested' => TripStatus.requested,
      'accepted' => TripStatus.accepted,
      'driver_arrived' => TripStatus.driverArrived,
      'in_progress' => TripStatus.inProgress,
      'completed' => TripStatus.completed,
      'cancelled_by_customer' => TripStatus.cancelledByCustomer,
      'cancelled_by_driver' => TripStatus.cancelledByDriver,
      'no_driver_found' => TripStatus.noDriverFound,
      _ => TripStatus.requested,
    };
  }
}
