import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration (
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xffff0505),
            Color(0xffff0505),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const _CustomAppBar(),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0x00000000),
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.white,
          selectedLabelStyle: const TextStyle(fontFamily: 'Persona', fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Persona', fontSize: 10),
          items: [
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/home.png", height: 50,), 
            label: "Songs",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/favorite.png", height: 50,), 
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/playlists.png", height: 50,),
            label: "Playlists",
          ),
          
          
        ]),
        body: Container(),
      ),
    );
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
      leading: const Icon(Icons.grid_view_rounded),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 20),
          child: const Image(
            image: AssetImage("assets/images/persona.png"),
          ),
        )
      ],
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(56);
}