import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    // Log to Crashlytics in release mode or when enabled
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'BLoC Error in ${bloc.runtimeType}',
        fatal: false,
      );
    } else {
      // In debug mode, log to console
      debugPrint('BLoC Error in ${bloc.runtimeType}: $error');
    }

    super.onError(bloc, error, stackTrace);
  }
}
