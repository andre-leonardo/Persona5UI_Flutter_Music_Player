import 'package:flutter/material.dart';
import 'package:phantom_tunes/home_screen.dart';
import 'package:phantom_tunes/playlist_screen.dart';
import 'package:phantom_tunes/song_screen.dart';
import 'package:phantom_tunes/search_screen.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phantom_tunes/utilis/global_variables.dart';


//this code is a frankenstein's monster made with various tutorial from indian programmers
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.storage.request();
  await Hive.initFlutter();
  await JustAudioBackground.init(
  androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
  androidNotificationChannelName: 'Phantom Tunes',
  androidNotificationOngoing: true,
  notificationColor: const Color(0xffff0505),
  androidNotificationChannelDescription: 'Phantom Tunes',
  );
  runApp(const MyApp());
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
            bodyLarge: TextStyle(
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


