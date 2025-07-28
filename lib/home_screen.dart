import 'package:audio_video_progress_bar/audio_video_progress_bar.dart'; // Keep if you use it in SongScreen
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Keep one toast library
import 'package:phantom_tunes/playlist_screen.dart';
import 'package:phantom_tunes/utilis/appbar.dart'; // Assuming this is your custom app bar
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart'; // Keep if used for PositionData in SongScreen
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audio_service/audio_service.dart'; // Keep if you're setting up background audio
import 'package:phantom_tunes/screen_customization.dart';
import 'package:phantom_tunes/song_screen.dart';
import 'package:phantom_tunes/search_screen.dart'; // Assuming you have this
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

  @override
  void initState() {
    super.initState();
    requestStoragePermission();

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

  // Request storage permission
  void requestStoragePermission() async {
    if (!kIsWeb) {
      bool permissionStatus = await audioQuery.permissionsStatus();
      if (!permissionStatus) {
        bool granted = await audioQuery.permissionsRequest();
        if (!granted) {
          showCustomToast(context, "Storage permission denied. Cannot load songs.");
        }
      }
      // Trigger a rebuild after permission status is checked/requested
      setState(() {});
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
                  trailing: Image.asset("assets/icons/more.png", height: 30),
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
                              "assets/images/persona_logo.png", // Fallback image
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
}