import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:phantom_tunes/song_screen.dart';



  final OnAudioQuery audioQuery = OnAudioQuery();

  var check = 0;
  final AudioPlayer player = AudioPlayer();


  List<SongModel> songs = [];
  String currentSongTitle = '';
  int currentIndex = 0;
  int nowPlaying = 0;


  bool isPlayerVisible = false;
  bool isItPlaying = false;
  
  

  void changePlayerVisibility() {
      isPlayerVisible = !isPlayerVisible;
  }

  void changePlayingState()
  {
      isItPlaying = !isItPlaying;
  }

  const bool showSecondBody = false;

  
  int currenTIndex = 0;
  
  void onItemTapped(int index) {
      currenTIndex = index;
  }


  Stream<DurationState> get durationStateStream =>
    Rx.combineLatest2<Duration, Duration?, DurationState>(
      player.positionStream, player.durationStream, (position, duration) => DurationState(
        position: position, total: duration?? Duration.zero
      )
    );



  




  