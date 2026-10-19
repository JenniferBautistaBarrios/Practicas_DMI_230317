import 'dart:convert';

import 'package:toktik/infrastructure/services/bundled_video_playback_service.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toktik/domain/entities/season.dart';
import 'package:toktik/domain/services/seasonal_audio_policy.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/datasources/local_video_datasource_impl.dart';
import 'package:toktik/infrastructure/repositories/feed_repositories.dart';
import 'package:toktik/infrastructure/repositories/local_preferences_repository.dart';
import 'package:toktik/infrastructure/repositories/video_posts_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const video = VideoPost(
    caption: 'Prueba',
    videoUrl: 'assets/videos/1.mp4',
    likes: 10,
  );
  late SharedPreferences storage;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await SharedPreferences.getInstance();
  });
  test('Catálogo local omite MP4 ausentes', () async {
    final local = LocalVideoDatasource(
      assetPaths: () async => {'assets/videos/1.mp4'},
    );
    expect(await local.getTrendingVideosByPage(1), hasLength(1));
    expect(await local.getTrendingVideosByPage(2), isEmpty);
    expect(
      LocalVideoDatasource(assetPaths: () async => {})
          .getTrendingVideosByPage(1),
      throwsStateError,
    );
  });
  test(
    'Los 13 MP4 aparecen en orden natural y nuevos archivos se detectan',
    () async {
      final local = LocalVideoDatasource(
        assetPaths: () async => {
          for (var i = 1; i <= 13; i++) 'assets/videos/$i.mp4',
          'assets/videos/readme.md',
          'assets/icons/demo.mp4',
        },
      );
      final videos = await local.getTrendingVideosByPage(1);
      expect(videos.map((v) => v.videoUrl), [
        for (var i = 1; i <= 13; i++) 'assets/videos/$i.mp4',
      ]);
      expect(videos.map((v) => v.id).toSet(), hasLength(13));
      final extended = LocalVideoDatasource(
        assetPaths: () async => {'assets/videos/14.mp4', 'assets/videos/2.mp4'},
      );
      expect(
        (await extended.getTrendingVideosByPage(1)).last.videoUrl,
        'assets/videos/14.mp4',
      );
    },
  );
  test(
    'Bundle real incluye los 13 videos sin depender del catálogo de ocho',
    () async {
      final videos = await LocalVideoDatasource().getTrendingVideosByPage(1);
      expect(videos, hasLength(13));
      expect(videos.last.videoUrl, 'assets/videos/13.mp4');
    },
  );
  test(
    'Variante compatible conserva identidad y fallback de assets nuevos',
    () async {
      final service = BundledVideoPlaybackService(
        assetPaths: () async => {
          'assets/videos/1.mp4',
          'assets/videos/playback/1.mp4',
          'assets/videos/14.mp4',
        },
      );
      expect(
        await service.resolve('assets/videos/1.mp4'),
        'assets/videos/playback/1.mp4',
      );
      expect(
        await service.resolve('assets/videos/14.mp4'),
        'assets/videos/14.mp4',
      );
    },
  );
  test('Sonido activo por defecto y mute explícito persiste', () async {
    final prefs = LocalPreferencesRepository(storage);
    expect(prefs.muted, false);
    await prefs.setMuted(true);
    expect(LocalPreferencesRepository(storage).muted, true);
    await prefs.setMuted(false);
    expect(LocalPreferencesRepository(storage).muted, false);
  });
  test('El mute de video no afecta la melodía de temporada', () {
    final policy = SeasonalAudioPolicy();
    expect(
      policy.shouldPlay(Season.halloween, enabled: true),
      true,
    );
    expect(
      policy.shouldPlay(Season.halloween, enabled: true),
      false,
    );
    expect(
      policy.shouldPlay(Season.halloween, enabled: true),
      false,
    );
    expect(
      policy.shouldPlay(Season.halloween, enabled: true),
      false,
    );
    expect(
      policy.shouldPlay(Season.christmas, enabled: true),
      true,
    );
    expect(
      policy.shouldPlay(Season.valentines, enabled: true),
      true,
    );
    expect(
      policy.shouldPlay(Season.normal, enabled: false),
      false,
    );
    expect(
      policy.shouldPlay(Season.normal, enabled: true),
      false,
    );
  });
  test('Temporadas y límites de fechas', () {
    expect(seasonForDate(DateTime(2026, 10, 1)), Season.halloween);
    expect(seasonForDate(DateTime(2026, 11, 1)), Season.normal);
    expect(seasonForDate(DateTime(2026, 12, 31)), Season.christmas);
    expect(seasonForDate(DateTime(2027, 1, 1)), Season.normal);
    expect(seasonForDate(DateTime(2027, 2, 14)), Season.valentines);
    expect(seasonForDate(DateTime(2027, 2, 15)), Season.normal);
  });
  test('Like suma, persiste, resta y se reactiva sin duplicar', () async {
    var prefs = LocalPreferencesRepository(storage);
    await prefs.toggleLike(video);
    prefs = LocalPreferencesRepository(storage);
    expect(prefs.likes(video), 11);
    expect(prefs.favorites.single.id, video.id);
    await prefs.toggleLike(video);
    prefs = LocalPreferencesRepository(storage);
    expect(prefs.likes(video), 10);
    expect(prefs.favorites, isEmpty);
    await prefs.toggleLike(video);
    expect(prefs.likes(video), 11);
    final json = jsonDecode(storage.getString('toktik.preferences.v1')!);
    expect(json['likes'][video.id]['count'], 11);
  });
  test('Cada video guarda su propio Me gusta y suma solo uno', () async {
    final first = LocalPreferencesRepository(storage);
    const secondVideo = VideoPost(
      caption: 'Otro video',
      videoUrl: 'assets/videos/2.mp4',
      likes: 4,
    );

    await first.toggleLike(video);
    expect(first.likes(video), 11);
    expect(first.isLiked(video), isTrue);
    expect(first.likes(secondVideo), 4);
    expect(first.isLiked(secondVideo), isFalse);

    final restored = LocalPreferencesRepository(storage);
    expect(restored.isLiked(video), isTrue);
    expect(restored.likes(video), 11);
    expect(restored.isLiked(secondVideo), isFalse);
    await restored.toggleLike(secondVideo);
    expect(restored.likes(secondVideo), 5);
    expect(restored.likes(video), 11);
  });
  test(
    'Contador corrige datos antiguos que no coinciden con el Me gusta',
    () async {
      const zeroLikeVideo = VideoPost(
        caption: 'Sin likes',
        videoUrl: 'assets/videos/1.mp4',
      );
      await storage.setString(
        'toktik.preferences.v1',
        jsonEncode({
          'likes': {
            zeroLikeVideo.id: {
              'video': zeroLikeVideo.toJson(),
              'liked': true,
              'count': 0,
            },
          },
        }),
      );

      final restored = LocalPreferencesRepository(storage);
      expect(restored.isLiked(zeroLikeVideo), isTrue);
      expect(restored.likes(zeroLikeVideo), 1);

      await restored.toggleLike(zeroLikeVideo);
      expect(restored.isLiked(zeroLikeVideo), isFalse);
      expect(restored.likes(zeroLikeVideo), 0);
      expect(LocalPreferencesRepository(storage).likes(zeroLikeVideo), 0);
    },
  );
  test('Escrituras concurrentes conservan favoritos y preferencias', () async {
    final prefs = LocalPreferencesRepository(storage);
    await Future.wait([
      prefs.toggleLike(video),
      prefs.toggleLike(
        const VideoPost(caption: 'Segundo', videoUrl: 'assets/videos/2.mp4'),
      ),
      prefs.setMuted(false),
    ]);
    final restored = LocalPreferencesRepository(storage);
    expect(restored.favorites, hasLength(2));
    expect(restored.muted, false);
  });
  test(
    'Override de temporada persiste y automático elimina override',
    () async {
      final prefs = LocalPreferencesRepository(storage);
      await prefs.setSeason(Season.christmas);
      await prefs.setSeasonalAudio(false);
      final restored = LocalPreferencesRepository(storage);
      expect(restored.seasonOverride, Season.christmas);
      expect(restored.seasonalAudio, false);
      await restored.setSeason(null);
      expect(LocalPreferencesRepository(storage).seasonOverride, isNull);
    },
  );
  test('Descubrir excluye locales aunque una fuente los devuelva', () async {
    final repo = DiscoverFeedRepository({
      'Local por error': VideoPostsRepositoryImpl(
        videosDatasource: LocalVideoDatasource(
          assetPaths: () async => {'assets/videos/1.mp4'},
        ),
      ),
    });
    expect((await repo.load(1)).videos, isEmpty);
  });
  test('Favoritos conserva locales y remotos de ambas secciones', () async {
    final prefs = LocalPreferencesRepository(storage);
    const remote = VideoPost(
      caption: 'Remoto',
      videoUrl: 'https://cdn.test/video.mp4',
      source: VideoSource.peertube,
      externalId: '123',
    );
    await prefs.toggleLike(video);
    await prefs.toggleLike(remote);
    final favorites = FavoritesFeedRepository(prefs);
    expect((await favorites.load(1)).videos.map((v) => v.source).toSet(), {
      VideoSource.local,
      VideoSource.peertube,
    });
    expect((await favorites.load(2)).videos, isEmpty);
    await prefs.toggleLike(video);
    expect(favorites.savedVideos.single.id, remote.id);
  });
}
