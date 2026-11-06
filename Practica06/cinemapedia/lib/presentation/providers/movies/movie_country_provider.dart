import 'package:cinemapedia/config/constants/movie_country.dart';
import 'package:flutter_riverpod/legacy.dart';

final movieCountryProvider = StateProvider<MovieCountry>(
  (ref) => MovieCountry.mexico,
);
