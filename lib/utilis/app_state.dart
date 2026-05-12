// lib/utilis/app_state.dart
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

// ─── Navigation ───
enum AppScreen { songs, playlists, favorites }

// ─── Global singletons ───
final OnAudioQuery audioQuery = OnAudioQuery();

// Populated after AudioService.init() in main.dart
late AudioPlayerHandler audioHandler;

// ─── Observable state ───
ValueNotifier<AppScreen> currentAppScreen = ValueNotifier(AppScreen.songs);

/// The complete device song library — never overwritten by playlists.
ValueNotifier<List<SongModel>> allSongs = ValueNotifier([]);

ValueNotifier<SongModel?> currentPlayingSong = ValueNotifier(null);
ValueNotifier<bool> isPlayerVisible = ValueNotifier(false);
ValueNotifier<Set<int>> favoriteSongIds = ValueNotifier({});

// ─── AudioHandler — manages playback + notifications ───
class AudioPlayerHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);
  final ValueNotifier<LoopMode> loopModeNotifier = ValueNotifier(LoopMode.off);
  final ValueNotifier<bool> shuffleNotifier = ValueNotifier(false);

  /// The songs currently loaded into the player (may differ from allSongs
  /// when a playlist is playing).
  List<SongModel> _loadedSongs = [];

  /// Whether the player is currently loaded with the global library.
  bool _isGlobalLibraryLoaded = false;

  AudioPlayer get player => _player;

  AudioPlayerHandler() {
    // Forward player state changes to audio_service (for notification)
    _player.playbackEventStream.listen(_broadcastState);

    // Track playing state
    _player.playerStateStream.listen((state) {
      isPlayingNotifier.value = state.playing;
    });

    // Track current song index — uses _loadedSongs (the actual player queue)
    _player.currentIndexStream.listen((index) {
      if (index != null && _loadedSongs.isNotEmpty && index < _loadedSongs.length) {
        currentPlayingSong.value = _loadedSongs[index];
        final song = _loadedSongs[index];
        mediaItem.add(_songToMediaItem(song));
      }
    });

    // Auto-advance to next song
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  MediaItem _songToMediaItem(SongModel song) {
    return MediaItem(
      id: song.uri ?? '${song.id}',
      album: song.album ?? '',
      title: song.title,
      artist: song.artist ?? '<Unknown>',
      duration: Duration(milliseconds: song.duration ?? 0),
      extras: {'songId': song.id},
    );
  }

  // ─── Load a list of songs into the player queue ───
  Future<void> loadSongs(List<SongModel> songs) async {
    _loadedSongs = List.from(songs);

    final sources = songs.map((song) => AudioSource.uri(
      Uri.parse(song.uri!),
      tag: _songToMediaItem(song),
    )).toList();

    await _player.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      preload: false,
    );

    // Update audio_service queue
    queue.add(songs.map(_songToMediaItem).toList());
  }

  // ─── Play a song from the global library by its index in allSongs ───
  Future<void> playSongAt(int index) async {
    // Re-load the global library if it's not currently loaded
    if (_player.audioSource == null || !_isGlobalLibraryLoaded) {
      if (allSongs.value.isEmpty) return;
      await loadSongs(allSongs.value);
      _isGlobalLibraryLoaded = true;
    }
    if (index < 0 || index >= _loadedSongs.length) return;

    await _player.seek(Duration.zero, index: index);
    await _player.play();
  }

  // ─── Play from a custom queue (playlists, search results, etc.) ───
  Future<void> playFromCustomQueue(List<SongModel> songs, int index) async {
    if (songs.isEmpty) return;
    await loadSongs(songs);
    _isGlobalLibraryLoaded = false;

    await _player.seek(Duration.zero, index: index);
    await _player.play();
  }

  // ─── BaseAudioHandler overrides ───
  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;
    shuffleNotifier.value = enabled;
    await _player.setShuffleModeEnabled(enabled);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        loopModeNotifier.value = LoopMode.off;
        await _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        loopModeNotifier.value = LoopMode.one;
        await _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        loopModeNotifier.value = LoopMode.all;
        await _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  // Cycle through loop modes: off → all → one → off
  Future<void> cycleLoopMode() async {
    switch (loopModeNotifier.value) {
      case LoopMode.off:
        await setRepeatMode(AudioServiceRepeatMode.all);
        break;
      case LoopMode.all:
        await setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case LoopMode.one:
        await setRepeatMode(AudioServiceRepeatMode.none);
        break;
    }
  }

  // Toggle shuffle
  Future<void> toggleShuffle() async {
    final newMode = shuffleNotifier.value
        ? AudioServiceShuffleMode.none
        : AudioServiceShuffleMode.all;
    await setShuffleMode(newMode);
  }

  // Broadcast player state to audio_service (updates notification)
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    ));
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await _player.dispose();
  }
}