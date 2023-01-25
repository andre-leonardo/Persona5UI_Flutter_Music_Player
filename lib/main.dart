import 'package:flutter/material.dart';
import 'package:prime_curso/home_screen.dart';
import 'package:prime_curso/playlist_screen.dart';
import 'package:prime_curso/song_screen.dart';
import 'package:screens/screens.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Persona',
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: const Color(0xffff0505)
        )
      ),
      home: const HomeScreen(),
      getPages: [
        GetPage(name: '/', page: () => const HomeScreen()),
        GetPage(name: '/song', page: () => const SongScreen()),
        GetPage(name: '/playlist', page: () => const PlaylistScreen()),
      ],
    );
  }
}
