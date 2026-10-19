import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../config/helpers/human_formats.dart';
import '../../../domain/entities/youtube_video.dart';
import '../../widgets/video/youtube_inline_player.dart';

class YouTubeVideoDetailsScreen extends StatefulWidget {
  final YouTubeVideo video;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final bool autoPlay;

  const YouTubeVideoDetailsScreen({
    super.key,
    required this.video,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.autoPlay = false,
  });

  @override
  State<YouTubeVideoDetailsScreen> createState() => _YouTubeVideoDetailsScreenState();
}

class _YouTubeVideoDetailsScreenState extends State<YouTubeVideoDetailsScreen> {
  late bool _isFavorite = widget.isFavorite;
  late bool _playing = widget.autoPlay;

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF100A19);
    const panel = Color(0xFF20152D);
    const accent = Color(0xFFFF6B35);
    final video = widget.video;
    final title = video.title;
    final artist = video.channel;
    final published = DateTime.tryParse(video.publishedAt);
    final publishedLabel = published == null
        ? 'No disponible'
        : '${published.day.toString().padLeft(2, '0')}/${published.month.toString().padLeft(2, '0')}/${published.year}';
    final tags = <String>{
      '#${artist.replaceAll(RegExp(r'[^A-Za-z0-9]'), '')}',
      '#VideoMusical',
      '#Musica',
    };

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        leading: IconButton(
          tooltip: 'Regresar',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: _isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
              widget.onFavoriteToggle?.call();
            },
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? const Color(0xFFFF4F9A) : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _playing
                  ? YouTubeInlinePlayer(videoId: video.id, aspectRatio: 16 / 9)
                  : InkWell(
                      onTap: () => setState(() => _playing = true),
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: [
                          Image.network(video.thumbnailUrl, fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const ColoredBox(color: panel, child: Icon(Icons.music_video_rounded, size: 50))),
                          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0x88000000)]))),
                          const Center(child: CircleAvatar(radius: 31, backgroundColor: Color(0xDDFF6B35), child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 42))),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 18),
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              _Metric(icon: Icons.visibility_outlined, label: video.views > 0 ? '${HumanFormats.humanReadbleNumber(video.views.toDouble())} vistas' : 'Vistas no disponibles'),
              _Metric(icon: Icons.favorite_border_rounded, label: video.likes == null ? 'Likes no disponibles' : '${HumanFormats.humanReadbleNumber(video.likes!.toDouble())} likes'),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Color(0xFF483753), height: 1),
          ),
          _SectionTitle(title: 'Información básica'),
          const SizedBox(height: 12),
          _InfoRow(label: 'Artista', value: artist),
          _InfoRow(label: 'Canción', value: title),
          _InfoRow(label: 'Fecha de publicación', value: publishedLabel),
          const _InfoRow(label: 'Álbum', value: 'No disponible en los datos de YouTube'),
          if (video.description.trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            const _SectionTitle(title: 'Descripción'),
            const SizedBox(height: 8),
            Text(video.description, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Etiquetas'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => Chip(
              label: Text(tag),
              backgroundColor: panel,
              side: const BorderSide(color: Color(0xFF483753)),
              labelStyle: const TextStyle(color: Color(0xFFFF9A70), fontWeight: FontWeight.w700),
            )).toList(),
          ),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Sigue al artista'),
          const SizedBox(height: 10),
          Card(
            color: panel,
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFF392044), child: Icon(Icons.person_rounded, color: accent)),
              title: Text(artist, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Canal de YouTube. No se proporcionaron otros enlaces.'),
              trailing: video.channelId.isEmpty
                  ? null
                  : const Icon(Icons.open_in_new_rounded, size: 18),
              onTap: video.channelId.isEmpty
                  ? null
                  : () => launchUrl(Uri.parse('https://www.youtube.com/channel/${video.channelId}')),
            ),
          ),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Letra de la canción'),
          const SizedBox(height: 10),
          const Card(
            color: panel,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('La letra no está disponible para este video.'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Metric({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18, color: const Color(0xFFFF6B35)),
      const SizedBox(width: 6),
      Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900));
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 145, child: Text(label, style: const TextStyle(color: Color(0xFFBEB2C8)))),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700))),
      ],
    ),
  );
}
