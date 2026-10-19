import '../entities/season.dart';

/// El sonido de temporada es independiente del volumen de los videos.
class SeasonalAudioPolicy {
  Season? _lastSeason;

  bool shouldPlay(Season season, {required bool enabled}) {
    final changed = _lastSeason != season;
    _lastSeason = season;
    return changed && enabled;
  }
}
