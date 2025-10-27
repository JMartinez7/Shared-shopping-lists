import 'package:go_router/go_router.dart';

import '../../features/shared/presentation/presentation.dart';
import '../../features/shopping_lists/shopping_lists.dart';

final routerConfig = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) {
        return const SplashScreen();
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
