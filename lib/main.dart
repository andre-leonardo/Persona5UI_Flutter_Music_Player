// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemChrome
import 'package:phantom_tunes/home_screen.dart';
// If you plan to use audio_service for background playback:
// @pragma('vm:entry-point')
// void audioPlayerTaskEntrypoint() async {
//   AudioServiceBackground.run(() => AudioPlayerHandler());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set desired orientation (if needed)
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // If using AudioService, initialize it here:
  // await AudioService.init(builder: () => AudioPlayerHandler());

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
        // Define your Persona 5 inspired theme here
        primaryColor: const Color(0xffff0505),
        hintColor: Colors.white,
        scaffoldBackgroundColor: Colors.black, // Dark background
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Arsenal', color: Colors.white),
          bodyMedium: TextStyle(fontFamily: 'Arsenal', color: Colors.white),
          // Add other text styles as needed
        ),
        // ... more theming
      ),
      home: const HomeScreen(),
    );
  }
}