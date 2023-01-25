import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const _CustomAppBar(),
        bottomNavigationBar: const _CustomNavBar(),
        body: SingleChildScrollView(
          child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hi,    start    listening!',
                    style: TextStyle(
                      color: Color(0xffffffff),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Joel     Sungado!!!!!',
                    style: TextStyle(
                      color: Color(0xffffffff),
                      fontFamily: 'Persona'
                    ),
                    
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    style: const TextStyle(
                      fontFamily: 'Persona',
                      color: Color(0xffffffff)
                      ),
                    decoration:
                     InputDecoration(
                      filled: true,
                      fillColor: const Color(0xff000000),
                      hintText: 'Search',
                      hintStyle: const TextStyle(
                        color: Color(0xffffffff),
                        fontSize: 13,    
                        ),
                        prefixIcon: Image.asset("assets/icons/search.png", height: 50),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(30.0),
                          bottomRight: Radius.circular(10.0),
                          ),
                          borderSide: BorderSide(
                          color: Colors.white,
                          width: 2.0
                          ),
                          ),
                      // hintStyle: Theme.of(context).textTheme.bodyMedium.copyWith
                    ), 
                  )
                ],
              ),
            )
          ],)
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
      // selectedLabelStyle: const TextStyle(fontFamily: 'Persona', fontSize: 10),
      // unselectedLabelStyle: const TextStyle(fontFamily: 'Persona', fontSize: 10),
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