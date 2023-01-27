import 'package:flutter/material.dart';
import 'package:phantom_tunes/search_screen.dart';
import 'package:just_audio/just_audio.dart';


class HomeScreen extends StatelessWidget {
  
  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const _CustomAppBar(),
        bottomNavigationBar: const _CustomNavBar(),
        body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.music_note),
            title: Text("Song Title"),
            subtitle: Text("Artist Name"),
            onTap: () {
              // Do something when the ListTile is tapped
            },
          ),
          ListTile(
            leading: Icon(Icons.music_note),
            title: Text("Another Song"),
            subtitle: Text("Another Artist"),
            onTap: () {
              // Do something when the ListTile is tapped
            },
          ),
        ],
      ),
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
      backgroundColor: const Color(0x00000000),
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
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SizedBox(
            width: constraints.maxWidth * 0.2, // 20% of the screen width
            height: constraints.maxWidth * 0.2, // 20% of the screen width
            child: Image.asset("assets/icons/logo.png"),
          );
        },
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            child: const Image(
              image: AssetImage("assets/icons/search.png"),
            ),
          ),
        )
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