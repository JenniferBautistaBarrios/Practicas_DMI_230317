import 'package:cinemapedia/config/constants/movie_country.dart';
import 'package:cinemapedia/presentation/providers/actors/actors_repository_provider.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:cinemapedia/presentation/screens/movies/home_screen.dart';
import 'package:cinemapedia/presentation/screens/movies/movie_screen.dart';
import 'package:cinemapedia/presentation/widgets/movies/country_selector.dart';
import 'package:cinemapedia/presentation/widgets/movies/movies_slideshow.dart';
import 'package:cinemapedia/presentation/widgets/movies/movie_horizontal_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

Widget app({
  bool fail = false,
  bool empty = false,
  Widget child = const HomeScreen(),
}) => ProviderScope(
  overrides: [
    movieRepositoryProvider.overrideWith(
      (ref) => FakeMoviesRepository(
        ref.watch(movieCountryProvider),
        fail: fail,
        empty: empty,
      ),
    ),
    actorsRepositoryProvider.overrideWith((ref) => FakeActorsRepository()),
  ],
  child: MaterialApp(home: child),
);

void main() {
  testWidgets('Menu, flags and regional carousel work on a narrow phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('CINEMAPEDIA'), findsOneWidget);
    expect(find.text('MX película 1'), findsWidgets);
    expect(find.text('4.0/5'), findsWidgets);
    expect(find.text('🇲🇽 MX · B'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Abrir menú'));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsOneWidget);
    await tester.tap(find.text('Inicio').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CountrySelector));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutschland'));
    await tester.pumpAndSettle();
    expect(find.text('DE película 1'), findsWidgets);
    expect(find.text('MX película 1'), findsNothing);
    expect(find.text('🇩🇪 DE · 12'), findsWidgets);
    expect(find.text('Startseite'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Swiping changes the carousel page. Double-tapping a direction goes to an edge.
    final pageView = find.descendant(
      of: find.byType(MoviesSlideshow),
      matching: find.byType(PageView),
    );
    await tester.drag(pageView, const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(
      tester.widget<PageView>(pageView).controller!.page,
      closeTo(1, 0.01),
    );
    final arrow = find.descendant(
      of: find.byType(MoviesSlideshow),
      matching: find.byIcon(Icons.chevron_left),
    );
    await tester.tap(arrow);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(arrow);
    await tester.pumpAndSettle();
    expect(
      tester.widget<PageView>(pageView).controller!.page,
      closeTo(0, 0.01),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Section navigation, list gestures and return to start work', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    final mainScroll = find.byType(CustomScrollView);
    final vertical = tester.widget<CustomScrollView>(mainScroll).controller!;
    await tester.tap(find.text('Populares').last);
    await tester.pumpAndSettle();
    expect(vertical.offset, greaterThan(500));
    await tester.tap(find.byTooltip('Volver al inicio'));
    await tester.pumpAndSettle();
    expect(vertical.offset, closeTo(0, 0.1));

    final section = find.byType(MovieHorizontalListview).first;
    await tester.ensureVisible(section);
    await tester.pumpAndSettle();
    final list = find.descendant(of: section, matching: find.byType(ListView));
    await tester.drag(list, const Offset(-250, 0));
    await tester.pumpAndSettle();
    final horizontal = tester.widget<ListView>(list).controller!;
    expect(horizontal.offset, greaterThan(0));
    final previous = find.descendant(
      of: section,
      matching: find.byIcon(Icons.chevron_left_rounded),
    );
    await tester.tap(previous);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(previous);
    await tester.pumpAndSettle();
    expect(horizontal.offset, closeTo(0, 0.1));
    await tester.tap(find.byTooltip('Volver al inicio'));
    await tester.pumpAndSettle();
    await tester.drag(mainScroll, const Offset(0, 350));
    await tester.pumpAndSettle();
    expect(find.byType(RefreshProgressIndicator), findsNothing);
    expect(find.text('MX película 1'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Empty regions show a message and keep country navigation available',
    (tester) async {
      await tester.pumpWidget(app(empty: true));
      await tester.pumpAndSettle();
      expect(
        find.text('No hay películas disponibles en esta región.'),
        findsWidgets,
      );
      expect(find.byType(CountrySelector), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('API errors provide retry and do not hide the menu', (
    tester,
  ) async {
    await tester.pumpWidget(app(fail: true));
    await tester.pumpAndSettle();
    expect(find.text('Reintentar'), findsWidgets);
    expect(find.byTooltip('Abrir menú'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.text('Reintentar').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Changing country on details replaces title and certification', (
    tester,
  ) async {
    await tester.pumpWidget(app(child: const MovieScreen(movieId: '1')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('MX película 1'), findsOneWidget);
    expect(find.text('🇲🇽 MX · B'), findsOneWidget);
    await tester.tap(find.byType(CountrySelector));
    await tester.pumpAndSettle();
    await tester.tap(find.text('United States'));
    await tester.pumpAndSettle();
    expect(find.text('US película 1'), findsOneWidget);
    expect(find.text('🇺🇸 US · PG-13'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('All countries render without overflow at a larger text scale', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = ProviderContainer(
      overrides: [
        movieRepositoryProvider.overrideWith(
          (ref) => FakeMoviesRepository(ref.watch(movieCountryProvider)),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const HomeScreen(),
        ),
      ),
    );
    for (final country in MovieCountry.values) {
      container.read(movieCountryProvider.notifier).state = country;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: country.code);
    }
  });
}
