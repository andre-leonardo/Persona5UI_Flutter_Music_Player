// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:phantom_tunes/playlist_screen.dart';
import 'package:phantom_tunes/favorites_screen.dart';
import 'package:phantom_tunes/utilis/appbar.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:phantom_tunes/screen_customization.dart';
import 'package:phantom_tunes/song_screen.dart';
import 'package:phantom_tunes/utilis/app_state.dart';
import 'package:phantom_tunes/utilis/favorites_manager.dart';
import 'package:phantom_tunes/utilis/toast_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _hasPermission = false;
  Future<List<SongModel>>? _songsFuture;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
    isPlayerVisible.addListener(_rebuild);
  }

  @override
  void dispose() {
    isPlayerVisible.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0: currentAppScreen.value = AppScreen.songs; break;
        case 1: currentAppScreen.value = AppScreen.playlists; break;
        case 2: currentAppScreen.value = AppScreen.favorites; break;
      }
    });
  }

  Future<void> _checkAndRequestPermission() async {
    if (!kIsWeb) {
      try {
        bool status = await audioQuery.permissionsStatus();
        if (!status) status = await audioQuery.permissionsRequest();
        if (mounted) {
          setState(() {
            _hasPermission = status;
            if (status) {
              _songsFuture = audioQuery.querySongs(
                sortType: null,
                orderType: OrderType.ASC_OR_SMALLER,
                uriType: UriType.EXTERNAL,
                ignoreCase: true,
              );
            }
          });
          if (!status) showCustomToast(context, "Storage permission denied.");
        }
      } catch (e) {
        debugPrint("Permission error: $e");
        if (mounted) {
          setState(() {
            _hasPermission = true;
            _songsFuture = audioQuery.querySongs(
              sortType: null,
              orderType: OrderType.ASC_OR_SMALLER,
              uriType: UriType.EXTERNAL,
              ignoreCase: true,
            );
          });
        }
      }
    } else {
      setState(() {
        _hasPermission = true;
        _songsFuture = audioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isPlayerVisible,
      builder: (context, playerIsVisible, _) {
        return Stack(
          children: [
            // Home screen (kept in the tree to preserve scroll state)
            Offstage(
              offstage: playerIsVisible,
              child: Scaffold(
                backgroundColor: Colors.black,
                appBar: const CustomAppBar(),
                bottomNavigationBar: _buildBottomNav(),
                body: Stack(
                  children: [
                    // Main screen content
                    ValueListenableBuilder<AppScreen>(
                      valueListenable: currentAppScreen,
                      builder: (context, screen, _) {
                        return IndexedStack(
                          index: screen.index,
                          children: [
                            _buildSongsList(),
                            const PlaylistScreen(),
                            const FavoritesScreen(),
                          ],
                        );
                      },
                    ),
                    // Mini-player at the bottom
                    _buildMiniPlayer(),
                  ],
                ),
              ),
            ),
            // Song screen (only built when visible)
            if (playerIsVisible) const SongScreen(),
          ],
        );
      },
    );
  }

  // ─── Bottom Navigation ───
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFFF0505),
      unselectedItemColor: Colors.white70,
      selectedItemColor: Colors.white,
      selectedLabelStyle: const TextStyle(fontFamily: 'Persona', fontSize: 10),
      unselectedLabelStyle: const TextStyle(fontFamily: 'Persona', fontSize: 10),
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset("assets/icons/home.png", height: 40, color: Colors.white70),
          activeIcon: Image.asset("assets/icons/home.png", height: 45, color: Colors.white),
          label: "Songs",
        ),
        BottomNavigationBarItem(
          icon: Image.asset("assets/icons/playlists.png", height: 40, color: Colors.white70),
          activeIcon: Image.asset("assets/icons/playlists.png", height: 45, color: Colors.white),
          label: "Playlists",
        ),
        BottomNavigationBarItem(
          icon: Image.asset("assets/icons/favorite.png", height: 40, color: Colors.white70),
          activeIcon: Image.asset("assets/icons/favorite.png", height: 45, color: Colors.white),
          label: "Favorites",
        ),
      ],
    );
  }

  // ─── Mini-player (shown when a song is playing) ───
  Widget _buildMiniPlayer() {
    return ValueListenableBuilder<SongModel?>(
      valueListenable: currentPlayingSong,
      builder: (context, song, _) {
        if (song == null) return const SizedBox.shrink();

        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () => isPlayerVisible.value = true,
            child: Container(
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                border: Border(
                  top: BorderSide(color: Color(0xFFFF0505), width: 2),
                ),
              ),
              child: Row(
                children: [
                  // Album art
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Color(0xFFFF0505), width: 1),
                      ),
                    ),
                    child: QueryArtworkWidget(
                      id: song.id,
                      type: ArtworkType.AUDIO,
                      artworkBorder: BorderRadius.zero,
                      nullArtworkWidget: Image.asset(
                        "assets/images/persona.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Song info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: const TextStyle(
                            fontFamily: 'Arsenal',
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          song.artist ?? "<Unknown>",
                          style: const TextStyle(
                            fontFamily: 'Arsenal',
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  // Play/Pause button
                  ValueListenableBuilder<bool>(
                    valueListenable: audioHandler.isPlayingNotifier,
                    builder: (context, isPlaying, _) {
                      return IconButton(
                        onPressed: () {
                          if (isPlaying) {
                            audioHandler.pause();
                          } else {
                            audioHandler.play();
                          }
                        },
                        icon: Image.asset(
                          isPlaying ? "assets/icons/pause.png" : "assets/icons/play.png",
                          height: 28,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Songs list ───
  Widget _buildSongsList() {
    if (!_hasPermission) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFFF0505)),
            SizedBox(height: 16),
            Text(
              "Requesting permissions...",
              style: TextStyle(color: Colors.white, fontFamily: 'Arsenal'),
            ),
          ],
        ),
      );
    }

    if (_songsFuture == null) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF0505)));
    }

    return FutureBuilder<List<SongModel>>(
      future: _songsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF0505)),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No Songs Found",
              style: TextStyle(
                color: Colors.white54,
                fontFamily: 'Arsenal',
                fontSize: 18,
              ),
            ),
          );
        }

        // Filter and sort songs
        final songs = snapshot.data!
            .where((s) => s.duration != null && s.duration! > 0)
            .toList()
          ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

        // Update global song list (player loads lazily on first tap)
        if (allSongs.value.length != songs.length) {
          allSongs.value = songs;
        }

        return Padding(
          // Add bottom padding for mini-player
          padding: EdgeInsets.only(
            bottom: currentPlayingSong.value != null ? 64 : 0,
          ),
          child: ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) => _buildSongTile(songs[index], index),
          ),
        );
      },
    );
  }

  // ─── Individual song tile ───
  Widget _buildSongTile(SongModel song, int index) {
    return CustomPaint(
      painter: BackgroundPainter(strokeColor: Colors.white, context: context),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 0.012 * MediaQuery.of(context).size.height,
        ),
        child: ListTile(
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Favorite button
              ValueListenableBuilder<Set<int>>(
                valueListenable: favoriteSongIds,
                builder: (context, favorites, _) {
                  final isFav = favorites.contains(song.id);
                  return GestureDetector(
                    onTap: () => FavoritesManager().toggleFavorite(song.id),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? const Color(0xFFFF0505) : Colors.white54,
                      size: 22,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              // More options
              GestureDetector(
                onTap: () => _showSongOptions(context, song),
                child: Image.asset("assets/icons/more.png", height: 24, color: Colors.white54),
              ),
            ],
          ),
          leading: SizedBox(
            width: 50,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFF0505), width: 1.5),
              ),
              child: QueryArtworkWidget(
                artworkBorder: BorderRadius.zero,
                id: song.id,
                type: ArtworkType.AUDIO,
                nullArtworkWidget: Image.asset(
                  "assets/images/persona.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          onTap: () async {
            await audioHandler.playSongAt(index);
          },
        ),
      ),
    );
  }

  // ─── Song options bottom sheet ───
  void _showSongOptions(BuildContext context, SongModel song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color(0xFFFF0505), width: 2),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    song.title,
                    style: const TextStyle(
                      fontFamily: 'Persona',
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const Divider(color: Color(0xFFFF0505), height: 1),
                // Add to playlist
                ListTile(
                  leading: const Icon(Icons.playlist_add, color: Color(0xFFFF0505)),
                  title: const Text(
                    "Add to playlist",
                    style: TextStyle(fontFamily: 'Arsenal', color: Colors.white, fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showPlaylistPicker(song);
                  },
                ),
                // Toggle favorite
                ValueListenableBuilder<Set<int>>(
                  valueListenable: favoriteSongIds,
                  builder: (context, favorites, _) {
                    final isFav = favorites.contains(song.id);
                    return ListTile(
                      leading: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: const Color(0xFFFF0505),
                      ),
                      title: Text(
                        isFav ? "Remove from favorites" : "Add to favorites",
                        style: const TextStyle(
                          fontFamily: 'Arsenal',
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        FavoritesManager().toggleFavorite(song.id);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPlaylistPicker(SongModel song) async {
    try {
      final playlists = await audioQuery.queryPlaylists(
        sortType: PlaylistSortType.DATE_ADDED,
        orderType: OrderType.DESC_OR_GREATER,
      );
      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFFFF0505), width: 2),
        ),
        builder: (ctx) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "CHOOSE PLAYLIST",
                    style: TextStyle(fontFamily: 'Persona', color: Colors.white, fontSize: 18),
                  ),
                ),
                const Divider(color: Color(0xFFFF0505), height: 1),
                ListTile(
                  leading: const Icon(Icons.add, color: Color(0xFFFF0505)),
                  title: const Text(
                    "Create new playlist",
                    style: TextStyle(
                      fontFamily: 'Arsenal', color: Colors.white, fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final name = await _showCreatePlaylistDialog();
                    if (name != null && name.trim().isNotEmpty) {
                      final created = await audioQuery.createPlaylist(name.trim());
                      if (created) {
                        final updated = await audioQuery.queryPlaylists(
                          sortType: PlaylistSortType.DATE_ADDED,
                          orderType: OrderType.DESC_OR_GREATER,
                        );
                        if (updated.isNotEmpty) {
                          await audioQuery.addToPlaylist(updated.first.id, song.id);
                          Fluttertoast.showToast(
                            msg: "\"${song.title}\" added to \"$name\"!",
                            backgroundColor: const Color(0xFFFF0505),
                            textColor: Colors.white,
                          );
                        }
                      }
                    }
                  },
                ),
                if (playlists.isNotEmpty)
                  ...playlists.map((playlist) => ListTile(
                    leading: const Icon(Icons.queue_music, color: Colors.white54),
                    title: Text(
                      playlist.playlist,
                      style: const TextStyle(fontFamily: 'Arsenal', color: Colors.white, fontSize: 16),
                    ),
                    subtitle: Text(
                      "${playlist.numOfSongs} song${playlist.numOfSongs == 1 ? '' : 's'}",
                      style: const TextStyle(fontFamily: 'Arsenal', color: Colors.white38, fontSize: 13),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final success = await audioQuery.addToPlaylist(playlist.id, song.id);
                      Fluttertoast.showToast(
                        msg: success
                            ? "\"${song.title}\" added to \"${playlist.playlist}\"!"
                            : "Failed to add song",
                        backgroundColor: success ? const Color(0xFFFF0505) : Colors.grey,
                        textColor: Colors.white,
                      );
                    },
                  )),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("Error loading playlists: $e");
    }
  }

  Future<String?> _showCreatePlaylistDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFFFF0505), width: 2),
          borderRadius: BorderRadius.zero,
        ),
        title: const Text(
          "NEW PLAYLIST",
          style: TextStyle(fontFamily: 'Persona', color: Colors.white, fontSize: 22),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(fontFamily: 'Arsenal', color: Colors.white, fontSize: 16),
          cursorColor: const Color(0xFFFF0505),
          decoration: const InputDecoration(
            hintText: "Playlist name",
            hintStyle: TextStyle(color: Colors.white38, fontFamily: 'Arsenal'),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFF0505), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "CANCEL",
              style: TextStyle(fontFamily: 'Persona', color: Colors.white54, fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFF0505),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text(
              "CREATE",
              style: TextStyle(fontFamily: 'Persona', color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}