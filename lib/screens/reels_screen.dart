import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/reel_item.dart';
import '../services/tmdb_service.dart';
import 'player_screen.dart';

final laneProvider = StateProvider<String>((ref) => 'popular');
final reelsProvider = FutureProvider.family<List<ReelItem>, String>((ref, lane) async {
  return TmdbService.fetchLane(lane);
});

class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  final PageController _pageController = PageController();
  final List<String> lanes = ['popular', 'foryou', 'movies', 'shows', 'cartoons', 'anime', 'kdrama'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lane = ref.watch(laneProvider);
    final reelsAsync = ref.watch(reelsProvider(lane));

    return Scaffold(
      backgroundColor: const Color(0xFF07070A),
      body: Stack(
        children: [
          reelsAsync.when(
            data: (reels) => reels.isEmpty
                ? const Center(child: Text('No titles found', style: TextStyle(color: Colors.white70)))
                : PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: reels.length,
                    itemBuilder: (context, index) => ReelPage(item: reels[index]),
                  ),
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFECE8E0))),
            error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.redAccent))),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'BWHS Reels',
                      style: GoogleFonts.instrumentSerif(
                        fontSize: 28,
                        color: const Color(0xFFF3F1EC),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Color(0xFFECE8E0)),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: lanes.map((l) {
                      final active = l == lane;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => ref.read(laneProvider.notifier).state = l,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: active ? const Color(0xFFF3F1EC) : const Color(0xFF1C1C22),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              l[0].toUpperCase() + l.substring(1),
                              style: TextStyle(
                                color: active ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReelPage extends StatefulWidget {
  final ReelItem item;
  const ReelPage({super.key, required this.item});

  @override
  State<ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<ReelPage> {
  YoutubePlayerController? _ytController;
  bool _showTrailer = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.trailerKey != null) {
      _ytController = YoutubePlayerController(
        initialVideoId: widget.item.trailerKey!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: true,
          hideControls: true,
          loop: true,
          disableDragSeek: true,
        ),
      );
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _showTrailer = true);
      });
    }
  }

  @override
  void dispose() {
    _ytController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerScreen(item: item),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: item.backdropUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: const Color(0xFF121216)),
            errorWidget: (_, __, ___) => Container(color: const Color(0xFF121216)),
          ),
          if (_showTrailer && _ytController != null)
            Positioned.fill(
              child: YoutubePlayer(
                controller: _ytController!,
                showVideoProgressIndicator: false,
                aspectRatio: 16 / 9,
              ),
            ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC07070A)],
                stops: [0.4, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 80,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.releaseYear != null)
                  Text(
                    item.releaseYear.toString(),
                    style: const TextStyle(color: Color(0xFFECE8E0), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                  ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  style: GoogleFonts.instrumentSerif(fontSize: 28, color: Colors.white, height: 1.0),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  item.overview,
                  style: const TextStyle(color: Color(0xFF9A9892), fontSize: 13, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFD56A), size: 16),
                    const SizedBox(width: 4),
                    Text(item.voteAverage.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 50,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: item.posterUrl,
                    width: 48,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                const Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
                const SizedBox(height: 4),
                const Text('Watch', style: TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
