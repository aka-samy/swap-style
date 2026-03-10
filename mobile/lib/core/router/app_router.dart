import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

// Auth screens
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/register_screen.dart';

// Main tab screens
import '../../features/discovery/screens/discovery_screen.dart';
import '../../features/matching/screens/match_list_screen.dart';
import '../../features/items/screens/closet_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

// Detail screens
import '../../features/items/screens/add_item_screen.dart';
import '../../features/items/screens/edit_item_screen.dart';
import '../../features/matching/screens/match_detail_screen.dart';
import '../../features/chat/screens/conversation_screen.dart';
import '../../features/profile/screens/public_profile_screen.dart';
import '../../features/profile/screens/wishlist_screen.dart';
import '../../features/gamification/screens/gamification_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/discover',
    redirect: (context, state) {
      final isAuth = authState.status == AuthStatus.authenticated;
      final isAuthRoute = state.matchedLocation == '/sign-in' ||
          state.matchedLocation == '/register';

      if (!isAuth && !isAuthRoute) return '/sign-in';
      if (isAuth && isAuthRoute) return '/discover';
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main app with bottom nav
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                builder: (context, state) => const DiscoveryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/matches',
                builder: (context, state) => const MatchListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => MatchDetailScreen(
                      matchId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'chat',
                        builder: (context, state) {
                          final matchId = state.pathParameters['id']!;
                          final userId =
                              ref.read(authProvider).userId ?? '';
                          return ConversationScreen(
                            matchId: matchId,
                            currentUserId: userId,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/closet',
                builder: (context, state) => const ClosetScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddItemScreen(),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    builder: (context, state) => EditItemScreen(
                      itemId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'wishlist',
                    builder: (context, state) => const WishlistScreen(),
                  ),
                  GoRoute(
                    path: 'achievements',
                    builder: (context, state) =>
                        const GamificationScreen(),
                  ),
                  GoRoute(
                    path: 'user/:userId',
                    builder: (context, state) => PublicProfileScreen(
                      userId: state.pathParameters['userId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Matches',
          ),
          NavigationDestination(
            icon: Icon(Icons.checkroom_outlined),
            selectedIcon: Icon(Icons.checkroom),
            label: 'Closet',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
