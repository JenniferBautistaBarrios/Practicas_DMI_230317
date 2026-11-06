import 'package:cinemapedia/config/constants/movie_country.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_providers.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_slideshow_provider.dart';
import 'package:cinemapedia/presentation/widgets/movies/country_selector.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const name = 'home-screen';
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  final _sections = List.generate(4, (_) => GlobalKey());
  int _selectedIndex = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goTo(int section) {
    setState(
      () => _selectedIndex = section < 0
          ? 0
          : section == 0
          ? 1
          : 2,
    );
    if (section < 0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
      return;
    }
    final target = _sections[section].currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(nowPlayingMoviesProvider);
    ref.invalidate(upcomingMoviesProvider);
    ref.invalidate(popularMoviesProvider);
    ref.invalidate(topRatedMoviesProvider);
    final providers = [
      nowPlayingMoviesProvider,
      upcomingMoviesProvider,
      popularMoviesProvider,
      topRatedMoviesProvider,
    ];
    await Future.wait(
      providers.map((provider) => ref.read(provider.notifier).initialLoad),
    );
  }

  @override
  Widget build(BuildContext context) {
    final country = ref.watch(movieCountryProvider);
    ref.listen(movieCountryProvider, (_, _) {
      setState(() => _selectedIndex = 0);
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });
    final states = [
      ref.watch(nowPlayingMoviesProvider),
      ref.watch(upcomingMoviesProvider),
      ref.watch(popularMoviesProvider),
      ref.watch(topRatedMoviesProvider),
    ];
    final providers = [
      nowPlayingMoviesProvider,
      upcomingMoviesProvider,
      popularMoviesProvider,
      topRatedMoviesProvider,
    ];
    const titles = ['nowPlaying', 'upcoming', 'popular', 'topRated'];

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: country.text('menu'),
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const CustomAppbar(),
        titleSpacing: 0,
        actions: const [CountrySelector()],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/images/logo.png', height: 72),
                    const SizedBox(height: 12),
                    Text(
                      'CINEMAPEDIA',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text('230389 · ${country.flag} ${country.name}'),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_rounded),
                title: Text(country.text('home')),
                onTap: () {
                  Navigator.pop(context);
                  _goTo(-1);
                },
              ),
              for (var index = 0; index < titles.length; index++)
                ListTile(
                  leading: Icon(
                    [
                      Icons.local_movies_rounded,
                      Icons.event_rounded,
                      Icons.trending_up_rounded,
                      Icons.star_rounded,
                    ][index],
                  ),
                  title: Text(country.text(titles[index])),
                  onTap: () {
                    Navigator.pop(context);
                    _goTo(index);
                  },
                ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(country.text('country')),
              ),
              for (final item in MovieCountry.values)
                ListTile(
                  leading: Text(
                    item.flag,
                    style: const TextStyle(fontSize: 25),
                  ),
                  title: Text(item.name),
                  subtitle: Text('${item.continent} · ${item.language}'),
                  selected: country == item,
                  trailing: country == item ? const Icon(Icons.check) : null,
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(movieCountryProvider.notifier).state = item;
                  },
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(country.text('gestures')),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Text(
                      '${country.flag} ${country.name} · ${country.text('nowPlaying')}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (states.first.isLoading && states.first.movies.isEmpty)
                    const SizedBox(height: 260, child: FullScreenLoader()),
                  MoviesSlideshow(
                    key: ValueKey(country),
                    movies: ref.watch(moviesSlideshowProvider),
                  ),
                  for (var index = 0; index < states.length; index++)
                    Column(
                      key: _sections[index],
                      children: [
                        MovieHorizontalListview(
                          key: ValueKey('${country.code}-$index'),
                          movies: states[index].movies,
                          title: country.text(titles[index]),
                          isLoading: states[index].isLoading,
                          error: states[index].error,
                          loadNextPage: () => ref
                              .read(providers[index].notifier)
                              .loadNextPage(),
                        ),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
                    child: Text(country.text('gestures')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        tooltip: country.text('start'),
        onPressed: () => _goTo(-1),
        child: const Icon(Icons.vertical_align_top_rounded),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => _goTo([-1, 0, 2][index]),
      ),
    );
  }
}
