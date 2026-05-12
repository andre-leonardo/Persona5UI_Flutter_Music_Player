// lib/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:phantom_tunes/utilis/app_state.dart';
import 'package:phantom_tunes/utilis/favorites_manager.dart';
import 'package:phantom_tunes/screen_customization.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: favoriteSongIds,
      builder: (context, favoriteIds, _) {
        return ValueListenableBuilder<List<SongModel>>(
          valueListenable: allSongs,
          builder: (context, songs, _) {
            final favSongs = songs.where((s) => favoriteIds.contains(s.id)).toList();

            if (favSongs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_border, color: Colors.white24, size: 80),
                    const SizedBox(height: 16),
                    const Text(
                      "No favorites yet",
                      style: TextStyle(
                        fontFamily: 'Persona',
                        color: Colors.white54,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tap the ♥ on any song to add it here",
                      style: TextStyle(
                        fontFamily: 'Arsenal',
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: currentPlayingSong.value != null ? 64 : 0,
              ),
              child: ListView.builder(
                itemCount: favSongs.length,
                itemBuilder: (context, index) {
                  final song = favSongs[index];
                  // Find the real index in allSongs for playback
                  final realIndex = songs.indexOf(song);

                  return CustomPaint(
                    painter: BackgroundPainter(strokeColor: Colors.white, context: context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 0.012 * MediaQuery.of(context).size.height,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                        leading: Persona5SlantedArtwork(
                          songId: song.id,
                          size: 50,
                          fallbackImagePath: "assets/images/persona.png",
                        ),
                        title: Text(
                          song.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Arsenal',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        subtitle: Text(
                          song.artist ?? "<Unknown>",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontFamily: 'Arsenal',
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        trailing: GestureDetector(
                          onTap: () => FavoritesManager().toggleFavorite(song.id),
                          child: const Icon(
                            Icons.favorite,
                            color: Color(0xFFFF0505),
                            size: 22,
                          ),
                        ),
                        onTap: () async {
                          if (realIndex >= 0) {
                            await audioHandler.playSongAt(realIndex);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
