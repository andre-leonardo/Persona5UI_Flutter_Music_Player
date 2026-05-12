// lib/main.dart
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phantom_tunes/home_screen.dart';
import 'package:phantom_tunes/utilis/app_state.dart';
import 'package:phantom_tunes/utilis/favorites_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize audio_service with our handler
  audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.phantom_tunes.audio',
      androidNotificationChannelName: 'Phantom Tunes',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
    ),
  );

  // Load persisted favorites
  await FavoritesManager().loadFavorites();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phantom Tunes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFFF0505),
        hintColor: Colors.white,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Arsenal', color: Colors.white),
          bodyMedium: TextStyle(fontFamily: 'Arsenal', color: Colors.white),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}