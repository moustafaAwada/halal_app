import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/send_verification_code_usecase.dart';
import '../../features/auth/presentation/cubit/forgot_password_cubit.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/auth/presentation/cubit/register_cubit.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_welcome_message.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';
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
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => SendVerificationCodeUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));

  // Data
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

void _initHome() {
  sl.registerFactory(() => HomeCubit(getWelcomeMessage: sl()));

  sl.registerLazySingleton(() => GetWelcomeMessage(sl()));

  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl());
}
