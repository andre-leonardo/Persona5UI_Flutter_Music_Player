import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:phantom_tunes/home_screen.dart';
import 'package:phantom_tunes/utilis/app_state.dart';
import 'package:phantom_tunes/screen_customization.dart';
import 'package:rxdart/rxdart.dart'; // For custom painters

// A utility class to hold position data for the progress bar
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

class _SongScreenState extends State<SongScreen> {
  // Stream to combine player state for the progress bar
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          player.positionStream,
          player.bufferedPositionStream,
          player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  void initState() {
    super.initState();
    // No need to listen to currentIndexStream here if currentPlayingSong is already updated globally
    // We listen to currentPlayingSong directly.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Assuming a background gradient/image
      body: Stack(
        children: [
          // Background (Optional: can be a global background in main.dart)
          // For now, let's keep it simple or use a container with a color
          Container(
            color: Colors.black, // Dark background for Persona 5 feel
          ),

          // Main content
          ValueListenableBuilder<SongModel?>(
            valueListenable: currentPlayingSong,
            builder: (context, song, child) {
              if (song == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/persona_logo.png", height: 100),
                      const SizedBox(height: 20),
                      const Text(
                        "No song playing...",
                        style: TextStyle(
                          fontFamily: 'Arsenal',
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffff0505),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0), // Sharp corners
                            side: const BorderSide(color: Colors.white, width: 2), // White border
                          ),
                        ),
                        onPressed: () {
                          isPlayerVisible.value = false; // Go back to song list
                        },
                        child: const Text(
                          "BACK TO SONGS",
                          style: TextStyle(
                            fontFamily: 'Persona',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Persona 5 style layout
              return Column(
                children: [
                  // Top Section: Back button and Title/Artist
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back Button (Persona 5 style)
                        GestureDetector(
                          onTap: () {
                            isPlayerVisible.value = false; // Hide the player, go back to HomeScreen
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xffff0505), // Red background
                              border: Border.all(color: Colors.white, width: 2), // White border
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 30),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Song Title
                              Transform.rotate( // Slight rotation for Persona style
                                angle: -0.05, // Adjust angle as needed
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  song.title,
                                  style: const TextStyle(
                                    fontFamily: 'Persona',
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              const SizedBox(height: 5),
                              // Artist Name
                              Transform.rotate( // Slight rotation
                                angle: -0.05,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  song.artist ?? "<Unknown>",
                                  style: const TextStyle(
                                    fontFamily: 'Arsenal',
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(), // Pushes content to the center/bottom

                  // Album Artwork (Central piece)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      color: Colors.grey[900], // Placeholder color
                      border: Border.all(color: const Color(0xffff0505), width: 3), // Red border
                    ),
                    // This is where you can apply your custom painter for the slanted border
                    child: Persona5SlantedArtwork(
                    songId: song.id,
                    size: MediaQuery.of(context).size.width * 0.7, // Set desired size
                    fallbackImagePath: "assets/images/persona_logo.png",
                  ),
                  ),
                  const Spacer(),

                  // Progress Bar
                  StreamBuilder<PositionData>(
                    stream: _positionDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                        child: ProgressBar(
                          progress: positionData?.position ?? Duration.zero,
                          buffered: positionData?.bufferedPosition ?? Duration.zero,
                          total: positionData?.duration ?? Duration.zero,
                          onSeek: player.seek,
                          barCapShape: BarCapShape.round,
                          baseBarColor: Colors.grey.shade800,
                          progressBarColor: const Color(0xffff0505), // Persona 5 red
                          bufferedBarColor: Colors.grey.shade700,
                          thumbColor: Colors.white,
                          thumbRadius: 8.0,
                          barHeight: 5.0,
                          timeLabelTextStyle: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Arsenal',
                            fontSize: 12,
                          ),
                          // Optional: custom labels for Persona 5 style
                          timeLabelLocation: TimeLabelLocation.sides,
                        ),
                      );
                    },
                  ),

                  // Playback Controls
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Previous button
                        _buildControlIconButton("assets/icons/previous.png", () async {
                          if (player.hasPrevious) {
                            await player.seekToPrevious();
                          } else {
                            showCustomToast(context, "No previous song");
                          }
                        }),
                        // Play/Pause button
                        ValueListenableBuilder<bool>(
                          valueListenable: audioPlayerManager.isPlaying,
                          builder: (context, isPlaying, child) {
                            return _buildControlIconButton(
                              isPlaying ? "assets/icons/pause.png" : "assets/icons/play.png",
                              () async {
                                if (isPlaying) {
                                  await audioPlayerManager.pause();
                                } else {
                                  await audioPlayerManager.resume();
                                }
                              },
                              size: 70.0, // Larger size for play/pause
                            );
                          },
                        ),
                        // Next button
                        _buildControlIconButton("assets/icons/next.png", () async {
                          if (player.hasNext) {
                            await player.seekToNext();
                          } else {
                            showCustomToast(context, "No next song");
                          }
                        }),
                      ],
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

  // Helper to build control buttons with Persona 5 style
  Widget _buildControlIconButton(String assetPath, VoidCallback onPressed, {double size = 50.0}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black, // Background color
          border: Border.all(color: const Color(0xffff0505), width: 3), // Red border
          // Could add more complex shapes/shadows here with CustomPainter if desired
        ),
        child: Center(
          child: Image.asset(assetPath, height: size * 0.6, color: Colors.white), // Icon
        ),
      ),
    );
  }

  // This Path is for clipping the album art to a slanted rectangle
  // Path _getAlbumArtPath(double size) {
  //   Path path = Path();
  //   // These coordinates define a slightly slanted rectangle relative to the given size
  //   path.moveTo(size * 0.05, 0); // Start slightly in from top-left
  //   path.lineTo(0, size * 0.95); // Bottom-left corner, slightly skewed down
  //   path.lineTo(size * 0.95, size); // Bottom-right corner
  //   path.lineTo(size, size * 0.05); // Top-right corner, slightly skewed up
  //   path.close();
  //   return path;
  // }
}

// You need to update ShapeClipper in screen_customization.dart if not already done
// It should look like this:
/*
class ShapeClipper extends CustomClipper<Path> {
  final Path path;

  ShapeClipper({required this.path});

  @override
  Path getClip(Size size) {
    // The path here is already pre-calculated based on the desired shape.
    // We just return it. The size parameter in getClip is the size of the widget being clipped.
    // If your path creation depends on the widget's final render size,
    // you'd recalculate it here based on `size`.
    // For our specific use, the path is generated in _getAlbumArtPath with the target size.
    return path;
  }

  @override
  bool shouldReclip(ShapeClipper oldClipper) => oldClipper.path != path;
}
*/