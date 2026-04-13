import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:hammer_app/core/config/app_config.dart';
import 'package:hammer_app/core/config/config_loader.dart';
import 'package:hammer_app/core/firebase/local_notification_service.dart';
import 'package:hammer_app/core/utils/common/screens/splash_screen.dart';
import 'package:hammer_app/core/utils/service_locators.dart';
import 'package:hammer_app/features/common/cubit/common_details_cubit.dart';
import 'package:hammer_app/features/common/cubit/fetch_key_cubit.dart';
import 'package:hammer_app/features/forgot_password/cubit/forgot_password_cubit.dart';

import 'package:hammer_app/features/kyc/cubit/kyc_cubit.dart';
import 'package:hammer_app/features/login/cubit/login_cubit.dart';
import 'package:hammer_app/features/otp/cubit/mobile_otp_cubit.dart';
import 'package:hammer_app/features/otp/cubit/verify_otp_cubit.dart';
import 'package:hammer_app/features/profile/cubit/profile_cubit.dart';
import 'package:hammer_app/features/profile/cubit/general_profile_cubit.dart';
import 'package:hammer_app/features/register/cubit/register_cubit.dart';
import 'package:hammer_app/features/service/cubit/service_cubit.dart';
import 'package:hammer_app/features/common/cubit/dynamic_content_cubit.dart';
import 'package:hammer_app/firebase_options_technician.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptionsTechnician.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await LocalNotificationService.init();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    LocalNotificationService.show(message);
  });

  initializeAppConfig();
  await init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RegisterCubit>(create: (_) => sl<RegisterCubit>()),
        BlocProvider<LoginCubit>(create: (_) => sl<LoginCubit>()),
        BlocProvider<OtpCubit>(create: (_) => sl<OtpCubit>()),
        BlocProvider<KycCubit>(create: (_) => sl<KycCubit>()),
        BlocProvider<ServiceCubit>(create: (_) => sl<ServiceCubit>()),
        BlocProvider<ProfileCubit>(create: (_) => sl<ProfileCubit>()),
        BlocProvider<GeneralProfileCubit>(create: (_) => sl<GeneralProfileCubit>()),
        BlocProvider<ForgotPasswordCubit>(
          create: (_) => sl<ForgotPasswordCubit>(),
        ),
        BlocProvider<MobileOtpCubit>(create: (_) => sl<MobileOtpCubit>()),
        BlocProvider<CommonDetailsCubit>(
          create: (_) => sl<CommonDetailsCubit>(),
        ),
        BlocProvider<FetchKeyCubit>(create: (_) => sl<FetchKeyCubit>()),
        BlocProvider<DynamicContentCubit>(create: (_) => sl<DynamicContentCubit>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConfig.instance.appName,
        home: const SplashScreen(),
      ),
    );
  }
}
