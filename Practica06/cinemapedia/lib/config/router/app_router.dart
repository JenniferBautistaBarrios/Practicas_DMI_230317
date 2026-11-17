import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/presentation/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [

    GoRoute(
      path: '/splash',
      name: SplashScreen.name,
      builder: (context, state) => const SplashScreen(),
    ),
    
    GoRoute(
      path: '/home/:page',
      name: HomeScreen.name,
      // Transición con fade para que la salida de la pantalla de carga sea suave
      pageBuilder: (context, state) {
        final pageIndex = int.parse( state.pathParameters['page'] ?? '0' );

        return CustomTransitionPage(
          key: state.pageKey,
          child: HomeScreen( pageIndex: pageIndex ),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        );
      },
      routes: [
         GoRoute(
          path: 'movie/:id',
          name: MovieScreen.name,
          builder: (context, state) {
            final movieId = state.pathParameters['id'] ?? 'no-id';

            return MovieScreen( movieId: movieId );
          },
        ),
      ]
    ),



    GoRoute(
      path: '/',
      redirect: (context, _) => '/home/0',
    ),

  ]
);
