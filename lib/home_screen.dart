import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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



class HomeScreen extends StatefulWidget {
  
  const HomeScreen({super.key});
  

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}






class ImperfectRectangleBorder extends CustomPainter {
  final Color strokeColor;
  ImperfectRectangleBorder({this.strokeColor = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    var path = Path();
    // Your code to draw the imperfect rectangle
    path.moveTo(0, -5);
    path.lineTo(size.width*(0.2), size.height+10);
    path.lineTo(size.width, size.height-5);
    path.lineTo(size.height*(0.8), -1 );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ImperfectRectangleBorder oldDelegate) =>
      oldDelegate.strokeColor != strokeColor;
}

class ArtworkWithShape extends StatelessWidget {
  final Path path;
  final int id;
  final ArtworkType type;

  const ArtworkWithShape({required this.path, required this.id, required this.type});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ShapeClipper(path: path),
      child: QueryArtworkWidget(
        artworkBorder: BorderRadius.zero,
        id: id,
        type: type,
      ),
    );
  }
}

class ShapeClipper extends CustomClipper<Path> {
  final Path path;

  ShapeClipper({required this.path});

  @override
  Path getClip(Size size) {
    return path;
  }

  @override
  bool shouldReclip(ShapeClipper oldClipper) => oldClipper.path != path;
}

class _HomeScreenState extends State<HomeScreen> {

  final OnAudioQuery _audioQuery = OnAudioQuery();

  //request permission from initStateMethod
  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _CustomAppBar(),
        bottomNavigationBar: _CustomNavBar(),
        body: FutureBuilder<List<SongModel>>(
          future: _audioQuery.querySongs(
            sortType: null,
            orderType: OrderType.ASC_OR_SMALLER,
            uriType: UriType.EXTERNAL,
            ignoreCase: true,
          ),
          builder: (context, item){
            if(item.data == null){
              return const Center(child: CircularProgressIndicator(),);   
            }
            if(item.data!.isEmpty){
              return const Center(child: Text("No Songs Found"),);
            }

            return ListView.builder(
              itemCount: item.data!.length,
              itemBuilder: ((context, index) {
                return Container(
                  margin: const EdgeInsets.only(top: 5, left: 12, right: 15),
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  decoration:  BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.grey),
                  ),

                  child: ListTile(
                      title: Text(item.data![index].title,
                          style: const TextStyle(
                              color: Color(0xffffffff),
                              fontFamily: 'Arsenal',
                              fontSize: 18,
                              fontWeight: FontWeight.w700
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                      ),
                      subtitle: Text(item.data![index].artist??"<Unknown>",
                          style: const TextStyle(
                              color: Color(0xffffffff),
                              fontFamily: 'Arsenal',
                              fontSize: 14,
                              fontWeight: FontWeight.w300
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                      ),
                      trailing: const Icon(Icons.more_vert),
                      leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: CustomPaint(
                        painter: ImperfectRectangleBorder(strokeColor: Colors.white),
                        child: QueryArtworkWidget(//from on_audio_query package
                          artworkBorder: BorderRadius.zero,
                          artworkFit: BoxFit.fill,
                          id: item.data![index].id,
                          type: ArtworkType.AUDIO,
                        ),
                      ),
                    ),
                    ),

                );
              }),
            );
          },
        ),
          
      );
    
  }
  
  
  void requestStoragePermission() async {
    //only if the platform is not web, coz web have no permissions
    if(!kIsWeb){
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if(!permissionStatus){
        await _audioQuery.permissionsRequest();
      }

      //ensure build method is called
      setState(() { });
    }
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


