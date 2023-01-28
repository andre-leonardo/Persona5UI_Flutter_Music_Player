import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phantom_tunes/search_screen.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:on_audio_query/on_audio_query.dart';



void toast(BuildContext context, String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0
  );
}



class HomeScreen extends StatelessWidget {
  
  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _CustomAppBar(),
        bottomNavigationBar: _CustomNavBar(),
          
      );
    
  }
}


class _CustomNavBar extends StatelessWidget {
  const _CustomNavBar({
    Key? key,
  }) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xffff0505),
      unselectedItemColor: Colors.white,
      selectedItemColor: Colors.white,
      selectedLabelStyle: const TextStyle(fontFamily: 'Persona', fontSize: 10),
      unselectedLabelStyle: const TextStyle(fontFamily: 'Persona', fontSize: 10),
      items: [
      BottomNavigationBarItem(
        icon: Image.asset("assets/icons/home.png", height: 50), 
        
        label: "Songs",
      ),
      BottomNavigationBarItem(
        icon: Image.asset("assets/icons/playlists.png", height: 50),
        label: "Playlists",
      ),
      BottomNavigationBarItem(
        icon: Image.asset("assets/icons/favorite.png", height: 50), 
        label: "Favorites",
      ),
      
      
      
    ]);
  }
}

class _CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  const _CustomAppBar({
    Key? key,
  }) : super(key: key);

  @override 
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        Positioned(
          
          top: 30,
          left: -10,
          child: Image.asset("assets/icons/logo.png", width: 160,),
        ),
        Positioned(
          right: 20,
          top: 40,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            child: const Image(
              image: AssetImage("assets/icons/search.png"),
              width: 38,)
          ),
        ),
        
      ],
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(100);
}


// class _CustomAppBar extends StatelessWidget with PreferredSizeWidget {
//   const _CustomAppBar({
//     Key? key,
//   }) : super(key: key);

//   @override 
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       leading: SizedBox(
//         width: 80,
//         height: 80,
//         child: Image.asset("assets/icons/logo.png", height: 78, width: 78,),
//         ),
//       actions: [
//         Container(
//           margin: const EdgeInsets.only(right: 10),
//           child: InkWell(
//             onTap: () {
//               Navigator.push(
//                 context, 
//                 MaterialPageRoute(builder: (context) => const SearchScreen()),
//               );
//             },
//             child: const Image(
//               image: AssetImage("assets/icons/search.png"),
//             ),
//           ),
//         )
//       ],
//     );
//   }
//   @override
//   Size get preferredSize => const Size.fromHeight(100);
// }