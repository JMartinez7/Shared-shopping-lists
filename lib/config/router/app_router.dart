import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth.dart';
import '../../features/shared/presentation/presentation.dart';
import '../../features/shopping_lists/shopping_lists.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.when(
        data: (user) => user != null,
        loading: () => false,
        error: (_, __) => false,
      );

      final isOnLoginPage = state.matchedLocation == '/login';
      final isOnSplashPage = state.matchedLocation == '/splash';

      // If loading auth state, stay on splash
      if (authState.isLoading) {
        return isOnSplashPage ? null : '/splash';
      }

      // If not logged in and not on login page, redirect to login
      if (!isLoggedIn && !isOnLoginPage) {
        return '/login';
      }

      // If logged in and on login page, redirect to home
      if (isLoggedIn && isOnLoginPage) {
        return '/home';
      }

      // If logged in and on splash page, redirect to home
      if (isLoggedIn && isOnSplashPage) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/shopping-list',
        builder: (context, state) {
          final shoppingList = state.extra as ShoppingList;
          return ShoppingListScreen(shoppingList: shoppingList);
        },
      ),
    ],
  );
});
