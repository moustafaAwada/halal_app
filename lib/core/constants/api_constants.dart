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

  /// GET all notifications for a client.
  static String notificationsByClientId(int clientId) =>
      '/notification/$clientId';

  /// GET unread notifications (`read=false`).
  /// Despite the `/readed` path, the API returns unread items.
  static String unreadNotificationsByClientId(int clientId) =>
      '/notification/$clientId/readed';

  /// GET used to mark a notification as read (backend update-via-GET contract).
  static String markNotificationAsRead(int notificationId) =>
      '/notification/read/$notificationId';
}
