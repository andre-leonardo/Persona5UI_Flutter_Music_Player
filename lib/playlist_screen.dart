import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:phantom_tunes/utilis/app_state.dart';
import 'package:phantom_tunes/screen_customization.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  List<PlaylistModel> _playlists = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    try {
      final playlists = await audioQuery.queryPlaylists(
        sortType: PlaylistSortType.DATE_ADDED,
        orderType: OrderType.DESC_OR_GREATER,
      );
      if (mounted) {
        setState(() {
          _playlists = playlists;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading playlists: $e");
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _createPlaylist() async {
    final name = await _showCreatePlaylistDialog();
    if (name != null && name.trim().isNotEmpty) {
      try {
        final success = await audioQuery.createPlaylist(name.trim());
        if (success) {
          Fluttertoast.showToast(
            msg: "Playlist \"$name\" created!",
            backgroundColor: const Color(0xffff0505),
            textColor: Colors.white,
          );
          _loadPlaylists(); // Refresh
        } else {
          Fluttertoast.showToast(
            msg: "Failed to create playlist",
            backgroundColor: Colors.grey,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        debugPrint("Error creating playlist: $e");
        Fluttertoast.showToast(msg: "Error: $e");
      }
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

  Future<void> _deletePlaylist(PlaylistModel playlist) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Color(0xffff0505), width: 2),
          borderRadius: BorderRadius.zero,
        ),
        title: const Text(
          "DELETE PLAYLIST?",
          style: TextStyle(
            fontFamily: 'Persona',
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        content: Text(
          'Delete "${playlist.playlist}"?',
          style: const TextStyle(
            fontFamily: 'Arsenal',
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
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
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xffff0505),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: const Text(
              "DELETE",
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

    if (confirm == true) {
      try {
        final success = await audioQuery.removePlaylist(playlist.id);
        if (success) {
          Fluttertoast.showToast(
            msg: "Playlist deleted",
            backgroundColor: const Color(0xffff0505),
            textColor: Colors.white,
          );
          _loadPlaylists();
        }
      } catch (e) {
        debugPrint("Error deleting playlist: $e");
      }
    }
  }

  void _openPlaylistDetail(PlaylistModel playlist) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return PlaylistDetailScreen(playlist: playlist);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xffff0505)),
      );
    }

    return Column(
      children: [
        // Create playlist button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: _createPlaylist,
            child: CustomPaint(
              painter: BackgroundPainter(strokeColor: Colors.white, context: context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Color(0xffff0505), size: 28),
                    SizedBox(width: 12),
                    Text(
                      "CREATE NEW PLAYLIST",
                      style: TextStyle(
                        fontFamily: 'Persona',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Playlist list
        Expanded(
          child: _playlists.isEmpty
              ? const Center(
                  child: Text(
                    "No playlists yet.\nCreate one to get started!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Arsenal',
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = _playlists[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: CustomPaint(
                        painter: BackgroundPainter(
                          strokeColor: Colors.white,
                          context: context,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 0.015 * MediaQuery.of(context).size.height,
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xffff0505),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.queue_music,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                            title: Text(
                              playlist.playlist,
                              style: const TextStyle(
                                fontFamily: 'Arsenal',
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            subtitle: Text(
                              "${playlist.numOfSongs} song${playlist.numOfSongs == 1 ? '' : 's'}",
                              style: const TextStyle(
                                fontFamily: 'Arsenal',
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                            trailing: GestureDetector(
                              onTap: () => _deletePlaylist(playlist),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white54,
                                size: 24,
                              ),
                            ),
                            onTap: () => _openPlaylistDetail(playlist),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Playlist Detail Screen — shows songs in a playlist
// and allows adding more songs
// ──────────────────────────────────────────────

class PlaylistDetailScreen extends StatefulWidget {
  final PlaylistModel playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  List<SongModel> _playlistSongs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylistSongs();
  }

  Future<void> _loadPlaylistSongs() async {
    try {
      final songs = await audioQuery.queryAudiosFrom(
        AudiosFromType.PLAYLIST,
        widget.playlist.id,
      );
      if (mounted) {
        setState(() {
          _playlistSongs = songs;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading playlist songs: $e");
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _showAddSongsDialog() async {
    // Get all available songs
    if (allSongs.value.isEmpty) {
      try {
        final songs = await audioQuery.querySongs(
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        );
        allSongs.value = songs
            .where((s) => s.duration != null && s.duration! > 0)
            .toList();
        allSongs.value.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      } catch (e) {
        debugPrint("Error querying songs: $e");
        return;
      }
    }

    if (!mounted) return;

    // Show bottom sheet with all songs to pick from
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color(0xffff0505), width: 2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xffff0505), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, color: Color(0xffff0505), size: 24),
                      const SizedBox(width: 12),
                      Text(
                        "ADD TO ${widget.playlist.playlist.toUpperCase()}",
                        style: const TextStyle(
                          fontFamily: 'Persona',
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Song list
                Expanded(
                  child: allSongs.value.isEmpty
                      ? const Center(
                          child: Text(
                            "No songs available",
                            style: TextStyle(
                              fontFamily: 'Arsenal',
                              color: Colors.white54,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: allSongs.value.length,
                          itemBuilder: (ctx, index) {
                            final song = allSongs.value[index];
                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white24,
                                    width: 1,
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
                              title: Text(
                                song.title,
                                style: const TextStyle(
                                  fontFamily: 'Arsenal',
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              subtitle: Text(
                                song.artist ?? "<Unknown>",
                                style: const TextStyle(
                                  fontFamily: 'Arsenal',
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              trailing: const Icon(
                                Icons.add_circle_outline,
                                color: Color(0xffff0505),
                                size: 24,
                              ),
                              onTap: () async {
                                await _addSongToPlaylist(song);
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    // Refresh after closing
    _loadPlaylistSongs();
  }

  Future<void> _addSongToPlaylist(SongModel song) async {
    try {
      final success = await audioQuery.addToPlaylist(
        widget.playlist.id,
        song.id,
      );
      if (success) {
        Fluttertoast.showToast(
          msg: "\"${song.title}\" added!",
          backgroundColor: const Color(0xffff0505),
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Failed to add song",
          backgroundColor: Colors.grey,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error adding song to playlist: $e");
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  Future<void> _removeSongFromPlaylist(SongModel song) async {
    try {
      final success = await audioQuery.removeFromPlaylist(
        widget.playlist.id,
        song.id,
      );
      if (success) {
        Fluttertoast.showToast(
          msg: "Song removed",
          backgroundColor: const Color(0xffff0505),
          textColor: Colors.white,
        );
        _loadPlaylistSongs();
      }
    } catch (e) {
      debugPrint("Error removing song: $e");
    }
  }

  Future<void> _playPlaylist(int startIndex) async {
    if (_playlistSongs.isEmpty) return;
    await audioPlayerManager.playSong(startIndex);
    // Override allSongs with playlist songs for playback context
    allSongs.value = _playlistSongs;
    isPlayerVisible.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xffff0505),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        title: Transform.rotate(
          angle: -0.03,
          child: Text(
            widget.playlist.playlist.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Persona',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          // Add songs button
          GestureDetector(
            onTap: _showAddSongsDialog,
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xffff0505),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 20),
                  SizedBox(width: 4),
                  Text(
                    "ADD",
                    style: TextStyle(
                      fontFamily: 'Persona',
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xffff0505)),
            )
          : _playlistSongs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.queue_music,
                        color: Colors.white24,
                        size: 80,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "This playlist is empty",
                        style: TextStyle(
                          fontFamily: 'Arsenal',
                          color: Colors.white54,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _showAddSongsDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffff0505),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Text(
                            "ADD SONGS",
                            style: TextStyle(
                              fontFamily: 'Persona',
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Play all button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: GestureDetector(
                        onTap: () => _playPlaylist(0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xffff0505),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow,
                                  color: Colors.white, size: 28),
                              SizedBox(width: 8),
                              Text(
                                "PLAY ALL",
                                style: TextStyle(
                                  fontFamily: 'Persona',
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Songs list
                    Expanded(
                      child: ListView.builder(
                        itemCount: _playlistSongs.length,
                        itemBuilder: (context, index) {
                          final song = _playlistSongs[index];
                          return Dismissible(
                            key: Key("${song.id}_$index"),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: const Color(0xffff0505),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            onDismissed: (_) =>
                                _removeSongFromPlaylist(song),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical:
                                    0.01 * MediaQuery.of(context).size.height,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white10,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white24,
                                      width: 1,
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
                                title: Text(
                                  song.title,
                                  style: const TextStyle(
                                    fontFamily: 'Arsenal',
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                subtitle: Text(
                                  song.artist ?? "<Unknown>",
                                  style: const TextStyle(
                                    fontFamily: 'Arsenal',
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                trailing: const Icon(
                                  Icons.drag_handle,
                                  color: Colors.white24,
                                  size: 20,
                                ),
                                onTap: () => _playPlaylist(index),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}