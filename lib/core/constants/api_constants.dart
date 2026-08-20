abstract final class ApiConstants {
  // ============================================================
  // Base URLs
  // ============================================================

  static const _apiBaseUrl =
      'https://e-commerce.server.intelakah.com/api/v1';

  static const clientBaseUrl = '$_apiBaseUrl/client';
  static const menuBaseUrl = '$_apiBaseUrl';
  static const walletBaseUrl = '$_apiBaseUrl/wallet';
  static const customerChatBaseUrl = '$_apiBaseUrl/customer-chat';
  static const tripsBaseUrl = '$_apiBaseUrl/trips';

  // ============================================================
  // Authentication
  // ============================================================

  static const login = '/login';
  static const register = '/register';
  static const sendCode = '/send-code';
  static const forgetPassword = '/forget-password';
  static const refreshToken = '/refresh-token';

  // ============================================================
  // Menu
  // ============================================================

  static const menuTop = '/menu/top';
  static const menuSearch = '/menu/search';

  static const menuTopUrl = '$menuBaseUrl$menuTop';
  static const menuSearchUrl = '$menuBaseUrl$menuSearch';

  // ============================================================
  // Products
  // ============================================================

  static const products = '/products';

  static String productById(int id) => '$products/$id';

  // ============================================================
  // Offers
  // ============================================================

  static const offers = '/offers';

  static String offerById(int id) => '$offers/$id';

  // ============================================================
  // Restaurants
  // ============================================================

  static const restaurants = '/restaurants';

  static String restaurantById(int vendorId) =>
      '/restaurant/$vendorId';

  // ============================================================
  // Favorites
  // ============================================================

  static const favorites = '/favorites';

  static String favoriteById(int id) => '$favorites/$id';

  // ============================================================
  // Cart
  // ============================================================

  static const cart = '/cart';

  static String cartById(int id) => '$cart/$id';

  // ============================================================
  // Orders
  // ============================================================

  static const createOrder = '/create-order';
  static const confirmOrder = '/confirm-order';
  static const orders = '/orders';

  static String orderDetails(int id) =>
      '/order-details/$id';

  static String rateOrderUrl(int orderId) =>
      '$menuBaseUrl/orders/$orderId/rate';

  // ============================================================
  // Delivery
  // ============================================================

  static String deliveryStatusUrl(int orderId) =>
      '$menuBaseUrl/delivery/$orderId/status';

  static String rateDeliveryUrl(int orderId) =>
      '$menuBaseUrl/delivery/orders/$orderId/rate';

  // ============================================================
  // User Profile
  // ============================================================

  static String userProfileById(int id) => '/$id';

  static String updateUserProfile(int id) =>
      '/update/$id';

  // ============================================================
  // Notifications
  // ============================================================

  static String notificationsByClientId(int clientId) =>
      '/notification/$clientId';

  static String unreadNotificationsByClientId(int clientId) =>
      '/notification/$clientId/readed';

  static String markNotificationAsRead(int notificationId) =>
      '/notification/read/$notificationId';

  // ============================================================
  // Wallet
  // ============================================================

  static const walletBalanceUrl =
      '$walletBaseUrl/balance';

  static const walletMyRequestsUrl =
      '$walletBaseUrl/my-requests';

  static const walletRechargeUrl =
      '$walletBaseUrl/recharge';

  // ============================================================
  // Customer Chat
  // ============================================================

  static const sendChatMessageUrl =
      '$customerChatBaseUrl/customer/message';

  static const chatHistoryUrl =
      '$customerChatBaseUrl/customer/history';

  // ============================================================
  // Trips
  // ============================================================

  static const requestTripUrl =
      '$tripsBaseUrl/request';

  static const nearbyTripsUrl =
      '$tripsBaseUrl/nearby';

  static String acceptTripUrl(int tripId) =>
      '$tripsBaseUrl/$tripId/accept';

  static String driverArrivedUrl(int tripId) =>
      '$tripsBaseUrl/$tripId/arrive';

  static String startTripUrl(int tripId) =>
      '$tripsBaseUrl/$tripId/start';

  static String tripTrackingUrl(int tripId) =>
      '$tripsBaseUrl/$tripId/tracking';

  static String completeTripUrl(int tripId) =>
      '$tripsBaseUrl/$tripId/complete';

  static String cancelTripUrl(int tripId) =>
      '$tripsBaseUrl/$tripId/cancel';

  static String rateTripUrl(int tripId) =>
      '$tripsBaseUrl/$tripId/rate';

  static String rebookTripUrl(int tripId) =>
      '$tripsBaseUrl/$tripId/rebook';

  static String getTripByIdUrl(int tripId) =>
      '$tripsBaseUrl/$tripId';

  // ============================================================
  // ETA
  // ============================================================

  static const eta = '/eta';

  // ============================================================
  // Ads
  // ============================================================

  static const adsAvailableUrl = '$_apiBaseUrl/ads/available';
}