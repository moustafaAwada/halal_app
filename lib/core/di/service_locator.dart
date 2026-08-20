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
import '../../features/home/data/datasources/ads_remote_data_source.dart';
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/ads_repository_impl.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/ads_repository.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_available_ads.dart';
import '../../features/home/domain/usecases/get_home_data.dart';
import '../../features/home/domain/usecases/get_offer_details.dart';
import '../../features/home/domain/usecases/get_product_details.dart';
import '../../features/home/domain/usecases/get_restaurant_details.dart';
import '../../features/home/presentation/cubit/ads_cubit.dart';
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
import '../../features/chat/data/datasources/chat_remote_data_source.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/get_chat_history.dart';
import '../../features/chat/domain/usecases/send_chat_message.dart';
import '../../features/chat/presentation/cubit/chat_cubit.dart';
import '../../features/notifications/data/datasources/notifications_remote_data_source.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/domain/usecases/get_all_notifications.dart';
import '../../features/notifications/domain/usecases/get_unread_notifications.dart';
import '../../features/notifications/domain/usecases/mark_notification_as_read.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/notifications/presentation/cubit/unread_notifications_cubit.dart';
import '../../features/orders/data/datasources/orders_remote_data_source.dart';
import '../../features/orders/data/datasources/rating_remote_data_source.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/data/repositories/rating_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/domain/repositories/rating_repository.dart';
import '../../features/orders/domain/usecases/get_order_details.dart';
import '../../features/orders/domain/usecases/get_orders.dart';
import '../../features/orders/domain/usecases/rate_delivery.dart';
import '../../features/orders/domain/usecases/rate_order.dart';
import '../../features/orders/presentation/cubit/order_details_cubit.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';
import '../../features/orders/presentation/cubit/rating_cubit.dart';
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
import '../../features/advanced/data/datasources/advanced_remote_data_source.dart';
import '../../features/advanced/data/repositories/advanced_features_repository_impl.dart';
import '../../features/advanced/domain/repositories/advanced_features_repository.dart';
import '../../features/advanced/domain/usecases/advanced_start_trip.dart';
import '../../features/advanced/domain/usecases/get_high_demand_eta.dart';
import '../../features/advanced/domain/usecases/get_nearby_trips.dart';
import '../../features/advanced/domain/usecases/rebook_trip.dart';
import '../../features/advanced/domain/usecases/verify_and_complete_delivery.dart';
import '../../features/advanced/presentation/cubit/advanced_cubit.dart';
import '../../features/advanced/presentation/cubit/eta_cubit.dart';
import '../../features/trip/data/datasources/trip_remote_data_source.dart';
import '../../features/trip/data/repositories/trip_repository_impl.dart';
import '../../features/trip/domain/repositories/trip_repository.dart';
import '../../features/trip/domain/usecases/accept_trip.dart';
import '../../features/trip/domain/usecases/cancel_trip.dart';
import '../../features/trip/domain/usecases/complete_trip.dart';
import '../../features/trip/domain/usecases/driver_arrived.dart';
import '../../features/trip/domain/usecases/get_trip_details.dart';
import '../../features/trip/domain/usecases/rate_trip.dart';
import '../../features/trip/domain/usecases/request_trip.dart';
import '../../features/trip/domain/usecases/start_trip.dart';
import '../../features/trip/domain/usecases/update_tracking.dart';
import '../../features/trip/presentation/cubit/trip_cubit.dart';
import '../../features/wallet/data/datasources/wallet_remote_data_source.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/domain/usecases/get_wallet_balance.dart';
import '../../features/wallet/domain/usecases/get_wallet_requests.dart';
import '../../features/wallet/domain/usecases/submit_recharge.dart';
import '../../features/wallet/presentation/cubit/wallet_cubit.dart';
import '../network/dio_client.dart';
import '../network/dio_error_mapper.dart';
import '../router/app_router.dart';
import '../storage/secure_storage_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton(SecureStorageService.new);
  sl.registerLazySingleton(DioErrorMapper.new);
  sl.registerLazySingleton(
    () => DioClient(
      secureStorage: sl<SecureStorageService>(),
      onSessionExpired: AppRouter.goToLoginOnSessionExpired,
    ),
  );

  _initAuth();
  _initHome();
  _initSearch();
  _initFavorites();
  _initCart();
  _initProfile();
  _initOrders();
  _initNotifications();
  _initChat();
  _initTrip();
  _initAdvanced();
  _initOnboarding();
  _initWallet();
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
  sl.registerFactory(() => AdsCubit(getAvailableAdsUseCase: sl()));
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
  sl.registerLazySingleton(() => GetAvailableAdsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductDetailsUseCase(sl()));
  sl.registerLazySingleton(() => GetOfferDetailsUseCase(sl()));
  sl.registerLazySingleton(() => GetRestaurantDetailsUseCase(sl()));
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AdsRepository>(
    () => AdsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(
      dio: sl<DioClient>().dio,
      errorMapper: sl(),
    ),
  );
  sl.registerLazySingleton<AdsRemoteDataSource>(
    () => AdsRemoteDataSourceImpl(
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
  sl.registerFactory(
    () => RatingCubit(
      rateOrderUseCase: sl(),
      rateDeliveryUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderDetailsUseCase(sl()));
  sl.registerLazySingleton(() => RateOrderUseCase(sl()));
  sl.registerLazySingleton(() => RateDeliveryUseCase(sl()));
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<RatingRepository>(
    () => RatingRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(
      dio: sl<DioClient>().dio,
      errorMapper: sl(),
    ),
  );
  sl.registerLazySingleton<RatingRemoteDataSource>(
    () => RatingRemoteDataSourceImpl(
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

void _initChat() {
  sl.registerFactory(
    () => ChatCubit(
      getChatHistoryUseCase: sl(),
      sendChatMessageUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetChatHistoryUseCase(sl()));
  sl.registerLazySingleton(() => SendChatMessageUseCase(sl()));
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(
      dio: sl<DioClient>().dio,
      errorMapper: sl(),
    ),
  );
}

void _initTrip() {
  sl.registerFactory(
    () => TripCubit(
      requestTripUseCase: sl(),
      cancelTripUseCase: sl(),
      rateTripUseCase: sl(),
      acceptTripUseCase: sl(),
      driverArrivedUseCase: sl(),
      startTripUseCase: sl(),
      updateTrackingUseCase: sl(),
      completeTripUseCase: sl(),
      getTripDetailsUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => RequestTripUseCase(sl()));
  sl.registerLazySingleton(() => CancelTripUseCase(sl()));
  sl.registerLazySingleton(() => RateTripUseCase(sl()));
  sl.registerLazySingleton(() => AcceptTripUseCase(sl()));
  sl.registerLazySingleton(() => DriverArrivedUseCase(sl()));
  sl.registerLazySingleton(() => StartTripUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTrackingUseCase(sl()));
  sl.registerLazySingleton(() => CompleteTripUseCase(sl()));
  sl.registerLazySingleton(() => GetTripDetailsUseCase(sl()));

  sl.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<TripRemoteDataSource>(
    () => TripRemoteDataSourceImpl(
      dio: sl<DioClient>().dio,
      errorMapper: sl(),
    ),
  );
}

void _initAdvanced() {
  sl.registerFactory(
    () => EtaCubit(getHighDemandEtaUseCase: sl()),
  );
  sl.registerFactory(
    () => AdvancedCubit(
      rebookTripUseCase: sl(),
      getNearbyTripsUseCase: sl(),
      advancedStartTripUseCase: sl(),
      verifyAndCompleteDeliveryUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetHighDemandEtaUseCase(sl()));
  sl.registerLazySingleton(() => RebookTripUseCase(sl()));
  sl.registerLazySingleton(() => GetNearbyTripsUseCase(sl()));
  sl.registerLazySingleton(() => AdvancedStartTripUseCase(sl()));
  sl.registerLazySingleton(() => VerifyAndCompleteDeliveryUseCase(sl()));

  sl.registerLazySingleton<AdvancedFeaturesRepository>(
    () => AdvancedFeaturesRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AdvancedRemoteDataSource>(
    () => AdvancedRemoteDataSourceImpl(
      dio: sl<DioClient>().dio,
      errorMapper: sl(),
    ),
  );
}

void _initWallet() {
  sl.registerFactory(
    () => WalletCubit(
      getWalletBalanceUseCase: sl(),
      getWalletRequestsUseCase: sl(),
      submitRechargeUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetWalletBalanceUseCase(sl()));
  sl.registerLazySingleton(() => GetWalletRequestsUseCase(sl()));
  sl.registerLazySingleton(() => SubmitRechargeUseCase(sl()));

  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(
      dio: sl<DioClient>().dio,
      errorMapper: sl(),
    ),
  );
}
