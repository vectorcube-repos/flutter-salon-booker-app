import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:salon_booker_app/core/services/auth/auth_session_notifier.dart';
import 'package:salon_booker_app/core/services/location/location_session_notifier.dart';
import 'package:salon_booker_app/core/services/logging/app_logger.dart';
import 'package:salon_booker_app/core/services/network/dio_client.dart';
import 'package:salon_booker_app/core/services/storage/secure_storage_service.dart';
import 'package:salon_booker_app/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:salon_booker_app/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:salon_booker_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:salon_booker_app/features/authentication/domain/usecases/clear_session_usecase.dart';
import 'package:salon_booker_app/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:salon_booker_app/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:salon_booker_app/features/authentication/domain/usecases/request_otp_usecase.dart';
import 'package:salon_booker_app/features/authentication/domain/usecases/verify_otp_usecase.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/request_otp/request_otp_bloc.dart';
import 'package:salon_booker_app/features/bookings/data/datasources/bookings_remote_data_source.dart';
import 'package:salon_booker_app/features/bookings/data/repositories/bookings_repository_impl.dart';
import 'package:salon_booker_app/features/bookings/domain/repositories/bookings_repository.dart';
import 'package:salon_booker_app/features/bookings/domain/use_cases/get_bookings_use_case.dart';
import 'package:salon_booker_app/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:salon_booker_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:salon_booker_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:salon_booker_app/features/home/domain/repositories/home_repository.dart';
import 'package:salon_booker_app/features/home/domain/use_cases/get_home_dashboard_use_case.dart';
import 'package:salon_booker_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:salon_booker_app/features/explore/data/datasources/product_remote_data_source.dart';
import 'package:salon_booker_app/features/explore/data/datasources/salon_booking_remote_data_source.dart';
import 'package:salon_booker_app/features/explore/data/datasources/explore_remote_data_source.dart';
import 'package:salon_booker_app/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:salon_booker_app/features/explore/data/repositories/product_repository_impl.dart';
import 'package:salon_booker_app/features/explore/data/repositories/salon_booking_repository_impl.dart';
import 'package:salon_booker_app/features/explore/data/services/favorites_notifier.dart';
import 'package:salon_booker_app/features/explore/domain/repositories/explore_repository.dart';
import 'package:salon_booker_app/features/explore/domain/repositories/product_repository.dart';
import 'package:salon_booker_app/features/explore/domain/repositories/salon_booking_repository.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/get_explore_dashboard_use_case.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/add_to_favorites_use_case.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/book_appointment_use_case.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/get_categories_use_case.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/get_favorites_use_case.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/get_product_details_use_case.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/get_products_use_case.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/get_salon_booking_details_use_case.dart';
import 'package:salon_booker_app/features/explore/domain/use_cases/remove_from_favorites_use_case.dart';
import 'package:salon_booker_app/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:salon_booker_app/features/explore/presentation/bloc/categories_bloc.dart';
import 'package:salon_booker_app/features/explore/presentation/bloc/product_details_bloc.dart';
import 'package:salon_booker_app/features/explore/presentation/bloc/products_bloc.dart';
import 'package:salon_booker_app/features/explore/presentation/bloc/salon_booking_bloc.dart';
import 'package:salon_booker_app/features/location/data/datasources/location_local_data_source.dart';
import 'package:salon_booker_app/features/location/data/datasources/location_remote_data_source.dart';
import 'package:salon_booker_app/features/location/data/repositories/location_repository_impl.dart';
import 'package:salon_booker_app/features/location/domain/repositories/location_repository.dart';
import 'package:salon_booker_app/features/location/domain/use_cases/get_location_details_use_case.dart';
import 'package:salon_booker_app/features/location/domain/use_cases/get_saved_location_use_case.dart';
import 'package:salon_booker_app/features/location/domain/use_cases/has_saved_location_use_case.dart';
import 'package:salon_booker_app/features/location/domain/use_cases/reverse_geocode_location_use_case.dart';
import 'package:salon_booker_app/features/location/domain/use_cases/save_location_use_case.dart';
import 'package:salon_booker_app/features/location/domain/use_cases/search_locations_use_case.dart';
import 'package:salon_booker_app/features/location/presentation/cubit/location_setup_cubit.dart';
import 'package:salon_booker_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:salon_booker_app/features/profile/presentation/bloc/profile_edit_profile_bloc.dart';
import 'package:salon_booker_app/features/profile/presentation/bloc/profile_favorites_bloc.dart';
import 'package:salon_booker_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:salon_booker_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:salon_booker_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:salon_booker_app/features/profile/domain/use_cases/change_password_use_case.dart';
import 'package:salon_booker_app/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:salon_booker_app/features/profile/domain/use_cases/update_profile_use_case.dart';
import 'package:salon_booker_app/features/profile/presentation/bloc/profile_change_password_bloc.dart';
import 'package:salon_booker_app/features/search/data/datasources/search_remote_data_source.dart';
import 'package:salon_booker_app/features/search/data/repositories/search_repository_impl.dart';
import 'package:salon_booker_app/features/search/domain/repositories/search_repository.dart';
import 'package:salon_booker_app/features/search/domain/use_cases/search_catalog_use_case.dart';
import 'package:salon_booker_app/features/search/presentation/cubit/search_cubit.dart';
import 'package:salon_booker_app/features/salon_favorites/data/datasources/salon_favorites_remote_data_source.dart';
import 'package:salon_booker_app/features/salon_favorites/data/repositories/salon_favorites_repository_impl.dart';
import 'package:salon_booker_app/features/salon_favorites/domain/repositories/salon_favorites_repository.dart';
import 'package:salon_booker_app/features/salon_favorites/domain/use_cases/add_salon_to_favorites_use_case.dart';
import 'package:salon_booker_app/features/salon_favorites/domain/use_cases/get_favorite_salons_use_case.dart';
import 'package:salon_booker_app/features/salon_favorites/domain/use_cases/remove_salon_from_favorites_use_case.dart';
import 'package:salon_booker_app/features/salon_favorites/presentation/cubit/salon_favorites_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service Locator for Dependency Injection
final sl = GetIt.instance;

