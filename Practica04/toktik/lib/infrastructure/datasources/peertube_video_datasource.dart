import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/video_post.dart';
import 'direct_video_datasource.dart';
import 'wikimedia_video_datasource.dart';

/// Sepia Search descubre videos; la API de cada instancia entrega sus archivos.
/// No se carga el reproductor web ni se necesita una cuenta de PeerTube.
class PeerTubeVideoDatasource extends DirectVideoDatasource {
  static const _queries = [
    'food',
    'cooking',
    'recipe',
    'sports',
    'football',
    'soccer',
    'basketball',
    'NASA',
    'space',
    'science',
    'gaming',
    'video game',
    'comida',
    'cocina',
    'receta',
    'deportes',
    'futbol',
    'ciencia',
    'videojuegos',
    'tecnologia',
    'music',
  ];
  static const _licenses = {
    1: 'https://creativecommons.org/licenses/by/4.0/',
    2: 'https://creativecommons.org/licenses/by-sa/4.0/',
    3: 'https://creativecommons.org/licenses/by-nd/4.0/',
    4: 'https://creativecommons.org/licenses/by-nc/4.0/',
    5: 'https://creativecommons.org/licenses/by-nc-sa/4.0/',
    6: 'https://creativecommons.org/licenses/by-nc-nd/4.0/',
    7: 'https://creativecommons.org/publicdomain/zero/1.0/',
    8: 'https://creativecommons.org/publicdomain/zero/1.0/',
  };
  final _pages = <int, List<VideoPost>>{};
  final _seen = <String>{};
  final _random = Random();
  late int _query;
  final _starts = List<int>.filled(_queries.length, 0);
  final _finishedQueries = <int>{};
  PeerTubeVideoDatasource(http.Client client, SharedPreferences storage)
    : super(client, storage, 'peertube.categories.v3') {
    _query = _random.nextInt(_queries.length);
  }

  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) async {
    if (page < 1) return [];
    for (var logical = 1; logical <= page; logical++) {
      if (_pages.containsKey(logical)) continue;
      final videos = <VideoPost>[];
      var attempts = 0;
      while (videos.isEmpty &&
          _finishedQueries.length < _queries.length &&
          attempts < _queries.length) {
        final query = _query;
        final start = _starts[query];
        _query = (_query + 1) % _queries.length;
        attempts++;
        final data = await getJson(
          Uri.https('sepiasearch.org', '/api/v1/search/videos', {
            'search': _queries[query],
            'start': '$start',
            'count': '40',
            'durationMax': '90',
            'nsfw': 'false',
          }),
          'search.$query.$start',
        );
        final items = (data['data'] as List? ?? [])
            .cast<Map<String, dynamic>>();
        final candidates = items.where((item) {
          final ratio = num.tryParse('${item['aspectRatio']}') ?? 0;
          final duration = DirectVideoDatasource.number(item['duration']);
          return ratio > 0 &&
              ratio <= 1 / 1.4 &&
              duration > 0 &&
              duration <= 90 &&
              item['nsfw'] != true &&
              item['isLive'] != true &&
              _licenses.containsKey(
                DirectVideoDatasource.number(item['licence']?['id']),
              );
        }).toList();
        // Una instancia federada caída no invalida el resto del catálogo.
        var failures = 0;
        final results = await Future.wait(
          candidates.map((item) async {
            try {
              return await _resolve(item);
            } catch (_) {
              failures++;
              return null;
            }
          }),
        );
        if (candidates.isNotEmpty && failures == candidates.length) {
          throw StateError('PeerTube: instancias no disponibles');
        }
        final found = results.whereType<VideoPost>().toList()
          ..shuffle(_random);
        for (final video in found) {
          if (_seen.add(video.id)) videos.add(video);
        }
        final next = start + items.length;
        final total = DirectVideoDatasource.number(data['total']);
        if (items.isEmpty ||
            (total > 0 && next >= total) ||
            (total <= 0 && items.length < 40)) {
          _finishedQueries.add(query);
        } else {
          _starts[query] = next;
        }
      }
      _pages[logical] = videos;
    }
    return _pages[page] ?? [];
  }

  Future<VideoPost?> _resolve(Map<String, dynamic> item) async {
    final watch = Uri.tryParse('${item['url']}');
    if (watch?.scheme != 'https' || watch!.host.isEmpty) return null;
    final uuid = '${item['uuid']}';
    final data = await getJson(
      Uri.https(watch.host, '/api/v1/videos/$uuid'),
      '${watch.host}.$uuid',
    );
    final ratio = num.tryParse('${data['aspectRatio']}') ?? 0;
    final license = DirectVideoDatasource.number(data['licence']?['id']);
    if (ratio <= 0 ||
        ratio > 1 / 1.4 ||
        !_licenses.containsKey(license) ||
        data['nsfw'] == true ||
        data['isLive'] == true) {
      return null;
    }
    final files =
        <Map<String, dynamic>>[
            ...(data['files'] as List? ?? []).cast<Map<String, dynamic>>(),
            for (final playlist in data['streamingPlaylists'] as List? ?? [])
              ...(playlist['files'] as List? ?? [])
                  .cast<Map<String, dynamic>>(),
          ].where((file) {
            final width = DirectVideoDatasource.number(file['width']);
            final height = DirectVideoDatasource.number(file['height']);
            final uri = Uri.tryParse('${file['fileUrl']}');
            return width > 0 &&
                height / width >= 1.4 &&
                file['hasAudio'] == true &&
                file['hasVideo'] == true &&
                uri?.scheme == 'https' &&
                uri!.path.endsWith('.mp4');
          }).toList()
          ..sort(
            (a, b) => (DirectVideoDatasource.number(a['width']) - 480)
                .abs()
                .compareTo(
                  (DirectVideoDatasource.number(b['width']) - 480).abs(),
                ),
          );
    if (files.isEmpty) return null;
    return VideoPost(
      caption: '${data['name'] ?? item['name']}',
      videoUrl: '${files.first['fileUrl']}',
      source: VideoSource.peertube,
      externalId: '${watch.host}/$uuid',
      likes: DirectVideoDatasource.number(data['likes']),
      views: DirectVideoDatasource.number(data['views']),
      attributionUrl: watch.toString(),
      licenseUrl: _licenses[license],
      description:
          '${WikimediaVideoDatasource.plainText('${data['description'] ?? ''}')}\nAutor: ${data['account']?['displayName'] ?? data['account']?['name'] ?? watch.host} · PeerTube · ${data['licence']?['label']}. Se conserva el encuadre original.',
    );
  }
}
