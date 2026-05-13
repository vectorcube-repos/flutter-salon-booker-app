import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_booker_app/core/common/widgets/main_scaffold.dart';
import 'package:salon_booker_app/core/services/location/location_session_notifier.dart';
import 'package:salon_booker_app/core/routing/go_router_refresh_stream.dart';
import 'package:salon_booker_app/core/common/screens/not_found_screen.dart';
import 'package:salon_booker_app/core/services/dependency_injection/injection_container.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:salon_booker_app/features/authentication/presentation/screens/otp_screen.dart';
import 'package:salon_booker_app/features/authentication/presentation/screens/signin_screen.dart';
import 'package:salon_booker_app/features/bookings/presentation/screens/bookings_screen.dart';
import 'package:salon_booker_app/features/home/presentation/screens/home_screen.dart';
import 'package:salon_booker_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:salon_booker_app/features/explore/presentation/screens/services_screen.dart';
import 'package:salon_booker_app/features/explore/presentation/screens/appointment_confirmed_screen.dart';
import 'package:salon_booker_app/features/explore/presentation/screens/saloon_screen.dart';
import 'package:salon_booker_app/features/explore/presentation/screens/saloons_screen.dart';
import 'package:salon_booker_app/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:salon_booker_app/features/explore/presentation/bloc/categories_bloc.dart';
import 'package:salon_booker_app/features/explore/presentation/bloc/salon_booking_bloc.dart';
import 'package:salon_booker_app/features/location/presentation/screens/location_setup_screen.dart';
import 'package:salon_booker_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:salon_booker_app/features/profile/presentation/bloc/profile_change_password_bloc.dart';
import 'package:salon_booker_app/features/profile/presentation/bloc/profile_edit_profile_bloc.dart';
import 'package:salon_booker_app/features/profile/presentation/bloc/profile_favorites_bloc.dart';
import 'package:salon_booker_app/features/profile/presentation/screens/profile_change_password_screen.dart';
import 'package:salon_booker_app/features/profile/presentation/screens/profile_edit_profile_screen.dart';
import 'package:salon_booker_app/features/profile/presentation/screens/profile_favorites_screen.dart';
import 'package:salon_booker_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:salon_booker_app/features/search/presentation/cubit/search_cubit.dart';
import 'package:salon_booker_app/features/search/presentation/screens/search_screen.dart';
import 'package:go_router/go_router.dart';

// Define public routes (routes that don't require authentication)
const _publicRoutes = <String>{'/signin', '/otp'};

