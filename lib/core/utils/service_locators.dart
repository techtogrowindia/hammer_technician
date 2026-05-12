import 'package:get_it/get_it.dart';
import 'package:hammer_app/features/common/cubit/common_details_cubit.dart';
import 'package:hammer_app/features/common/cubit/fetch_key_cubit.dart';
import 'package:hammer_app/features/common/data/repositories/common_details_repositories.dart';
import 'package:hammer_app/features/common/data/services/common_detail_service.dart';
import 'package:hammer_app/features/common/data/services/fetch_key_service.dart';
import 'package:hammer_app/features/common/data/services/dynamic_content_service.dart';
import 'package:hammer_app/features/common/cubit/dynamic_content_cubit.dart';
import 'package:hammer_app/features/forgot_password/cubit/forgot_password_cubit.dart';
import 'package:hammer_app/features/forgot_password/data/repositories/forgot_password_repository.dart';
import 'package:hammer_app/features/forgot_password/data/services/forgot_password_service.dart';
import 'package:hammer_app/features/kyc/cubit/kyc_cubit.dart';
import 'package:hammer_app/features/kyc/data/repositories/kyc_repository.dart';
import 'package:hammer_app/features/kyc/data/services/kyc_service.dart';
import 'package:hammer_app/features/login/cubit/login_cubit.dart';
import 'package:hammer_app/features/otp/cubit/mobile_otp_cubit.dart';
import 'package:hammer_app/features/otp/data/repositories/mobile_otp_repository.dart';
import 'package:hammer_app/features/otp/data/serivces/mobile_otp_service.dart';
import 'package:hammer_app/features/profile/cubit/profile_cubit.dart';
import 'package:hammer_app/features/profile/cubit/general_profile_cubit.dart';
import 'package:hammer_app/features/profile/data/repositories/profile_repository.dart';
import 'package:hammer_app/features/profile/data/services/profile_service.dart';
import 'package:hammer_app/features/register/cubit/register_cubit.dart';
import 'package:hammer_app/features/otp/cubit/verify_otp_cubit.dart';
import 'package:hammer_app/features/login/data/repositories/login_repository.dart';
import 'package:hammer_app/features/register/data/repositories/register_repository.dart';
import 'package:hammer_app/features/otp/data/repositories/verify_otp_repository.dart';
import 'package:hammer_app/features/login/data/serivces/login_service.dart';
import 'package:hammer_app/features/register/data/serivces/register_service.dart';
import 'package:hammer_app/features/otp/data/serivces/verify_otp_service.dart';
import 'package:hammer_app/features/service/cubit/service_cubit.dart';
import 'package:hammer_app/features/service/data/repositories/service_repository.dart';
import 'package:hammer_app/features/service/data/services/service_api.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Login
  sl.registerLazySingleton<LoginService>(() => LoginService());

  sl.registerLazySingleton<LoginRepository>(() => LoginRepository(sl()));

  sl.registerFactory<LoginCubit>(() => LoginCubit(sl<LoginRepository>()));

  // Register
  sl.registerLazySingleton<RegisterService>(() => RegisterService());

  sl.registerLazySingleton<RegisterRepository>(() => RegisterRepository(sl()));

  sl.registerFactory<RegisterCubit>(
    () => RegisterCubit(sl<RegisterRepository>()),
  );

  // Verify otp
  sl.registerLazySingleton<OtpService>(() => OtpService());

  sl.registerLazySingleton<OtpRepository>(() => OtpRepository(sl()));

  sl.registerFactory<OtpCubit>(() => OtpCubit(sl<OtpRepository>()));

  // kyc
  sl.registerLazySingleton<KycApiService>(() => KycApiService());

  sl.registerLazySingleton<KycRepository>(() => KycRepository(sl()));

  sl.registerLazySingleton<KycCubit>(() => KycCubit(sl<KycRepository>()));

  // Services
  sl.registerLazySingleton<ServiceApi>(() => ServiceApi());

  sl.registerLazySingleton<ServiceRepository>(() => ServiceRepository());

  sl.registerFactory<ServiceCubit>(() => ServiceCubit(sl<ServiceRepository>()));

  // Services
  sl.registerLazySingleton<ProfileService>(() => ProfileService());

  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepository(sl()));

  sl.registerLazySingleton<ProfileCubit>(
    () => ProfileCubit(sl<ProfileRepository>()),
  );

  // General Profile
  sl.registerFactory<GeneralProfileCubit>(
    () => GeneralProfileCubit(sl<ProfileRepository>()),
  );

  // Forgot Password
  sl.registerLazySingleton<ForgotPasswordService>(
    () => ForgotPasswordService(),
  );

  sl.registerLazySingleton<ForgotPasswordRepository>(
    () => ForgotPasswordRepository(sl()),
  );
  sl.registerFactory<ForgotPasswordCubit>(
    () => ForgotPasswordCubit(sl<ForgotPasswordRepository>()),
  );

  //mobile otp

  sl.registerLazySingleton<MobileOtpService>(() => MobileOtpService());

  sl.registerLazySingleton<MobileOtpRepository>(
    () => MobileOtpRepository(sl()),
  );
  sl.registerFactory<MobileOtpCubit>(
    () => MobileOtpCubit(sl<MobileOtpRepository>()),
  );

  //Common

  sl.registerLazySingleton<CommonDetailsService>(() => CommonDetailsService());

  sl.registerLazySingleton<CommonDetailsRepository>(
    () => CommonDetailsRepository(service: sl()),
  );
  sl.registerLazySingleton<CommonDetailsCubit>(
    () => CommonDetailsCubit(repository: sl<CommonDetailsRepository>()),
  );

  sl.registerLazySingleton<FetchKeyService>(() => FetchKeyService());
  sl.registerFactory<FetchKeyCubit>(() => FetchKeyCubit(sl<FetchKeyService>()));

  // Dynamic Content
  sl.registerLazySingleton<DynamicContentService>(() => DynamicContentService());
  sl.registerFactory<DynamicContentCubit>(() => DynamicContentCubit(service: sl()));
}
