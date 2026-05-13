import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booker_app/core/routing/app_router.dart';
import 'package:salon_booker_app/core/services/dependency_injection/injection_container.dart';
import 'package:salon_booker_app/core/services/location/location_session_notifier.dart';
import 'package:salon_booker_app/core/theme/app_theme.dart';
import 'package:salon_booker_app/features/authentication/domain/usecases/clear_session_usecase.dart';
import 'package:salon_booker_app/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:salon_booker_app/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:salon_booker_app/core/services/auth/auth_session_notifier.dart';
import 'package:salon_booker_app/firebase_options.dart';

bool _isInitialized = false;

/// Test-friendly app initialization
/// Call this INSIDE testWidgets, after the binding is initialized
Future<void> initializeTestApp() async {
  if (_isInitialized) {
    return; // Already initialized
  }

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    if (!kReleaseMode) debugPrint('dotenv load failed: $e');
  }

  // Initialize Firebase for tests (skip if already initialized)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (!kReleaseMode) debugPrint('Firebase already initialized: $e');
  }

  // Initialize the DI container
  await initDependencies();
  
  _isInitialized = true;
}

/// Reset for next test
Future<void> resetTestApp() async {
  if (_isInitialized) {
    await resetDependencies();
    _isInitialized = false;
  }
}

/// Get the app widget for testing
Widget getTestApp() {
  // Get dependencies
  final getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
  final authSessionNotifier = sl<AuthSessionNotifier>();
  
  // Create AuthBloc
  final authBloc = AuthBloc(
    getCurrentUserUseCase,
    sl<LogoutUseCase>(),
    sl<ClearSessionUseCase>(),
    authSessionNotifier,
    initialState: AuthState.unauthenticated(), // Start unauthenticated for tests
  );

  // Create router
  final router = createRouter(
    authBloc: authBloc,
    locationSessionNotifier: sl<LocationSessionNotifier>(),
    initialLocation: '/signin',
  );

  return BlocProvider.value(
    value: authBloc,
    child: ScreenUtilInit(
      designSize: const Size(414, 896),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        title: 'Salon Booker App',
        theme: AppTheme.light(),
        themeMode: ThemeMode.light,
      ),
    ),
  );
}
