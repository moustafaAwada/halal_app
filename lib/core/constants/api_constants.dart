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

  static const menuTopUrl = '$menuBaseUrl$menuTop';
  static const menuSearchUrl = '$menuBaseUrl$menuSearch';

  static String favoriteById(int id) => '$favorites/$id';
}
