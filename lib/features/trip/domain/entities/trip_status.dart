enum TripStatus {
  requested,
  accepted,
  driverArrived,
  inProgress,
  completed,
  cancelledByCustomer,
  cancelledByDriver;

  String get apiValue => switch (this) {
        TripStatus.requested => 'requested',
        TripStatus.accepted => 'accepted',
        TripStatus.driverArrived => 'driver_arrived',
        TripStatus.inProgress => 'in_progress',
        TripStatus.completed => 'completed',
        TripStatus.cancelledByCustomer => 'cancelled_by_customer',
        TripStatus.cancelledByDriver => 'cancelled_by_driver',
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
      _ => TripStatus.requested,
    };
  }
}
