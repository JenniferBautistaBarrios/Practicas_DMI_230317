import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/youtube_video.dart';
import '../../../domain/entities/video_post.dart';
import '../../../domain/repositories/feed_repository.dart';
import '../../providers/discover_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/youtube_provider.dart';
import '../../widgets/settings/season_settings.dart';
import '../../widgets/shared/season_splash.dart';
import '../../widgets/shared/youtube_api_view.dart';
import '../../widgets/shared/video_scrollable_view.dart';
import '../video_details/youtube_video_details_screen.dart';

class DiscoverScreen extends StatefulWidget {
  final List<FeedRepository> repositories;
  const DiscoverScreen({super.key, required this.repositories});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final List<DiscoverProvider> _feeds;
  // La app vuelve a abrir en el feed vertical original; Discovery se abre
  // desde el botón superior y las pestañas inferiores siguen disponibles.
  int _tab = 0;
  @override
  void initState() {
    super.initState();
    _feeds = widget.repositories
        .map((r) => DiscoverProvider(repository: r))
        .toList();
    _tabs = TabController(length: 3, initialIndex: 0, vsync: this)
      ..addListener(_selectTab);
    _feeds[1].loadNextPage();
  }

  void _selectTab() {
    final index = _tabs.index;
    if (_tab == index) return;
    setState(() => _tab = index);
    if (index == 0 && _feeds[1].initialLoading) {
      _feeds[1].loadNextPage();
    }
  }

  void _openYouTubeDetails(YouTubeVideo video, {bool autoPlay = false}) {
    final preferences = context.read<PreferencesProvider>();
    final favorite = video.toVideoPost();
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => YouTubeVideoDetailsScreen(
        video: video,
        autoPlay: autoPlay,
        isFavorite: preferences.repository.isLiked(favorite),
        onFavoriteToggle: () => preferences.toggleLike(favorite),
      ),
    ));
  }

  @override
  void dispose() {
    _tabs.removeListener(_selectTab);
    _tabs.dispose();
    for (final feed in _feeds) {
      feed.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _buildContent(context);

  Widget _buildContent(BuildContext context) {
    context.watch<PreferencesProvider>();
    final favorites =
        (widget.repositories[2] as FavoritesRepository).savedVideos;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colors.surfaceContainer, colors.surface],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: .16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: .12),
                        blurRadius: 20,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: NavigationBarTheme(
                      data: NavigationBarThemeData(
                        backgroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        indicatorColor: colors.primary.withValues(alpha: .14),
                        labelTextStyle:
                            WidgetStateProperty.resolveWith<TextStyle?>(
                          (states) => TextStyle(
                            fontSize: 11,
                            fontWeight: states.contains(WidgetState.selected)
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: states.contains(WidgetState.selected)
                                ? colors.primary
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      child: NavigationBar(
                        height: 58,
                        selectedIndex: _tab,
                        onDestinationSelected: _tabs.animateTo,
                        labelBehavior:
                            NavigationDestinationLabelBehavior.alwaysShow,
                        destinations: const [
                          NavigationDestination(
                            icon: Icon(Icons.home_outlined),
                            selectedIcon: Icon(Icons.home_rounded),
                            label: 'Inicio',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.explore_outlined),
                            selectedIcon: Icon(Icons.explore_rounded),
                            label: 'Discovery',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.favorite_border_rounded),
                            selectedIcon: Icon(Icons.favorite_rounded),
                            label: 'Me gusta',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: 44,
                      height: 42,
                      child: IconButton.filledTonal(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Tonos y temporada',
                        onPressed: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const SeasonSettings(),
                        ),
                        icon: const Icon(Icons.music_note_rounded, size: 21),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _feedView(1),
                  _discoverView(),
                  _favoritesView(favorites),
                ],
              ),
            ),
        ],
        ),
    );
  }
  Widget _favoritesView(List<VideoPost> favorites) => favorites.isEmpty
      ? const Center(child: Text('Guarda videos con el corazÃ³n para verlos aquÃ­.'))
      : VideoScrollableView(
          key: const ValueKey('favorites'),
          videos: favorites,
          active: _tab == 2,
        );
  Widget _feedView(int index) => ListenableBuilder(
    listenable: _feeds[index],
    builder: (context, _) {
      final feed = _feeds[index];
      if (feed.initialLoading) {
        return const SeasonSplash();
      }
      if (feed.videos.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(feed.error ?? 'No hay videos disponibles.'),
              TextButton(
                onPressed: feed.loadNextPage,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      }
      return Stack(
        fit: StackFit.expand,
        children: [
          VideoScrollableView(
            key: ValueKey(index == 0 ? 'discover-videos' : 'for-you-videos'),
            videos: feed.videos,
            active: _tab == 0,
            onNearEnd: feed.loadNextPage,
          ),
          if (feed.loading)
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      );
    },
  );

  Widget _discoverView() => NotificationListener<ScrollNotification>(
    onNotification: (notification) {
      final youtube = context.read<YouTubeProvider>();
      if (_tab == 1 &&
          notification.metrics.axis == Axis.vertical &&
          notification.metrics.extentAfter < 700 &&
          youtube.hasMoreVideos &&
          !youtube.loadingMoreVideos) {
        youtube.loadMoreVideos();
      }
      return false;
    },
    child: ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 10,
        16,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: [
        Row(
          children: [
            Icon(Icons.explore_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: 10),
            Text('Discovery', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const Spacer(),
            IconButton.filledTonal(
              tooltip: 'Temporada',
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const SeasonSettings(),
              ),
              icon: const Icon(Icons.tune_rounded),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(children: [
          Text('Tendencias musicales · YouTube', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(width: 8),
          Icon(Icons.local_fire_department_rounded, color: Theme.of(context).colorScheme.primary),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          height: 205,
          child: Consumer<YouTubeProvider>(
            builder: (context, youtube, _) {
              if (youtube.trendingVideos.isEmpty) {
                if (youtube.loadingTrendingVideos) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Center(
                  child: TextButton.icon(
                    onPressed: () => youtube.loadTrendingMusic(force: true),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(youtube.trendingError ?? 'No hay tendencias disponibles.'),
                  ),
                );
              }
              final videos = youtube.trendingVideos.take(8).toList();
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: videos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) => _trendCard(context, video: videos[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 25),
        Row(children: [
          Expanded(child: Text('Videos musicales de YouTube', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
          Icon(Icons.music_note_rounded, color: Theme.of(context).colorScheme.secondary),
        ]),
        const SizedBox(height: 12),
        const YouTubeApiView(),
      ],
    ),
  );
  Widget _trendCard(BuildContext context, {required YouTubeVideo video}) => SizedBox(
    width: 158,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openYouTubeDetails(video, autoPlay: true),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              video.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainer,
              ),
            ),
            const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xDD100A19)]))),
            Center(
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
            Positioned(left: 11, right: 11, bottom: 11, child: Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13))),
          ],
        ),
      ),
    ),
  );
}
