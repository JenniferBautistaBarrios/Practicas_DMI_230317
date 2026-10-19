import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/video_post.dart';
import 'direct_video_datasource.dart';
import 'wikimedia_video_datasource.dart';

/// Videos directos del catálogo público de NASA; no necesita API key.
class NasaVideoDatasource extends DirectVideoDatasource {
  static const _queries = [
    'rocket launch',
    'astronaut',
    'international space station',
    'mars rover',
    'earth from space',
    'solar system',
    'space telescope',
    'moon mission',
    'satellite weather',
    'volcano earth observation',
    'ocean from space',
    'aircraft test',
    'NASA technology',
  ];
  static const _pageSize = 30;
  final _pages = <int, List<VideoPost>>{};
  final _seen = <String>{};
  int _query = 0;
  int _searchPage = 1;

  NasaVideoDatasource(http.Client client, SharedPreferences storage)
    : super(client, storage, 'nasa.videos.v1');

  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) async {
    if (page < 1) return [];
    for (var logical = 1; logical <= page; logical++) {
      if (_pages.containsKey(logical)) continue;
      final videos = <VideoPost>[];
      while (videos.isEmpty && _query < _queries.length) {
        final queryIndex = _query;
        final data = await getJson(
          Uri.https('images-api.nasa.gov', '/search', {
            'q': _queries[queryIndex],
            'media_type': 'video',
            'page': '$_searchPage',
            'page_size': '$_pageSize',
          }),
          'search.$queryIndex.$_searchPage',
        );
        final collection = data['collection'] as Map<String, dynamic>? ?? {};
        final items = (collection['items'] as List? ?? [])
            .cast<Map<String, dynamic>>();
        final results = await Future.wait(
          items.map((item) async {
            try {
              return await _resolve(item);
            } catch (_) {
              return null;
            }
          }),
        );
        for (final video in results.whereType<VideoPost>()) {
          if (_seen.add(video.id)) videos.add(video);
        }

        final metadata = collection['metadata'] as Map<String, dynamic>? ?? {};
        final totalHits = DirectVideoDatasource.number(metadata['total_hits']);
        if (items.isEmpty ||
            (_searchPage * _pageSize >= totalHits && totalHits > 0)) {
          _query++;
          _searchPage = 1;
        } else {
          _searchPage++;
        }
      }
      _pages[logical] = videos;
    }
    return _pages[page] ?? [];
  }

  Future<VideoPost?> _resolve(Map<String, dynamic> item) async {
    final data = (item['data'] as List? ?? []).firstOrNull;
    if (data == null || data['media_type'] != 'video') return null;
    final id = '${data['nasa_id'] ?? ''}';
    if (id.isEmpty) return null;

    final manifest = await getJson(
      Uri.https('images-api.nasa.gov', '/asset/$id'),
      'asset.$id',
    );
    final collection = manifest['collection'] as Map<String, dynamic>? ?? {};
    final files = (collection['items'] as List? ?? [])
        .map((entry) => Uri.tryParse('${entry['href']}'))
        .whereType<Uri>()
        .where(
          (uri) =>
              (uri.scheme == 'http' || uri.scheme == 'https') &&
              uri.host == 'images-assets.nasa.gov' &&
              uri.path.toLowerCase().endsWith('.mp4'),
        )
        .map((uri) => uri.replace(scheme: 'https'))
        .toList();
    if (files.isEmpty) return null;
    files.sort((a, b) => _qualityRank(a).compareTo(_qualityRank(b)));
    final title = WikimediaVideoDatasource.plainText(
      '${data['title'] ?? 'Video NASA'}',
    );
    final description = WikimediaVideoDatasource.plainText(
      '${data['description'] ?? ''}',
    );
    final creator = data['photographer'] ?? data['secondary_creator'];

    return VideoPost(
      caption: title,
      videoUrl: files.first.toString(),
      source: VideoSource.nasa,
      externalId: id,
      attributionUrl: 'https://images.nasa.gov/details/$id',
      description:
          '$description\nAutor: ${creator ?? 'NASA'} · NASA. Material del catálogo público de NASA.',
    );
  }

  int _qualityRank(Uri uri) {
    final path = uri.path.toLowerCase();
    if (path.contains('~small')) return 0;
    if (path.contains('~medium')) return 1;
    if (path.contains('~large')) return 2;
    if (path.contains('~orig')) return 4;
    return 3;
  }
}
