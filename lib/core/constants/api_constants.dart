abstract final class ApiConstants {
  static const baseUrl = 'https://e-commerce.server.intelakah.com/api/v1/client';
  static const menuBaseUrl = 'https://e-commerce.server.intelakah.com/api/v1';

  static const login = '/login';
  static const register = '/register';
  static const sendCode = '/send-code';
  static const forgetPassword = '/forget-password';
  static const menuTop = '/menu/top';
  static const menuSearch = '/menu/search';
  static const favorites = '/favorites';
  static const products = '/products';
  static const offers = '/offers';
  static const restaurants = '/restaurants';
  static const cart = '/cart';
  static const createOrder = '/create-order';
  static const confirmOrder = '/confirm-order';
  static const orders = '/orders';
  static const eta = '/eta';

  static const menuTopUrl = '$menuBaseUrl$menuTop';
  static const menuSearchUrl = '$menuBaseUrl$menuSearch';

  static String productById(int id) => '$products/$id';
  static String offerById(int id) => '$offers/$id';
  static String restaurantById(int vendorId) => '/restaurant/$vendorId';
  static String favoriteById(int id) => '$favorites/$id';
  static String cartById(int id) => '$cart/$id';
  static String userProfileById(int id) => '/$id';
  static String updateUserProfile(int id) => '/update/$id';
  static String orderDetails(int id) => '/order-details/$id';

  static String notificationsByClientId(int clientId) =>
      '/notification/$clientId';


  static String unreadNotificationsByClientId(int clientId) =>
      '/notification/$clientId/readed';

  static String markNotificationAsRead(int notificationId) =>
      '/notification/read/$notificationId';


  static const customerChatBaseUrl =
      'https://e-commerce.server.intelakah.com/api/v1/customer-chat';

  static const sendChatMessageUrl = '$customerChatBaseUrl/customer/message';

  static const chatHistoryUrl = '$customerChatBaseUrl/customer/history';


  static const tripsBaseUrl =
      'https://e-commerce.server.intelakah.com/api/v1/trips';

  static const requestTripUrl = '$tripsBaseUrl/request';

  static String acceptTripUrl(int tripId) => '$tripsBaseUrl/$tripId/accept';

  static String driverArrivedUrl(int tripId) => '$tripsBaseUrl/$tripId/arrive';

  static String startTripUrl(int tripId) => '$tripsBaseUrl/$tripId/start';

  static String tripTrackingUrl(int tripId) =>
      '$tripsBaseUrl/$tripId/tracking';

  static String completeTripUrl(int tripId) =>
      '$tripsBaseUrl/$tripId/complete';

  static String cancelTripUrl(int tripId) => '$tripsBaseUrl/$tripId/cancel';

  static String rateTripUrl(int tripId) => '$tripsBaseUrl/$tripId/rate';

  static String rebookTripUrl(int tripId) => '$tripsBaseUrl/$tripId/rebook';

  static const nearbyTripsUrl = '$tripsBaseUrl/nearby';

  static String deliveryStatusUrl(int orderId) =>
      '$menuBaseUrl/delivery/$orderId/status';

  static String rateOrderUrl(int orderId) =>
      '$menuBaseUrl/orders/$orderId/rate';

  static String rateDeliveryUrl(int orderId) =>
      '$menuBaseUrl/delivery/orders/$orderId/rate';
}
