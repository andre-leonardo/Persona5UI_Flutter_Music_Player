// lib/utils/app_state.dart
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';


// Using a custom enum for navigation state
enum AppScreen {
  songs,
  playlists,
  favorites,
  search, // Assuming you want a search screen as well
}

// Global instances (less ideal, but better than individual variables for now)
// In a real app, these would be managed by a state management solution.
final OnAudioQuery audioQuery = OnAudioQuery();
final AudioPlayer player = AudioPlayer();

// These states should ideally be managed by a state management solution
// like Provider, Riverpod, or BLoC, and not as global variables directly.
// For the purpose of fixing your existing code, we'll keep them here
// but with a strong recommendation to refactor.
ValueNotifier<AppScreen> currentAppScreen = ValueNotifier(AppScreen.songs);
ValueNotifier<List<SongModel>> allSongs = ValueNotifier([]);
ValueNotifier<SongModel?> currentPlayingSong = ValueNotifier(null);
ValueNotifier<bool> isPlayerVisible = ValueNotifier(false); // To show/hide the full player screen

// A simple utility to manage audio playback state
class AudioPlayerManager extends ChangeNotifier {
  final AudioPlayer _player;
  SongModel? _currentSong;
  // Change this:
  // bool _isPlaying = false;
  // To this:
  final ValueNotifier<bool> _isPlayingNotifier = ValueNotifier<bool>(false);

  AudioPlayerManager(this._player) {
    _player.playerStateStream.listen((playerState) {
      // Update the ValueNotifier's value
      _isPlayingNotifier.value = playerState.playing;
      // No need to call notifyListeners() here for _isPlayingNotifier
      // as ValueNotifier handles its own notifications.
      // But keep notifyListeners() if other properties (like _currentSong)
      // also trigger general manager changes that widgets might listen to.
      // For this specific case, if only _isPlayingNotifier and _currentSong
      // are exposed as ValueListenables, you might not need the general notifyListeners() here.
      // However, it doesn't hurt.
      notifyListeners();
    });
    _player.currentIndexStream.listen((index) {
      if (index != null && allSongs.value.isNotEmpty) {
        _currentSong = allSongs.value[index];
        notifyListeners();
      }
    });
  }

  SongModel? get currentSong => _currentSong;
  // Change this:
  // bool get isPlaying => _isPlaying;
  // To this:
  ValueListenable<bool> get isPlaying => _isPlayingNotifier; // Expose the ValueNotifier

  Future<void> playSong(int index) async {
    if (allSongs.value.isEmpty) return;
    await _player.setAudioSource(
      createPlaylist(allSongs.value),
      initialIndex: index,
    );
    _currentSong = allSongs.value[index];
    await _player.play();
    notifyListeners();
  }

  Future<void> resume() async {
    await _player.play();
    notifyListeners();
  }

  Future<void> pause() async {
    await _player.pause();
    notifyListeners();
  }

  Future<void> stop() async {
    await _player.stop();
    _currentSong = null;
    notifyListeners();
  }

  ConcatenatingAudioSource createPlaylist(List<SongModel> songs) {
    List<AudioSource> sources = [];
    for (var song in songs){
      sources.add(AudioSource.uri(
        Uri.parse(song.uri!),
        tag: MediaItem(
          id: '${song.id}',
          album: song.album,
          title: song.title,
        ),
      ));
    }
    return ConcatenatingAudioSource(children: sources);
  }
}

// You might initialize this in your main.dart or as a global/singleton
final AudioPlayerManager audioPlayerManager = AudioPlayerManager(player);