/// Initialize all dependencies
///
/// Call this once at app startup in main.dart:
/// ```dart
/// await initDependencies();
/// ```
Future<void> initDependencies() async {
  // ---------------------------------------------------------------------------
  // External Dependencies (Third-party packages)
  // ---------------------------------------------------------------------------

  // SharedPreferences - Must be initialized asynchronously
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // FlutterSecureStorage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(aOptions: AndroidOptions()),
  );

  // Logger
  sl.registerLazySingleton<Logger>(() => Logger());

  // Firebase Crashlytics
  sl.registerLazySingleton<FirebaseCrashlytics>(
    () => FirebaseCrashlytics.instance,
  );

  // ---------------------------------------------------------------------------
  // Core Services
  // ---------------------------------------------------------------------------

  // App Logger
  sl.registerLazySingleton<AppLogger>(
    () =>
        AppLogger(logger: sl<Logger>(), crashlytics: sl<FirebaseCrashlytics>()),
  );

  // Auth Session Notifier
  sl.registerLazySingleton<AuthSessionNotifier>(() => AuthSessionNotifier());
  sl.registerLazySingleton<LocationSessionNotifier>(
    () => LocationSessionNotifier(),
  );

  // Secure Storage Service
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageServiceImpl(
      sl<FlutterSecureStorage>(),
      sl<SharedPreferences>(),
    ),
  );

  // Initialize SecureStorageService
  await sl<SecureStorageService>().init();

  // Network Client
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      sl<SecureStorageService>(),
      sessionNotifier: sl<AuthSessionNotifier>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Features - Location
  // ---------------------------------------------------------------------------

  sl.registerLazySingleton<LocationLocalDataSource>(
    () => LocationLocalDataSourceImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      sl<LocationRemoteDataSource>(),
      sl<LocationLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton<GetSavedLocationUseCase>(
    () => GetSavedLocationUseCase(sl<LocationRepository>()),
  );
  sl.registerLazySingleton<HasSavedLocationUseCase>(
    () => HasSavedLocationUseCase(sl<LocationRepository>()),
  );
  sl.registerLazySingleton<SaveLocationUseCase>(
    () => SaveLocationUseCase(sl<LocationRepository>()),
  );
  sl.registerLazySingleton<SearchLocationsUseCase>(
    () => SearchLocationsUseCase(sl<LocationRepository>()),
  );
  sl.registerLazySingleton<GetLocationDetailsUseCase>(
    () => GetLocationDetailsUseCase(sl<LocationRepository>()),
  );
  sl.registerLazySingleton<ReverseGeocodeLocationUseCase>(
    () => ReverseGeocodeLocationUseCase(sl<LocationRepository>()),
  );
  sl.registerFactory<LocationSetupCubit>(
    () => LocationSetupCubit(
      searchLocationsUseCase: sl<SearchLocationsUseCase>(),
      getLocationDetailsUseCase: sl<GetLocationDetailsUseCase>(),
      reverseGeocodeLocationUseCase: sl<ReverseGeocodeLocationUseCase>(),
      saveLocationUseCase: sl<SaveLocationUseCase>(),
      locationSessionNotifier: sl<LocationSessionNotifier>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Features - Authentication
  // ---------------------------------------------------------------------------

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDataSource>(),
      sl<SecureStorageService>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<ClearSessionUseCase>(
    () => ClearSessionUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<RequestOtpUseCase>(
    () => RequestOtpUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<VerifyOtpUseCase>(
    () => VerifyOtpUseCase(sl<AuthRepository>()),
  );

  // Blocs
  sl.registerFactory<RequestOtpBloc>(
    () => RequestOtpBloc(sl<RequestOtpUseCase>()),
  );

  // ---------------------------------------------------------------------------
  // Features - Bookings
  // ---------------------------------------------------------------------------

  // Data Sources
  sl.registerLazySingleton<BookingsRemoteDataSource>(
    () => BookingsRemoteDataSourceImpl(sl<DioClient>()),
  );

  // Repository
  sl.registerLazySingleton<BookingsRepository>(
    () => BookingsRepositoryImpl(sl<BookingsRemoteDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton<GetBookingsUseCase>(
    () => GetBookingsUseCase(sl<BookingsRepository>()),
  );

  // Blocs
  sl.registerFactory<BookingsBloc>(
    () => BookingsBloc(sl<GetBookingsUseCase>()),
  );

  // ---------------------------------------------------------------------------
  // Features - Salon Favorites
  // ---------------------------------------------------------------------------

  sl.registerLazySingleton<SalonFavoritesRemoteDataSource>(
    () => SalonFavoritesRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<SalonFavoritesRepository>(
    () => SalonFavoritesRepositoryImpl(sl<SalonFavoritesRemoteDataSource>()),
  );
  sl.registerLazySingleton<AddSalonToFavoritesUseCase>(
    () => AddSalonToFavoritesUseCase(sl<SalonFavoritesRepository>()),
  );
  sl.registerLazySingleton<GetFavoriteSalonsUseCase>(
    () => GetFavoriteSalonsUseCase(sl<SalonFavoritesRepository>()),
  );
  sl.registerLazySingleton<RemoveSalonFromFavoritesUseCase>(
    () => RemoveSalonFromFavoritesUseCase(sl<SalonFavoritesRepository>()),
  );
  sl.registerLazySingleton<SalonFavoritesCubit>(
    () => SalonFavoritesCubit(
      sl<AddSalonToFavoritesUseCase>(),
      sl<RemoveSalonFromFavoritesUseCase>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Features - Profile
  // ---------------------------------------------------------------------------

  // Data Sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl<DioClient>()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<ChangePasswordUseCase>(
    () => ChangePasswordUseCase(sl<ProfileRepository>()),
  );

  // Blocs
  sl.registerFactory<ProfileBloc>(() => ProfileBloc(sl<GetProfileUseCase>()));
  sl.registerFactory<ProfileEditProfileBloc>(
    () => ProfileEditProfileBloc(
      sl<GetProfileUseCase>(),
      sl<UpdateProfileUseCase>(),
    ),
  );
  sl.registerFactory<ProfileChangePasswordBloc>(
    () => ProfileChangePasswordBloc(sl<ChangePasswordUseCase>()),
  );

  // ---------------------------------------------------------------------------
  // Features - Home
  // ---------------------------------------------------------------------------

  // Data Sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(sl<DioClient>()),
  );

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl<HomeRemoteDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton<GetHomeDashboardUseCase>(
    () => GetHomeDashboardUseCase(sl<HomeRepository>()),
  );

  // Blocs
  sl.registerFactory<HomeBloc>(
    () =>
        HomeBloc(sl<GetHomeDashboardUseCase>(), sl<GetSavedLocationUseCase>()),
  );

  // ---------------------------------------------------------------------------
  // Features - Search
  // ---------------------------------------------------------------------------

  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(sl<SearchRemoteDataSource>()),
  );
  sl.registerLazySingleton<SearchCatalogUseCase>(
    () => SearchCatalogUseCase(sl<SearchRepository>()),
  );
  sl.registerFactory<SearchCubit>(
    () => SearchCubit(sl<SearchCatalogUseCase>()),
  );

  // ---------------------------------------------------------------------------
  // Features - Products
  // ---------------------------------------------------------------------------

  // Explore dashboard
  sl.registerLazySingleton<ExploreRemoteDataSource>(
    () => ExploreRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<ExploreRepository>(
    () => ExploreRepositoryImpl(sl<ExploreRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetExploreDashboardUseCase>(
    () => GetExploreDashboardUseCase(sl<ExploreRepository>()),
  );
  sl.registerFactory<ExploreBloc>(
    () => ExploreBloc(
      sl<GetExploreDashboardUseCase>(),
      sl<GetSavedLocationUseCase>(),
    ),
  );

  sl.registerLazySingleton<SalonBookingRemoteDataSource>(
    () => SalonBookingRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<SalonBookingRepository>(
    () => SalonBookingRepositoryImpl(sl<SalonBookingRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetSalonBookingDetailsUseCase>(
    () => GetSalonBookingDetailsUseCase(sl<SalonBookingRepository>()),
  );
  sl.registerLazySingleton<BookAppointmentUseCase>(
    () => BookAppointmentUseCase(sl<SalonBookingRepository>()),
  );
  sl.registerFactory<SalonBookingBloc>(
    () => SalonBookingBloc(
      sl<GetSalonBookingDetailsUseCase>(),
      sl<BookAppointmentUseCase>(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl<DioClient>()),
  );

  // Services
  sl.registerLazySingleton<FavoritesNotifier>(() => FavoritesNotifier());

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      sl<ProductRemoteDataSource>(),
      sl<FavoritesNotifier>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<GetProductDetailsUseCase>(
    () => GetProductDetailsUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<GetFavoritesUseCase>(
    () => GetFavoritesUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<AddToFavoritesUseCase>(
    () => AddToFavoritesUseCase(sl<ProductRepository>()),
  );
  sl.registerLazySingleton<RemoveFromFavoritesUseCase>(
    () => RemoveFromFavoritesUseCase(sl<ProductRepository>()),
  );

  // Blocs
  sl.registerFactory<ProductsBloc>(
    () => ProductsBloc(
      sl<GetProductsUseCase>(),
      sl<AddToFavoritesUseCase>(),
      sl<RemoveFromFavoritesUseCase>(),
      sl<FavoritesNotifier>(),
    ),
  );
  sl.registerFactory<CategoriesBloc>(
    () => CategoriesBloc(sl<GetCategoriesUseCase>()),
  );
  sl.registerFactory<ProductDetailsBloc>(
    () => ProductDetailsBloc(
      sl<GetProductDetailsUseCase>(),
      sl<AddToFavoritesUseCase>(),
      sl<RemoveFromFavoritesUseCase>(),
    ),
  );
  sl.registerFactory<ProfileFavoritesBloc>(
    () => ProfileFavoritesBloc(
      sl<GetFavoriteSalonsUseCase>(),
      sl<RemoveSalonFromFavoritesUseCase>(),
      sl<SalonFavoritesCubit>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Features - Other Features (Add as needed)
  // ---------------------------------------------------------------------------

  // TODO: Add more features here as they're implemented
}

/// Clean up dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
}
