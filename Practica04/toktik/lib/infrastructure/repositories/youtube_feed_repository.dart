import '../../domain/repositories/feed_repository.dart';
import '../datasources/youtube_video_datasource.dart';

class YouTubeFeedRepository implements FeedRepository {
  final YouTubeVideoDatasource datasource;
  String? _term;
  String? _categoryId;

  YouTubeFeedRepository(this.datasource);

  void search({String? term, String? categoryId}) {
    _term = term?.trim().isEmpty == true ? null : term?.trim();
    _categoryId = categoryId?.trim().isEmpty == true
        ? null
        : categoryId?.trim();
  }

  void showTrending() {
    _term = null;
    _categoryId = null;
  }

  @override
  Future<FeedPage> load(int page) async {
    if (page != 1) return const FeedPage([], []);
    final videos = _term == null && _categoryId == null
        ? await datasource.getTrendingVideos()
        : await datasource.searchVideos(term: _term, categoryId: _categoryId);
    return FeedPage(datasource.toVideoPosts(videos), []);
  }
}
