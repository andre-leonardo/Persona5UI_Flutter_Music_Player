import 'package:flutter/material.dart';
import 'package:phantom_tunes/home_screen.dart';
import 'package:phantom_tunes/playlist_screen.dart';
import 'package:phantom_tunes/song_screen.dart';
import 'package:phantom_tunes/search_screen.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:get/get.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Phantom Tunes',
    androidNotificationOngoing: true,
    notificationColor: const Color(0xffff0505),
    androidNotificationChannelDescription: 'Phantom Tunes',

  );
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xffff0505),
      ),
      child: GetMaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily: 'Persona',
          textTheme: const TextTheme(
            bodyText1: TextStyle(
              color: Color(0xffffffff), 
              fontFamily: 'Persona'
            ),
          ),
        ),
        home: const HomeScreen(),
        getPages: [
          GetPage(name: '/', page: () => const HomeScreen()),
          GetPage(name: '/song', page: () => const SongScreen()),
          GetPage(name: '/playlist', page: () => const PlaylistScreen()),
          GetPage(name: '/search', page: () => const SearchScreen()),
        ],
      ),
    );
  }
}


