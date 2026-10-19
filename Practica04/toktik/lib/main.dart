import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme/app_theme.dart';
import 'domain/services/seasonal_audio_policy.dart';
import 'domain/services/local_video_playback_service.dart';
import 'infrastructure/services/bundled_video_playback_service.dart';
import 'infrastructure/datasources/local_video_datasource_impl.dart';
import 'infrastructure/repositories/video_posts_repository_impl.dart';
import 'infrastructure/repositories/local_preferences_repository.dart';
import 'infrastructure/repositories/feed_repositories.dart';
import 'infrastructure/datasources/peertube_video_datasource.dart';
import 'infrastructure/datasources/youtube_video_datasource.dart';
import 'infrastructure/repositories/youtube_repository_impl.dart';
import 'infrastructure/services/seasonal_audio.dart';
import 'infrastructure/services/platform_app_icon_service.dart';
import 'presentation/providers/preferences_provider.dart';
import 'presentation/providers/peertube_comments_provider.dart';
import 'presentation/providers/youtube_provider.dart';
import 'presentation/screens/discover/discover_screen.dart';
import 'presentation/widgets/shared/app_startup_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  final storage = await SharedPreferences.getInstance();
  runApp(MyApp(storage: storage));
}

class MyApp extends StatefulWidget {
  final SharedPreferences storage;
  const MyApp({super.key, required this.storage});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _client = http.Client();
  final _audio = SeasonalAudio();
  final _localPlayback = BundledVideoPlaybackService();
  final _appIcon = PlatformAppIconService();
  late final PreferencesProvider _preferences;
  late final DiscoverFeedRepository _discover;
  late final ForYouFeedRepository _forYou;
  late final FavoritesFeedRepository _favorites;
  late final YouTubeVideoDatasource _youtubeDatasource;
  late final YouTubeProvider _youtubeProvider;
  late final PeerTubeCommentsProvider _peerTubeCommentsProvider;
  Timer? _dateTimer;
  final _seasonalAudioPolicy = SeasonalAudioPolicy();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final preferences = LocalPreferencesRepository(widget.storage);
    _preferences = PreferencesProvider(preferences)
      ..addListener(_onPreferences);
    final localRepository = VideoPostsRepositoryImpl(
      videosDatasource: LocalVideoDatasource(),
    );
    _discover = DiscoverFeedRepository({
      'PeerTube': VideoPostsRepositoryImpl(
        videosDatasource: PeerTubeVideoDatasource(_client, widget.storage),
      ),
    });
    _forYou = ForYouFeedRepository(localRepository);
    _favorites = FavoritesFeedRepository(preferences);
    _youtubeDatasource = YouTubeVideoDatasource(client: _client);
    _youtubeProvider = YouTubeProvider(
      YouTubeRepositoryImpl(_youtubeDatasource),
      storage: widget.storage,
    );
    _peerTubeCommentsProvider = PeerTubeCommentsProvider(_client);
    _dateTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _preferences.refreshDate(),
    );
    _onPreferences();
  }

  void _onPreferences() {
    final season = _preferences.season;
    _appIcon.applySeason(season).catchError((Object error) {
      debugPrint('No se pudo actualizar el icono de la app: $error');
    });
    if (_seasonalAudioPolicy.shouldPlay(
      season,
      enabled: _preferences.repository.seasonalAudio,
    )) {
      final style = SeasonStyle.forSeason(season);
      _audio
          .play(style.melody, asset: style.audioAsset)
          .catchError((Object _) {});
    } else if (!_preferences.repository.seasonalAudio) {
      _audio.stop().catchError((Object _) {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _preferences.refreshDate();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      _audio.stop().catchError((Object _) {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dateTimer?.cancel();
    _preferences.removeListener(_onPreferences);
    _preferences.dispose();
    _peerTubeCommentsProvider.dispose();
    _client.close();
    _audio.dispose();
    _youtubeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Provider<LocalVideoPlaybackService>.value(
        value: _localPlayback,
        child: ChangeNotifierProvider<YouTubeProvider>.value(
          value: _youtubeProvider,
          child: ChangeNotifierProvider<PeerTubeCommentsProvider>.value(
            value: _peerTubeCommentsProvider,
            child: ChangeNotifierProvider.value(
              value: _preferences,
              child: Consumer<PreferencesProvider>(
                builder: (context, preferences, _) => MaterialApp(
                  title: 'KittyTokTik',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme(season: preferences.season).getTheme(),
                  home: AppStartupGate(
                    child: DiscoverScreen(
                      repositories: [_discover, _forYou, _favorites],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
