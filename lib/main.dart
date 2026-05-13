import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/routing/app_router.dart';
import 'package:salon_booker_app/core/services/dependency_injection/injection_container.dart';
import 'package:salon_booker_app/core/services/logging/app_bloc_observer.dart';
import 'package:salon_booker_app/core/services/location/location_session_notifier.dart';
import 'package:salon_booker_app/core/theme/app_theme.dart';
import 'package:salon_booker_app/core/services/auth/auth_session_notifier.dart';
import 'package:salon_booker_app/features/authentication/domain/usecases/clear_session_usecase.dart';
import 'package:salon_booker_app/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:salon_booker_app/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:salon_booker_app/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:salon_booker_app/features/location/domain/use_cases/get_saved_location_use_case.dart';
import 'package:salon_booker_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:salon_booker_app/features/salon_favorites/presentation/cubit/salon_favorites_cubit.dart';
import 'package:salon_booker_app/firebase_options.dart';
import 'package:go_router/go_router.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      try {
        await dotenv.load(fileName: '.env');
      } catch (e) {
        if (!kReleaseMode) debugPrint('dotenv load failed: $e');
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      Bloc.observer = AppBlocObserver();

      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        kReleaseMode,
      );

      FlutterError.onError = (details) {
        if (!kReleaseMode) FlutterError.dumpErrorToConsole(details);
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        if (!kReleaseMode) {
          FlutterError.dumpErrorToConsole(
            FlutterErrorDetails(exception: error, stack: stack),
          );
        }
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      try {
        await initDependencies();
      } catch (e, s) {
        if (!kReleaseMode) {
          FlutterError.dumpErrorToConsole(
            FlutterErrorDetails(exception: e, stack: s),
          );
        }
        FirebaseCrashlytics.instance.recordError(e, s, fatal: false);
        rethrow;
      }

      final getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
      final authSessionNotifier = sl<AuthSessionNotifier>();
      final locationSessionNotifier = sl<LocationSessionNotifier>();
      final user = await getCurrentUserUseCase();
      final savedLocation = await sl<GetSavedLocationUseCase>()();
      if (savedLocation != null) {
        await locationSessionNotifier.setLocation(savedLocation);
      }
      final initialAuthState = user != null
          ? AuthState.authenticated(user)
          : AuthState.unauthenticated();
      final initialLocation = initialAuthState.status == AuthStatus.authenticated
          ? (savedLocation != null ? '/' : '/location-setup')
          : '/signin';

      runApp(
        MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => AuthBloc(
                getCurrentUserUseCase,
                sl<LogoutUseCase>(),
                sl<ClearSessionUseCase>(),
                authSessionNotifier,
                initialState: initialAuthState,
              ),
            ),
            BlocProvider(
              create: (_) => sl<BookingsBloc>()..add(const GetBookingsEvent()),
            ),
            BlocProvider.value(value: sl<SalonFavoritesCubit>()),
            BlocProvider(
              create: (_) =>
                  sl<ProfileBloc>()..add(const ProfileLoadRequested()),
            ),
          ],
          child: MainApp(initialLocation: initialLocation),
        ),
      );
    },
    (error, stack) {
      if (kDebugMode) debugPrint('runZonedGuarded');
      if (!kReleaseMode) {
        FlutterError.dumpErrorToConsole(
          FlutterErrorDetails(exception: error, stack: stack),
        );
      }
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.initialLocation});

  final String initialLocation;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Create router once, after AuthBloc is available in the widget tree.
    final authBloc = context.read<AuthBloc>();
    _router ??= createRouter(
      authBloc: authBloc,
      locationSessionNotifier: sl<LocationSessionNotifier>(),
      initialLocation: widget.initialLocation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp.router(
        routerConfig: _router!,
        debugShowCheckedModeBanner: false,
        title: 'Salon Booker App',
        theme: AppTheme.light(),
        themeMode: ThemeMode.light,
      ),
    );
  }
}
