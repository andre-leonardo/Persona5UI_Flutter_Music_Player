import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:phantom_tunes/search_screen.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audio_service/audio_service.dart';




void toast(BuildContext context, String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
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



class ArtBorderPainter extends CustomPainter {
  final Color strokeColor;
  final BuildContext context;
  ArtBorderPainter({this.strokeColor = Colors.white, required this.context});
  @override
  void paint(Canvas canvas, Size size,) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50;


    var path = Path();
    paint.color = Colors.black;
    path.moveTo(size.width * 0.05, 0.06 * size.height);
    path.lineTo(size.width * (0.06), 0.94 * size.height);
    path.lineTo(size.width * (0.98), 0.95 * size.height);
    path.lineTo(size.width * (1.01), 0.015 * size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
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
      ..strokeWidth = 9.5
      ..style = PaintingStyle.stroke;

    var path = Path();
    // black imperfect rectangle
    paint.color = Colors.black;
    var borderPath = Path();
    borderPath.moveTo(screenWidth * -0.021, -0.008 * screenHeigth);
    borderPath.lineTo(size.width * (-0.1), 0.07 * screenHeigth);
    borderPath.lineTo(size.width * (1), 0.07 * screenHeigth);
    borderPath.lineTo(size.width * (1.0), -0.005 * screenHeigth);
    borderPath.close();
    canvas.drawPath(borderPath, paint);
    // white imperfect rectangle
    paint.color = Colors.white;
    paint.strokeWidth = 5;
    path.moveTo(0, -0.002 * screenHeigth);
    path.lineTo(size.width * (-0.02), 0.07 * screenHeigth);
    path.lineTo(size.width, 0.07 * screenHeigth);
    path.lineTo(size.width * (1), -1 / screenHeigth);
    path.close();
    canvas.drawPath(path, paint);
    
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
    path.moveTo(size.width / 4.6, size.height / 4);
    path.lineTo(size.width / 5, size.height /4);
    path.lineTo(size.width / 1.12, size.height * 0.19);
    path.lineTo(size.width / 1.2, size.height / 1.2);
    path.lineTo(size.width * 0.185, size.height / 1.3 );
    path.close();

    canvas.drawPath(path, fillPaint);

    Paint borderPaint1 = Paint()
      ..color = Colors.white
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, borderPaint1);

    Paint borderPaint2 = Paint()
      ..color = Color(0xffff0505)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

      Path invisibleBorder = Path();
      invisibleBorder.moveTo(size.width / 5, size.height / 4.5);
      invisibleBorder.lineTo(size.width / 5, size.height /4.7);
      invisibleBorder.lineTo(size.width / 1.08, size.height * 0.16);
      invisibleBorder.lineTo(size.width / 1.19, size.height / 1.18);
      invisibleBorder.lineTo(size.width * 0.175, size.height / 1.25 );
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

  var check = 0;
  final AudioPlayer _player = AudioPlayer();


  List<SongModel> songs = [];
  String currentSongTitle = '';
  int currentIndex = 0;

  bool isPlayerVisible = false;

  void changePlayerVisibility() {
    setState(() {
      isPlayerVisible = !isPlayerVisible;
    });
  }

  Stream<DurationState> get _durationStateStream =>
    Rx.combineLatest2<Duration, Duration?, DurationState>(
      _player.positionStream, _player.durationStream, (position, duration) => DurationState(
        position: position, total: duration?? Duration.zero
      )
    );

  //request permission from initStateMethod
  @override
  void initState() {
    super.initState();
    requestStoragePermission();


    _player.currentIndexStream.listen((index) {
      if(index != null){
        _updateCurrentPlayingSongDetails(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(isPlayerVisible){
      return Scaffold(
        backgroundColor: Color(0xffff0505),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 56.0, right: 20.0, left: 20.0),
            decoration: BoxDecoration(color: Color(0xffff0505)), 
            child: Column(
              children: <Widget>[
                //exit and title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(child: 
                    InkWell(
                      onTap: changePlayerVisibility,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset('assets/icons/arrow.png'),
                      ),
                    )
                    ),
                    Flexible(
                      flex: 5,
                      child: Text(
                        currentSongTitle,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      )
                  ],
                ),

                //artwork
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: CustomPaint(
                    painter: ArtBorderPainter(strokeColor: Colors.black, context: context,),
                    child: QueryArtworkWidget(
                      artworkBorder: BorderRadius.zero,
                      id: songs[currentIndex].id, 
                      type: ArtworkType.AUDIO),
                  ),
                ),

                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.zero,
                      margin: const EdgeInsets.only( top: 10),


                      child: StreamBuilder<DurationState>(
                        stream: _durationStateStream,
                        builder: (context, snapshot) {
                          final durationState = snapshot.data;
                          final progress = durationState?.position?? Duration.zero;
                          final total = durationState?.total ?? Duration.zero;
                          final height = MediaQuery.of(context).size.height;
                          final width = MediaQuery.of(context).size.width;
                          return Transform(
                            transform: Matrix4.skewY(height * 5.052189)..scale(width / 350, 0.9),
                            child: Transform.rotate(
                              angle: 25 / 4,
                              child: ProgressBar(
                                progress: progress, 
                                total: total,
                                barHeight: 15,
                                barCapShape: BarCapShape.square,
                                baseBarColor: Colors.black,
                                progressBarColor: Colors.white,
                                thumbColor: Colors.white,
                                thumbRadius: 0,
                                timeLabelTextStyle: const TextStyle(
                                  fontSize: 0,
                                ),
                                onSeek: (duration){
                                  _player.seek(duration);
                                },
                              ),
                            ),
                          );

                        }
                        ),
                      ),


                      StreamBuilder<DurationState>(
                        stream: _durationStateStream,
                        builder: (context, snapshot) {
                          final durationState = snapshot.data;
                          final progress = durationState?.position?? Duration.zero;
                          final total = durationState?.total ?? Duration.zero;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Flexible(
                                child: Text(
                                  progress.toString().split(".")[0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                )
                              ),
                              Flexible(
                                child: Text(
                                  total.toString().split(".")[0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                )
                              ),
                            ],
                          );
                        }),
                    
                  ],
                ),

                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment:  MainAxisAlignment.center,
                    mainAxisSize:  MainAxisSize.max,
                    children: [
                      //skip to previous
                      Flexible(
                        child: InkWell(
                          onTap: (){
                            if(_player.hasPrevious){
                              _player.seekToPrevious();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset("assets/icons/previous.png", width: 30, height: 30,)
                          ),
                        ),
                      ),

                      //play pause
                      Flexible(
                        child: InkWell(
                          onTap: (){
                            if(_player.playing){
                              _player.pause();
                            }else{
                              if(_player.currentIndex != null){
                                _player.play();
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15.0),
                            margin: const EdgeInsets.only(right: 10.0, left: 10.0),
                            child: StreamBuilder<bool>(
                              stream: _player.playingStream,
                              builder: (context, snapshot){
                                bool? playingState = snapshot.data;
                                //play/pause icons
                                if(playingState != null && playingState){
                                  return Image.asset("assets/icons/pause.png", width: 50, height: 50,);
                                }
                                return Image.asset("assets/icons/play.png", width: 50, height: 50,);
                              },
                            ),
                          ),
                        ),
                      ),

                      //skip to next
                      Flexible(
                        child: InkWell(
                          onTap: (){
                            if(_player.hasNext){
                              _player.seekToNext();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset("assets/icons/next.png", width: 30, height: 30,)
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


                //go to playlist, shuffle , repeat all and repeat one control buttons
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      //go to playlist btn
                      Flexible(
                        child: InkWell(
                          onTap: (){changePlayerVisibility();},
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset("assets/icons/list.png", width: 30, height: 30,)
                          ),
                        ),
                      ),

                      //shuffle playlist
                      Flexible(
                        child: InkWell(
                          
                          onTap: (){
                            if(check == 1)
                            {
                              _player.setShuffleModeEnabled(false);
                              check = 0;
                              toast(context, "Shuffling disabled");
                            }
                            else{
                              _player.setShuffleModeEnabled(true);
                              check = 1;
                              toast(context, "Shuffling enabled");
                            }
                            
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            margin:  const EdgeInsets.only(right: 30.0, left: 30.0),
                            child: StreamBuilder<bool>(
                              stream: _player.shuffleModeEnabledStream,
                              builder: (context, snapshot){
                                bool? shuffleModeEnabledStream = snapshot.data;
                                //play/pause icons
                                if(shuffleModeEnabledStream != null && shuffleModeEnabledStream){
                                  return Image.asset("assets/icons/shuffletrue.png", width: 30, height: 30,);
                                }
                                return Image.asset("assets/icons/shufflefalse.png", width: 30, height: 30,);
                              },
                            ),
                          ),
                        ),
                      ),

                      //repeat mode
                      Flexible(
                        child: InkWell(
                          onTap: (){
                            _player.loopMode == LoopMode.one ? _player.setLoopMode(LoopMode.all) : _player.setLoopMode(LoopMode.one);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: StreamBuilder<LoopMode>(
                              stream: _player.loopModeStream,
                              builder: (context, snapshot){
                                final loopMode = snapshot.data;
                                if(LoopMode.one == loopMode){
                                  return Image.asset("assets/icons/loop1.png", width: 30, height: 30,);
                                }
                                return Image.asset("assets/icons/loop.png", width: 30, height: 30,);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                
                
              ],
            ),
            ),
          ),
      );
    }
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

            songs.clear();
            songs = item.data!;
              
            return ListView.builder(
              itemCount: item.data!.length,
              itemBuilder: ((context, index) {
                return CustomPaint(
                  painter: BackgroundPainter(strokeColor: Colors.white, context: context),
                  child: Container(
                    padding: EdgeInsets.only(top: 0.019 * MediaQuery.of(context).size.height, bottom: 0.02 * MediaQuery.of(context).size.height),
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
                    onTap: () async {
                      changePlayerVisibility();
                      //String? uri = item.data![index].uri;
                      // await _player.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
                      
                      await _player.setAudioSource(
                        createPlaylist(item.data!),
                        initialIndex: index
                      );
                      await _player.play();
                    },



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
  
  ConcatenatingAudioSource createPlaylist(List<SongModel> songs) {
    List<AudioSource> sources = [];
    for (var song in songs){
      sources.add(AudioSource.uri
        (
          Uri.parse(song.uri!),
          tag: MediaItem(
            // Specify a unique ID for each media item:
            id: '${song.id}',
            // Metadata to display in the notification:
            album: song.album,
            title: song.title,
            
            // artUri: Uri.parse(song.album),
          ),
        )
      );
    }

    return ConcatenatingAudioSource(children: sources);
  }
  
  void _updateCurrentPlayingSongDetails(int index) {
    setState(() {
      if(songs.isNotEmpty){
        currentSongTitle = songs[index].title;
        currentIndex = index;
      }
    });
  }
  
  getDecoration(BoxShape shape, Offset offset, double blurRadius, double spreadRadius) {
    return BoxDecoration(
      color: Colors.white,
      shape: shape,
      boxShadow: [
        BoxShadow(
          offset: -offset,
          color: Colors.black,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius
        ),
        BoxShadow(
          offset: offset,
          color: Colors.blue,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius
        )
      ]
    );
  }
}

class DurationState{
  DurationState({
      this.position = Duration.zero, this.total = Duration.zero
  });
  Duration position, total;
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


