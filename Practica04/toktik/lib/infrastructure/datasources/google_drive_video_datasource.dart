import '../../domain/datasources/video_posts_datasource.dart';
import '../../domain/entities/video_post.dart';

/// Videos propios alojados en Drive. Cada archivo debe permitir acceso
/// a cualquier persona que tenga el enlace.
class GoogleDriveVideoDatasource implements VideoPostDatasource {
  static const _fileIds = [
    '1mTlxV43x4hoBtCwy06MN7CXvPHBaQW7I',
    '1NnKC5J_ZhTLw3-xnhR7ErFWg69SS086u',
    '1ED9P98DZJ1c4nETFuhRV8P9MFIKcUfwl',
    '1ggCuCsbpbft3bkSDWLCCq5vjZS3AeerQ',
    '1rxAzYe9TavDfgpBEl2ZdRwDmohfhOYs5',
    '1pVV7DGkiOTIbmGkZyBqeGOZzLMsr4Qbv',
    '1rQ_b0XRGU_ElswXGYBSKqZ3Jg1v1AeMR',
  ];

  static const _captions = [
    'Día de Muertos en la CDMX 💀🌼',
    'Tecnologías de la Información en la UTXJ 💻',
    'Un momento de piano 🎹',
    'Tutorial de maquillaje 💄',
    'Memes de programación 😂💻',
    'Bridgerton, la serie que amamos 👑',
    'Mi Huauchinango querido 🌿',
  ];

  static const _descriptions = [
    'La CDMX se llena de color para celebrar a quienes siempre viven en nuestros recuerdos. 🕯️🌼 #DíaDeMuertos #CDMX #Tradiciones #ParaTi',
    'Así se vive el mundo de las Tecnologías de la Información en la UTXJ. 💻✨ #UTXJ #TecnologíasDeLaInformación #Estudiantes #VidaUniversitaria',
    'Una melodía de piano para hacer una pausa y disfrutar el momento. 🎹🤍 #Piano #Música #Relax #ParaTi',
    'Un look paso a paso para darle un toque especial a tu día. 💄✨ #TutorialDeMaquillaje #Makeup #Belleza #ParaTi',
    'Cuando el código funciona a la primera… sabemos que es sospechoso. 😂💻 #Programación #MemesDeProgramación #Humor #Tech',
    'Vestidos, intrigas y romances: por eso siempre volvemos a Bridgerton. 👑✨ #Bridgerton #Series #Netflix #ParaTi',
    'Un pedacito de mi bello Huauchinango. 🌿💚 #Huauchinango #Puebla #PuebloMágico #México',
  ];

  @override
  Future<List<VideoPost>> getFavoriteVideosByUser(String userID) async => [];

  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) async {
    if (page != 1) return [];
    return List.generate(_fileIds.length, (index) {
      final id = _fileIds[index];
      return VideoPost(
        caption: _captions[index],
        videoUrl:
            'https://drive.usercontent.google.com/download?id=$id&export=download',
        source: VideoSource.googleDrive,
        externalId: id,
        description: _descriptions[index],
      );
    });
  }
}
