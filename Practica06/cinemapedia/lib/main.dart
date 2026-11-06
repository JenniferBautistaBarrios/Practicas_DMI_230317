import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cinemapedia/config/constants/movie_country.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';

import 'package:cinemapedia/config/router/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(movieCountryProvider);
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Cinemapedia',
      locale: Locale(country.languageCode, country.code),
      supportedLocales: MovieCountry.values
          .map((item) => Locale(item.languageCode, item.code))
          .toList(),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
    );
  }
}
