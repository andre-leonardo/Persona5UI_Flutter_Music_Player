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
  final BuildContext context;
  ImperfectRectangleBorder({this.strokeColor = Colors.white, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeigth = MediaQuery.of(context).size.height;
    var paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    var path = Path();
    // white imperfect rectangle
    path.moveTo(0, -0.002 * screenHeigth);
    path.lineTo(size.width * (-0.02), 0.07 * screenHeigth);
    path.lineTo(size.width, 0.07 * screenHeigth);
    path.lineTo(size.width * (1), -1 / screenHeigth);
    path.close();
    canvas.drawPath(path, paint);
    // black imperfect rectangle
    paint.color = Colors.black;
    paint.strokeWidth = 6.0;
    var borderPath = Path();
    borderPath.moveTo(screenWidth * -0.012, -0.011 * screenHeigth);
    borderPath.lineTo(size.width * (-0.1), 0.075 * screenHeigth);
    borderPath.lineTo(size.width * (1.1), 0.074 * screenHeigth);
    borderPath.lineTo(size.width * (1.05), -0.005 * screenHeigth);
    borderPath.close();
    canvas.drawPath(borderPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BackgroundPainter extends CustomPainter {

  final Color strokeColor;
  final BuildContext context;
  BackgroundPainter({this.strokeColor = Colors.white, required this.context});
  @override
  void paint(Canvas canvas, Size size) {
    Paint fillPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(size.width / 5, size.height / 4.5);
    path.lineTo(size.width / 5, size.height /4.5);
    path.lineTo(size.width / 1.1, size.height * 0.19);
    path.lineTo(size.width / 1.2, size.height / 1.3);
    path.lineTo(size.width * 0.2, size.height / 1.3 );
    path.close();

    canvas.drawPath(path, fillPaint);

    Paint borderPaint1 = Paint()
      ..color = Colors.white
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, borderPaint1);

    Paint borderPaint2 = Paint()
      ..color = Color(0xffff0505)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

      Path invisibleBorder = Path();
      invisibleBorder.moveTo(size.width / 5.3, size.height / 4.5);
      invisibleBorder.lineTo(size.width / 5, size.height /7);
      invisibleBorder.lineTo(size.width / 1.059, size.height * 0.12);
      invisibleBorder.lineTo(size.width / 1.19, size.height / 1.22);
      invisibleBorder.lineTo(size.width * 0.192, size.height / 1.2 );
      invisibleBorder.close();

    canvas.drawPath(invisibleBorder, borderPaint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


double imperfectRectangleAspectRatio = 600;
double imageAspectRatio = 500;

double scaleFactor = calculateScaleFactor(imperfectRectangleAspectRatio, imageAspectRatio);
  double calculateScaleFactor(double rectAspectRatio, double imageAspectRatio) {
    if (rectAspectRatio > imageAspectRatio) {
      return 1.0;
    } else {
      return rectAspectRatio / imageAspectRatio;
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
        appBar: const _CustomAppBar(),
        bottomNavigationBar: const _CustomNavBar(),
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
                return CustomPaint(
                  painter: BackgroundPainter(strokeColor: Colors.white, context: context),
                  child: Container(
                    padding: EdgeInsets.only(top: 0.01 * MediaQuery.of(context).size.height, bottom: 0.02 * MediaQuery.of(context).size.height),
                    decoration:  BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.transparent),
                    ),

                  child: ListTile(
                      title: Text(item.data![index].title,
                          style: const TextStyle(
                              color: Color(0xffffffff),
                              fontFamily: 'Arsenal',
                              fontSize: 17,
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

                      //my pathetic efforts trying to shape the song artwork
                     leading: SizedBox(
                        width: 50,
                        height: 50,
                        child: Transform(
                          transform: Matrix4.rotationZ(MediaQuery.of(context).devicePixelRatio*(-0.01))
                            ..rotateX(-0.1 * MediaQuery.of(context).devicePixelRatio)
                            ..rotateY(-0.3 * MediaQuery.of(context).devicePixelRatio)
                            ..scale(scaleFactor),
                          child: Stack(
                            children: [
                              QueryArtworkWidget(
                                artworkBorder: BorderRadius.zero,
                                id: item.data![index].id,
                                type: ArtworkType.AUDIO,
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: CustomPaint(
                                  painter: ImperfectRectangleBorder(strokeColor: Colors.white, context: context,),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),




                    ),
                  )
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


