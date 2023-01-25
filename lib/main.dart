import 'package:flutter/material.dart';
import 'package:prime_curso/home_screen.dart';
import 'package:prime_curso/playlist_screen.dart';
import 'package:prime_curso/song_screen.dart';
import 'package:screens/screens.dart';
import 'package:flutter/src/rendering/box.dart';
import 'package:get/get.dart';

void main() {
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
        ],
      ),
    );
  }
}
