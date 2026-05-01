
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Keep one toast library
import 'package:phantom_tunes/playlist_screen.dart';
import 'package:phantom_tunes/utilis/appbar.dart'; // Assuming this is your custom app bar

import 'package:on_audio_query/on_audio_query.dart';

import 'package:phantom_tunes/screen_customization.dart';
import 'package:phantom_tunes/song_screen.dart';

import 'package:phantom_tunes/utilis/app_state.dart'; // Import your new app_state

// Helper for toasts (consider using a custom Persona 5 themed toast)
void showCustomToast(BuildContext context, String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.grey, // Adjust color for Persona 5 theme
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // We'll manage current screen index locally for BottomNavigationBar
  // but the player visibility will come from AppState
  int _selectedIndex = 0;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();

    // Listen to changes in the player's current index to update the global currentPlayingSong
    player.currentIndexStream.listen((index) {
      if (index != null && allSongs.value.isNotEmpty) {
        currentPlayingSong.value = allSongs.value[index];
      }
    });

    // Listen to visibility changes to rebuild the HomeScreen
    isPlayerVisible.addListener(_onPlayerVisibilityChanged);
  }

  @override
  void dispose() {
    isPlayerVisible.removeListener(_onPlayerVisibilityChanged);
    super.dispose();
  }

  void _onPlayerVisibilityChanged() {
    setState(() {
      // Rebuilds the UI when isPlayerVisible changes
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Update the global currentAppScreen based on the tapped item
      switch (index) {
        case 0:
          currentAppScreen.value = AppScreen.songs;
          break;
        case 1:
          currentAppScreen.value = AppScreen.playlists;
          break;
        case 2:
          currentAppScreen.value = AppScreen.favorites;
          break;
      }
    });
  }

  // Request storage permission, then allow queries
  Future<void> _checkAndRequestPermission() async {
    if (!kIsWeb) {
      try {
        bool permissionStatus = await audioQuery.permissionsStatus();
        if (!permissionStatus) {
          permissionStatus = await audioQuery.permissionsRequest();
        }
        if (mounted) {
          setState(() {
            _hasPermission = permissionStatus;
          });
          if (!permissionStatus) {
            showCustomToast(context, "Storage permission denied. Cannot load songs.");
          }
        }
      } catch (e) {
        debugPrint("Permission error: $e");
        if (mounted) {
          setState(() {
            _hasPermission = true; // Try anyway
          });
        }
      }
    } else {
      setState(() {
        _hasPermission = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to isPlayerVisible directly to show/hide SongScreen
    return ValueListenableBuilder<bool>(
      valueListenable: isPlayerVisible,
      builder: (context, playerIsVisible, child) {
        if (playerIsVisible) {
          return SongScreen(); // Show the full screen player
        }

        return Scaffold(
          backgroundColor: Colors.transparent, // Assuming a background image/gradient will be behind this
          appBar: const CustomAppBar(),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xffff0505), // Persona 5 red
            unselectedItemColor: Colors.white,
            selectedItemColor: Colors.white,
            selectedLabelStyle: const TextStyle(fontFamily: 'Persona', fontSize: 10),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Persona', fontSize: 10),
            currentIndex: _selectedIndex, // Use the local selected index
            onTap: _onItemTapped, // Use the proper onTap for BottomNavigationBar
            items: [
              BottomNavigationBarItem(
                icon: Image.asset("assets/icons/home.png", height: 50),
                label: "Songs",
              ),
              BottomNavigationBarItem(
                icon: Image.asset("assets/icons/playlists.png", height: 50),
                label: "Playlists",
              ),
              BottomNavigationBarItem(
                icon: Image.asset("assets/icons/favorite.png", height: 50),
                label: "Favorites",
              ),
            ],
          ),
          body: ValueListenableBuilder<AppScreen>(
            valueListenable: currentAppScreen,
            builder: (context, screen, child) {
              switch (screen) {
                case AppScreen.playlists:
                  return const PlaylistScreen();
                case AppScreen.favorites:
                  // You'll need to implement your FavoritesScreen here
                  return const Center(child: Text("Favorites Screen (Not Implemented)", style: TextStyle(color: Colors.white)));
                case AppScreen.songs:
                default:
                  return _buildSongsList();
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildSongsList() {
    // Don't query until permissions are granted
    if (!_hasPermission) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xffff0505)),
            SizedBox(height: 16),
            Text("Requesting permissions...", style: TextStyle(color: Colors.white, fontFamily: 'Arsenal')),
          ],
        ),
      );
    }

    return FutureBuilder<List<SongModel>>(
      future: audioQuery.querySongs(
        sortType: null, // Default sort or specify as needed
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
        }
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const Center(child: Text("No Songs Found", style: TextStyle(color: Colors.white)));
        }

        // Update the global song list when data is available
        allSongs.value = snapshot.data!
            .where((song) => song.duration != null && song.duration! > 0) // Filter out invalid songs
            .toList();
        allSongs.value.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

        return ListView.builder(
          itemCount: allSongs.value.length,
          itemBuilder: (context, index) {
            final song = allSongs.value[index];
            return CustomPaint(
              // The BackgroundPainter seems to draw the black/red parallelogram
              // It's applied to each ListTile, which might be heavy.
              // Consider if this background should be for the whole list or individual items.
              // If it's for individual items, ensure its dimensions are correct for the ListTile.
              painter: BackgroundPainter(strokeColor: Colors.white, context: context),
              child: Container(
                padding: EdgeInsets.only(
                    top: 0.019 * MediaQuery.of(context).size.height,
                    bottom: 0.02 * MediaQuery.of(context).size.height),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.transparent),
                ),
                child: ListTile(
                  title: Text(
                    song.title,
                    style: const TextStyle(
                      color: Color(0xffffffff),
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
                      color: Color(0xffffffff),
                      fontFamily: 'Arsenal',
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  trailing: GestureDetector(
                    onTap: () => _showSongOptions(context, song),
                    child: Image.asset("assets/icons/more.png", height: 30),
                  ),
                  leading: SizedBox(
                    width: 0.15 * MediaQuery.of(context).size.width,
                    height: 0.1 * MediaQuery.of(context).size.height,
                    child: Transform(
                      // This transform attempts a 3D rotation, but its values are
                      // highly dependent on devicePixelRatio and might look different
                      // on various devices. Consider simpler rotations or fixed values
                      // if consistency is key.
                      transform: Matrix4.rotationZ(MediaQuery.of(context).devicePixelRatio * (-0.01))
                        ..rotateX(-0.1 * MediaQuery.of(context).devicePixelRatio)
                        ..rotateY(-0.3 * MediaQuery.of(context).devicePixelRatio)
                        ..scale(scaleFactor), // scaleFactor from screen_customization.dart
                      alignment: FractionalOffset.center, // Important for transform origin
                      child: Stack(
                        children: [
                          QueryArtworkWidget(
                            artworkBorder: BorderRadius.zero, // Remove default border radius
                            id: song.id,
                            type: ArtworkType.AUDIO,
                            nullArtworkWidget: Image.asset(
                              "assets/images/persona.png", // Fallback image
                              fit: BoxFit.cover,
                            ),
                          ),
                          // The ImperfectRectangleBorder for the album art
                          // Make sure this painter is drawing within the bounds of QueryArtworkWidget's size.
                          // Its current implementation using screenWidth/Height directly is problematic.
                          Positioned.fill( // Positioned.fill makes it cover its parent
                            child: CustomPaint(
                              painter: ImperfectRectangleBorder(strokeColor: Colors.white, context: context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () async {
                    // This logic is now handled by AudioPlayerManager
                    if (currentPlayingSong.value != song) {
                      await audioPlayerManager.playSong(index);
                    }
                    isPlayerVisible.value = true; // Show the SongScreen
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSongOptions(BuildContext context, SongModel song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color(0xffff0505), width: 2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with song name
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
                const Divider(color: Color(0xffff0505), height: 1),
                // Add to playlist
                ListTile(
                  leading: const Icon(Icons.playlist_add, color: Color(0xffff0505)),
                  title: const Text(
                    "Add to playlist",
                    style: TextStyle(
                      fontFamily: 'Arsenal',
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showPlaylistPicker(song);
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
          side: BorderSide(color: Color(0xffff0505), width: 2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
        ),
        builder: (ctx) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "CHOOSE PLAYLIST",
                    style: TextStyle(
                      fontFamily: 'Persona',
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                const Divider(color: Color(0xffff0505), height: 1),
                // Create new
                ListTile(
                  leading: const Icon(Icons.add, color: Color(0xffff0505)),
                  title: const Text(
                    "Create new playlist",
                    style: TextStyle(
                      fontFamily: 'Arsenal',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final name = await _showCreatePlaylistDialog();
                    if (name != null && name.trim().isNotEmpty) {
                      final created = await audioQuery.createPlaylist(name.trim());
                      if (created) {
                        // Re-query to get the new playlist's ID
                        final updatedPlaylists = await audioQuery.queryPlaylists(
                          sortType: PlaylistSortType.DATE_ADDED,
                          orderType: OrderType.DESC_OR_GREATER,
                        );
                        if (updatedPlaylists.isNotEmpty) {
                          final newPlaylist = updatedPlaylists.first;
                          await audioQuery.addToPlaylist(newPlaylist.id, song.id);
                          Fluttertoast.showToast(
                            msg: "\"${song.title}\" added to \"$name\"!",
                            backgroundColor: const Color(0xffff0505),
                            textColor: Colors.white,
                          );
                        }
                      }
                    }
                  },
                ),
                // Existing playlists
                if (playlists.isNotEmpty)
                  ...playlists.map((playlist) => ListTile(
                    leading: const Icon(Icons.queue_music, color: Colors.white54),
                    title: Text(
                      playlist.playlist,
                      style: const TextStyle(
                        fontFamily: 'Arsenal',
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      "${playlist.numOfSongs} song${playlist.numOfSongs == 1 ? '' : 's'}",
                      style: const TextStyle(
                        fontFamily: 'Arsenal',
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final success = await audioQuery.addToPlaylist(
                        playlist.id,
                        song.id,
                      );
                      if (success) {
                        Fluttertoast.showToast(
                          msg: "\"${song.title}\" added to \"${playlist.playlist}\"!",
                          backgroundColor: const Color(0xffff0505),
                          textColor: Colors.white,
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg: "Failed to add song",
                          backgroundColor: Colors.grey,
                          textColor: Colors.white,
                        );
                      }
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
          side: BorderSide(color: Color(0xffff0505), width: 2),
          borderRadius: BorderRadius.zero,
        ),
        title: const Text(
          "NEW PLAYLIST",
          style: TextStyle(
            fontFamily: 'Persona',
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(
            fontFamily: 'Arsenal',
            color: Colors.white,
            fontSize: 16,
          ),
          cursorColor: const Color(0xffff0505),
          decoration: const InputDecoration(
            hintText: "Playlist name",
            hintStyle: TextStyle(color: Colors.white38, fontFamily: 'Arsenal'),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffff0505), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "CANCEL",
              style: TextStyle(
                fontFamily: 'Persona',
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xffff0505),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: const Text(
              "CREATE",
              style: TextStyle(
                fontFamily: 'Persona',
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}