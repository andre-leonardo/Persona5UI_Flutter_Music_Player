// lib/song_screen.dart
import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:phantom_tunes/utilis/app_state.dart';
import 'package:phantom_tunes/utilis/favorites_manager.dart';
import 'package:phantom_tunes/utilis/toast_helper.dart';
import 'package:phantom_tunes/screen_customization.dart';
import 'package:rxdart/rxdart.dart';

class PositionData {
  const PositionData(this.position, this.bufferedPosition, this.duration);
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
}

class SongScreen extends StatefulWidget {
  const SongScreen({super.key});
  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> with SingleTickerProviderStateMixin {
  late AnimationController _artworkAnimController;
  late Animation<double> _artworkFade;
  int? _lastSongId;

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        audioHandler.player.positionStream,
        audioHandler.player.bufferedPositionStream,
        audioHandler.player.durationStream,
        (position, buffered, duration) =>
            PositionData(position, buffered, duration ?? Duration.zero),
      );

  @override
  void initState() {
    super.initState();
    _artworkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _artworkFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _artworkAnimController, curve: Curves.easeOut),
    );
    _artworkAnimController.forward();

    // Listen for song changes to replay the artwork fade
    currentPlayingSong.addListener(_onSongChanged);
  }

  void _onSongChanged() {
    final song = currentPlayingSong.value;
    if (song != null && song.id != _lastSongId) {
      _lastSongId = song.id;
      _artworkAnimController.reset();
      _artworkAnimController.forward();
    }
  }

  @override
  void dispose() {
    currentPlayingSong.removeListener(_onSongChanged);
    _artworkAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: ValueListenableBuilder<SongModel?>(
        valueListenable: currentPlayingSong,
        builder: (context, song, _) {
          if (song == null) {
            return _buildNoSongState();
          }
          return SafeArea(
            child: Column(
              children: [
                // ─── Top bar: back + song info ───
                _buildTopBar(song, screenWidth),

                const Spacer(flex: 1),

                // ─── Album artwork ───
                _buildArtwork(song, screenWidth),

                const Spacer(flex: 1),

                // ─── Song title + artist (below artwork) ───
                _buildSongInfo(song),

                const SizedBox(height: 20),

                // ─── Progress bar ───
                _buildProgressBar(),

                const SizedBox(height: 8),

                // ─── Playback controls ───
                _buildControls(screenHeight),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoSongState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/persona.png", height: 100),
          const SizedBox(height: 20),
          const Text(
            "No song playing...",
            style: TextStyle(fontFamily: 'Arsenal', color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 20),
          _buildPersonaButton("BACK TO SONGS", () {
            isPlayerVisible.value = false;
          }),
        ],
      ),
    );
  }

  // ─── Top bar ───
  Widget _buildTopBar(SongModel song, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // Back button — Persona 5 style
          GestureDetector(
            onTap: () => isPlayerVisible.value = false,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFF0505),
                border: Border.all(color: Colors.white, width: 2),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 24),
            ),
          ),
          const Spacer(),
          // Favorite button
          ValueListenableBuilder<Set<int>>(
            valueListenable: favoriteSongIds,
            builder: (context, favorites, _) {
              final isFav = favorites.contains(song.id);
              return GestureDetector(
                onTap: () => FavoritesManager().toggleFavorite(song.id),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: isFav ? const Color(0xFFFF0505) : Colors.white54,
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? const Color(0xFFFF0505) : Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── Artwork ───
  Widget _buildArtwork(SongModel song, double screenWidth) {
    final artSize = screenWidth * 0.72;
    return FadeTransition(
      opacity: _artworkFade,
      child: Persona5SlantedArtwork(
        songId: song.id,
        size: artSize,
        fallbackImagePath: "assets/images/persona.png",
      ),
    );
  }

  // ─── Song info ───
  Widget _buildSongInfo(SongModel song) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Title with slight Persona 5 rotation
          Transform.rotate(
            angle: -0.03,
            alignment: Alignment.centerLeft,
            child: Text(
              song.title,
              style: const TextStyle(
                fontFamily: 'Persona',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            song.artist ?? "<Unknown>",
            style: const TextStyle(
              fontFamily: 'Arsenal',
              fontSize: 16,
              color: Colors.white70,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Progress bar ───
  Widget _buildProgressBar() {
    return StreamBuilder<PositionData>(
      stream: _positionDataStream,
      builder: (context, snapshot) {
        final data = snapshot.data;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ProgressBar(
            progress: data?.position ?? Duration.zero,
            buffered: data?.bufferedPosition ?? Duration.zero,
            total: data?.duration ?? Duration.zero,
            onSeek: audioHandler.seek,
            barCapShape: BarCapShape.round,
            baseBarColor: Colors.grey.shade800,
            progressBarColor: const Color(0xFFFF0505),
            bufferedBarColor: Colors.grey.shade700,
            thumbColor: Colors.white,
            thumbRadius: 8,
            barHeight: 5,
            timeLabelTextStyle: const TextStyle(
              color: Colors.white,
              fontFamily: 'Arsenal',
              fontSize: 12,
            ),
            timeLabelLocation: TimeLabelLocation.sides,
          ),
        );
      },
    );
  }

  // ─── Controls ───
  Widget _buildControls(double screenHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle
          ValueListenableBuilder<bool>(
            valueListenable: audioHandler.shuffleNotifier,
            builder: (context, shuffleOn, _) {
              return _buildSmallControl(
                shuffleOn ? "assets/icons/shuffletrue.png" : "assets/icons/shufflefalse.png",
                () => audioHandler.toggleShuffle(),
                active: shuffleOn,
              );
            },
          ),
          // Previous
          _buildControlButton("assets/icons/previous.png", () async {
            if (audioHandler.player.hasPrevious) {
              await audioHandler.skipToPrevious();
            } else {
              if (mounted) showCustomToast(context, "No previous song");
            }
          }),
          // Play/Pause — larger
          ValueListenableBuilder<bool>(
            valueListenable: audioHandler.isPlayingNotifier,
            builder: (context, isPlaying, _) {
              return _buildControlButton(
                isPlaying ? "assets/icons/pause.png" : "assets/icons/play.png",
                () => isPlaying ? audioHandler.pause() : audioHandler.play(),
                size: 72,
              );
            },
          ),
          // Next
          _buildControlButton("assets/icons/next.png", () async {
            if (audioHandler.player.hasNext) {
              await audioHandler.skipToNext();
            } else {
              if (mounted) showCustomToast(context, "No next song");
            }
          }),
          // Loop
          ValueListenableBuilder<LoopMode>(
            valueListenable: audioHandler.loopModeNotifier,
            builder: (context, loopMode, _) {
              String iconPath;
              bool active;
              switch (loopMode) {
                case LoopMode.off:
                  iconPath = "assets/icons/loop.png";
                  active = false;
                  break;
                case LoopMode.all:
                  iconPath = "assets/icons/loop1.png";
                  active = true;
                  break;
                case LoopMode.one:
                  iconPath = "assets/icons/loop1.png";
                  active = true;
                  break;
              }
              return Stack(
                alignment: Alignment.center,
                children: [
                  _buildSmallControl(
                    iconPath,
                    () => audioHandler.cycleLoopMode(),
                    active: active,
                  ),
                  if (loopMode == LoopMode.one)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF0505),
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          "1",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── Control button (Persona 5 style) ───
  Widget _buildControlButton(String assetPath, VoidCallback onTap, {double size = 52}) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _SlantedButtonPainter(
          bgColor: Colors.black,
          borderColor: const Color(0xFFFF0505),
          borderWidth: 2.5,
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Image.asset(assetPath, height: size * 0.5, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // ─── Small control (shuffle/loop) ───
  Widget _buildSmallControl(String assetPath, VoidCallback onTap, {bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _SlantedButtonPainter(
          bgColor: active ? const Color(0xFFFF0505).withValues(alpha: 0.2) : Colors.transparent,
          borderColor: active ? const Color(0xFFFF0505) : Colors.white38,
          borderWidth: 1.5,
        ),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Image.asset(
              assetPath,
              height: 18,
              color: active ? const Color(0xFFFF0505) : Colors.white54,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Persona-styled button ───
  Widget _buildPersonaButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _SlantedButtonPainter(
          bgColor: const Color(0xFFFF0505),
          borderColor: Colors.white,
          borderWidth: 2.0,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Persona',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _SlantedButtonPainter extends CustomPainter {
  final Color bgColor;
  final Color borderColor;
  final double borderWidth;

  _SlantedButtonPainter({
    required this.bgColor,
    required this.borderColor,
    this.borderWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dx = size.height * 0.15;
    final dy = size.height * 0.05;
    
    final path = Path();
    path.moveTo(dx, dy); 
    path.lineTo(0, size.height); 
    path.lineTo(size.width - dx, size.height - dy); 
    path.lineTo(size.width, 0); 
    path.close();

    if (bgColor != Colors.transparent) {
      canvas.drawPath(
        path,
        Paint()
          ..color = bgColor
          ..style = PaintingStyle.fill,
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
  }

  @override
  bool shouldRepaint(_SlantedButtonPainter oldDelegate) {
    return oldDelegate.bgColor != bgColor || 
           oldDelegate.borderColor != borderColor ||
           oldDelegate.borderWidth != borderWidth;
  }
}