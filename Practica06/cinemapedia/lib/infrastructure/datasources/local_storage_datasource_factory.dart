import 'package:cinemapedia/domain/datasources/local_storage_datasource.dart';
import 'package:cinemapedia/infrastructure/datasources/isar_datasource.dart'
    if (dart.library.html) 'package:cinemapedia/infrastructure/datasources/web_storage_datasource.dart'
    as implementation;

LocalStorageDatasource createLocalStorageDatasource() =>
    implementation.createLocalStorageDatasource();
