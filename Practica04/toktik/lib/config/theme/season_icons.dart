import '../../domain/entities/app_icon.dart';
import '../../domain/entities/season.dart';

class SeasonIcons {
  static String assetFor(Season season) => switch (appIconForSeason(season)) {
    AppIcon.normal => 'assets/icons/Kittytoktik.png',
    AppIcon.halloween => 'assets/icons/Hallowen.png',
    AppIcon.christmas => 'assets/icons/Navidad.png',
    AppIcon.valentines => 'assets/icons/Sanvalentin.png',
  };
}
