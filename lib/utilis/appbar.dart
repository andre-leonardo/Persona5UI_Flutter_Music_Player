// lib/utilis/appbar.dart

import 'package:flutter/material.dart';
import 'package:phantom_tunes/search_screen.dart'; // Ensure this import is correct

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent, // Or your specific Persona 5 red
      elevation: 0, // No shadow
      centerTitle: true, // Recommended when using leading/actions
      titleSpacing: 0, // Reduces default title spacing

      // --- LEADING ICON (Left side) ---
      leading: GestureDetector(
        onTap: () {
          // Ensure your Scaffold has a Drawer defined in HomeScreen
          Scaffold.of(context).openDrawer();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0), // Padding from the screen edge
          child: Image.asset(
            "assets/images/persona2.png", // Corrected name
            height: 35, // Consistently set height
            errorBuilder: (ctx, error, stacktrace) { // Add errorBuilder for debug
              debugPrint('Error loading menu_icon.png in AppBar: $error');
              return const Icon(Icons.error_outline, color: Colors.red, size: 35);
            },
          ),
        ),
      ),

      // --- ACTIONS (Right side icons) ---
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0), // Padding from the screen edge
            child: Image.asset(
              "assets/icons/search.png", // Confirmed correct name
              height: 35, // Consistently set height
              errorBuilder: (ctx, error, stacktrace) { // Add errorBuilder for debug
                debugPrint('Error loading search.png in AppBar: $error');
                return const Icon(Icons.error_outline, color: Colors.red, size: 35);
              },
            ),
          ),
        ),
      ],

      // --- TITLE (Center content) ---
      // The title itself will automatically be horizontally constrained by the AppBar
      // if `leading` and `actions` are used correctly.
      title: const Text(
        "PHANTOM TUNES", // Your app name
        style: TextStyle(
          fontFamily: 'Persona', // Use your Persona font
          fontSize: 22, // Reduced font size for better fit
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center, // Center text within its allocated space
        maxLines: 1, // Crucial: Prevents text from wrapping to another line
        overflow: TextOverflow.ellipsis, // Crucial: Adds "..." if text is too long
      ),
    );
  }

  @override
  // Adjust preferredSize as needed. 90.0 is a reasonable height for icons+padding.
  Size get preferredSize => const Size.fromHeight(90.0);
}