GoRouter createRouter({
  required AuthBloc authBloc,
  required LocationSessionNotifier locationSessionNotifier,
  required String initialLocation,
}) {
  Widget buildSaloonsScreen(GoRouterState state) {
    final serviceId =
        state.uri.queryParameters['service_id'] ??
        state.uri.queryParameters['category_id'] ??
        '';
    return BlocProvider(
      key: ValueKey('explore-provider-${state.uri.toString()}'),
      create: (_) =>
          sl<ExploreBloc>()
            ..add(ExploreRequested(serviceId: serviceId, isInitialLoad: true)),
      child: SaloonsScreen(
        key: ValueKey('saloons-${state.uri.toString()}'),
        serviceId: serviceId,
      ),
    );
  }

  return GoRouter(
    refreshListenable: Listenable.merge([
      GoRouterRefreshStream(authBloc.stream),
      locationSessionNotifier,
    ]),
    initialLocation: initialLocation,
    errorBuilder: (context, state) =>
        NotFoundScreen(error: state.error, location: state.uri.toString()),
    redirect: (context, state) {
      final authStatus = authBloc.state.status;
      final currentLocation = state.uri.path;
      final isPublicRoute = _publicRoutes.contains(currentLocation);
      final hasSelectedLocation = locationSessionNotifier.hasSelectedLocation;
      final isLocationSetupRoute = currentLocation == '/location-setup';
      final isUnauthenticatedFlow =
          authStatus == AuthStatus.unauthenticated ||
          authStatus == AuthStatus.accountDisabled;

      if (isUnauthenticatedFlow && !isPublicRoute) {
        return '/signin';
      }

      if (authStatus == AuthStatus.authenticated &&
          !hasSelectedLocation &&
          !isLocationSetupRoute) {
        return '/location-setup';
      }

      if (authStatus == AuthStatus.authenticated && isPublicRoute) {
        return hasSelectedLocation ? '/' : '/location-setup';
      }

      return null;
    },
    routes: [
      // ------------------ PUBLIC ROUTES ------------------
      GoRoute(
        path: '/signin',
        name: 'signin',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) {
          final phone = state.extra is String ? state.extra as String : '';
          return OtpScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/location-setup',
        name: 'location-setup',
        builder: (context, state) => const LocationSetupScreen(),
      ),

      // ------------------ FULL-SCREEN ROUTES (no bottom nav) ------------------
      GoRoute(
        path: '/services',
        name: 'services',
        builder: (_, _) => BlocProvider(
          create: (_) => sl<CategoriesBloc>()..add(const GetCategoriesEvent()),
          child: const ServicesScreen(),
        ),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (_, _) => BlocProvider<SearchCubit>(
          create: (_) => sl<SearchCubit>(),
          child: const SearchScreen(),
        ),
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product',
        builder: (context, state) {
          final rawId = state.pathParameters['id'] ?? '';
          return BlocProvider(
            create: (_) => sl<SalonBookingBloc>(),
            child: SaloonScreen(saloonId: rawId),
          );
        },
      ),
      GoRoute(
        path: '/products-preview',
        name: 'products-preview',
        builder: (_, state) => buildSaloonsScreen(state),
      ),
      GoRoute(
        path: '/appointment-confirmed',
        name: 'appointment-confirmed',
        builder: (_, state) {
          final extra = state.extra is Map<String, String?>
              ? state.extra as Map<String, String?>
              : const <String, String?>{};
          return AppointmentConfirmedScreen(
            salonName: extra['salonName'],
            serviceName: extra['serviceName'],
            staffName: extra['staffName'],
            slotLabel: extra['slotLabel'],
          );
        },
      ),
      GoRoute(
        path: '/bookings-preview',
        name: 'bookings-preview',
        builder: (_, _) => const BookingsScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'profile-edit',
        builder: (context, _) {
          final profile = context.read<ProfileBloc>().state.profile;
          final bloc = sl<ProfileEditProfileBloc>();
          if (profile != null) {
            bloc.add(ProfileEditProfileInitialDataReceived(profile: profile));
          } else {
            bloc.add(const ProfileEditProfileLoadRequested());
          }
          return BlocProvider.value(
            value: bloc,
            child: const ProfileEditProfileScreen(),
          );
        },
      ),
      GoRoute(
        path: '/profile/change-password',
        name: 'profile-change-password',
        builder: (_, _) => BlocProvider(
          create: (_) => sl<ProfileChangePasswordBloc>(),
          child: const ProfileChangePasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/profile/favorites',
        name: 'profile-favorites',
        builder: (_, _) => BlocProvider(
          create: (_) =>
              sl<ProfileFavoritesBloc>()
                ..add(const ProfileFavoritesRequested()),
          child: const ProfileFavoritesScreen(),
        ),
      ),

      // ------------------ PROTECTED ROUTES (with bottom nav) ------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // ------------------ HOME ------------------
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (_, _) => BlocProvider(
                  create: (_) =>
                      sl<HomeBloc>()..add(const GetHomeDashboardEvent()),
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),

          // ------------------ PRODUCTS ------------------
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                name: 'products',
                pageBuilder: (_, state) => NoTransitionPage(
                  key: ValueKey('products-page-${state.uri.toString()}'),
                  child: buildSaloonsScreen(state),
                ),
              ),
            ],
          ),

          // ------------------ CART ------------------
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                name: 'bookings',
                builder: (_, _) => const BookingsScreen(),
              ),
            ],
          ),

          // ------------------ PROFILE ------------------
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
