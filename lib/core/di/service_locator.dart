import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_stored_user_id.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/send_verification_code_usecase.dart';
import '../../features/auth/presentation/cubit/forgot_password_cubit.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/auth/presentation/cubit/register_cubit.dart';
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_data.dart';
import '../../features/home/domain/usecases/get_offer_details.dart';
import '../../features/home/domain/usecases/get_product_details.dart';
import '../../features/home/domain/usecases/get_restaurant_details.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/home/presentation/cubit/product_detail_cubit.dart';
import '../../features/home/presentation/cubit/restaurant_detail_cubit.dart';
import '../../features/favorites/data/datasources/favorites_remote_data_source.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/domain/usecases/add_favorite.dart';
import '../../features/favorites/domain/usecases/get_favorites.dart';
import '../../features/favorites/domain/usecases/remove_favorite.dart';
import '../../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../../features/cart/data/datasources/cart_remote_data_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/add_to_cart.dart';
import '../../features/cart/domain/usecases/clear_cart.dart';
import '../../features/cart/domain/usecases/confirm_order.dart';
import '../../features/cart/domain/usecases/create_order.dart';
import '../../features/cart/domain/usecases/get_cart.dart';
import '../../features/cart/domain/usecases/remove_cart_item.dart';
import '../../features/cart/domain/usecases/update_cart_item.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/notifications/data/datasources/notifications_remote_data_source.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/domain/usecases/get_all_notifications.dart';
import '../../features/notifications/domain/usecases/get_unread_notifications.dart';
import '../../features/notifications/domain/usecases/mark_notification_as_read.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/notifications/presentation/cubit/unread_notifications_cubit.dart';
import '../../features/orders/data/datasources/orders_remote_data_source.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/domain/usecases/get_order_details.dart';
import '../../features/orders/domain/usecases/get_orders.dart';
import '../../features/orders/presentation/cubit/order_details_cubit.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_user_profile.dart';
import '../../features/profile/domain/usecases/update_user_profile.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../features/search/data/datasources/search_remote_data_source.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/domain/usecases/search_products.dart';
import '../../features/search/presentation/cubit/search_cubit.dart';
import '../network/dio_client.dart';
import '../network/dio_error_mapper.dart';
import '../storage/secure_storage_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton(SecureStorageService.new);
  sl.registerLazySingleton(DioErrorMapper.new);
  sl.registerLazySingleton(
    () => DioClient(secureStorage: sl<SecureStorageService>()),
  );

  _initAuth();
  _initHome();
  _initSearch();
  _initFavorites();
  _initCart();
  _initProfile();
  _initOrders();
  _initNotifications();
  _initOnboarding();
}

void _initAuth() {
  sl.registerFactory(() => LoginCubit(loginUseCase: sl()));
  sl.registerFactory(() => RegisterCubit(registerUseCase: sl()));
  sl.registerFactory(
    () => ForgotPasswordCubit(
      sendVerificationCodeUseCase: sl(),
      resetPasswordUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => SendVerificationCodeUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => GetStoredUserIdUseCase(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dio: sl<DioClient>().dio,
      errorMapper: sl(),
    ),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );
}

void _initOnboarding() {
  sl.registerFactory(OnboardingCubit.new);
}

void _initSearch() {
  sl.registerFactory(() => SearchCubit(searchProductsUseCase: sl()));
  sl.registerLazySingleton(() => SearchProductsUseCase(sl()));
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(
      dio: sl<DioClient>().dio,
      errorMapper: sl(),
    ),
  );
}

void _initHome() {
  sl.registerFactory(() => HomeCubit(getHomeDataUseCase: sl()));
  sl.registerFactory(
    () => ProductDetailCubit(
      getProductDetailsUseCase: sl(),
      getOfferDetailsUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => RestaurantDetailCubit(getRestaurantDetailsUseCase: sl()),
  );
  sl.registerLazySingleton(() => GetHomeDataUseCase(sl()));
  sl.registerLazySingleton(() => GetProductDetailsUseCase(sl()));
  sl.registerLazySingleton(() => GetOfferDetailsUseCase(sl()));
  sl.registerLazySingleton(() => GetRestaurantDetailsUseCase(sl()));
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(
      dio: sl<DioClient>().dio,
      errorMapper: sl(),
    ),
  );
}

void _initFavorites() {
  sl.registerFactory(
    () => FavoritesCubit(
      getFavoritesUseCase: sl(),
      addFavoriteUseCase: sl(),
      removeFavoriteUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => AddFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFavoriteUseCase(sl()));
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<FavoritesRemoteDataSource>(
    () => FavoritesRemoteDataSourceImpl(
      dio: sl<DioClient>().dio,
      errorMapper: sl(),
    ),
  );
}

void _initCart() {
  sl.registerFactory(
    () => CartCubit(
      getCartUseCase: sl(),
      addToCartUseCase: sl(),
      updateCartItemUseCase: sl(),
      removeCartItemUseCase: sl(),
      clearCartUseCase: sl(),
      createOrderUseCase: sl(),
      confirmOrderUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetCartUseCase(sl()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCartItemUseCase(sl()));
  sl.registerLazySingleton(() => RemoveCartItemUseCase(sl()));
  sl.registerLazySingleton(() => ClearCartUseCase(sl()));
  sl.registerLazySingleton(() => CreateOrderUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmOrderUseCase(sl()));
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(
      dio: sl<DioClient>().dio,
      errorMapper: sl(),
    ),
  );
}

void _initProfile() {
  sl.registerFactory(
    () => ProfileCubit(
      getStoredUserIdUseCase: sl(),
      getUserProfileUseCase: sl(),
      updateUserProfileUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      dio: sl<DioClient>().dio,
      errorMapper: sl(),
    ),
  );
}

void _initOrders() {
  sl.registerFactory(
    () => OrdersCubit(getOrdersUseCase: sl()),
  );
  sl.registerFactory(
    () => OrderDetailsCubit(getOrderDetailsUseCase: sl()),
  );
  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderDetailsUseCase(sl()));
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(
      dio: sl<DioClient>().dio,
      errorMapper: sl(),
    ),
  );
}

void _initNotifications() {
  sl.registerFactory(
    () => NotificationsCubit(
      getStoredUserIdUseCase: sl(),
      getAllNotificationsUseCase: sl(),
      getUnreadNotificationsUseCase: sl(),
      markNotificationAsReadUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => UnreadNotificationsCubit(
      getStoredUserIdUseCase: sl(),
      getUnreadNotificationsUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetAllNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => GetUnreadNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsReadUseCase(sl()));
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(
      dio: sl<DioClient>().dio,
      errorMapper: sl(),
    ),
  );
}
