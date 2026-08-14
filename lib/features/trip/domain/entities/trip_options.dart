/// Allowed API values for trip request payloads.
abstract final class TripVehicleType {
  static const car = 'car';
  static const motorcycle = 'motorcycle';
  static const scooter = 'scooter';
  static const van = 'van';
  static const truck = 'truck';

  static const values = [car, motorcycle, scooter, van, truck];

  static const labels = {
    car: 'سيارة',
    motorcycle: 'دراجة نارية',
    scooter: 'سكوتر',
    van: 'فان',
    truck: 'شاحنة',
  };
}

abstract final class TripPaymentMethod {
  static const cash = 'cash';
  static const wallet = 'wallet';
  static const card = 'card';

  static const values = [cash, wallet, card];

  static const labels = {
    cash: 'نقداً',
    wallet: 'محفظة',
    card: 'بطاقة',
  };

  /// Card payments require delivery PIN verification.
  static bool requiresDeliveryPin(String method) {
    final normalized = method.trim().toLowerCase();
    return normalized == card;
  }
}
