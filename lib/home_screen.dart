import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:phantom_tunes/search_screen.dart';
import 'package:just_audio/just_audio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audio_service/audio_service.dart';
import 'package:phantom_tunes/main.dart';
import 'package:phantom_tunes/screenCustomization.dart';


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
  int nowPlaying = 0;

  bool isPlayerVisible = false;
  bool isItPlaying = false;
  
  

  void changePlayerVisibility() {
    setState(() {
      isPlayerVisible = !isPlayerVisible;
    });
  }

  void changePlayingState()
  {
    setState(() {
      isItPlaying = !isItPlaying;
    });
  }

  bool _showSecondBody = false;

  
  int _currentIndex = 0;
    void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
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
                            changePlayingState();
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
        bottomNavigationBar:  BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xffff0505),
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.white,
          selectedLabelStyle: const TextStyle(fontFamily: 'Persona', fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Persona', fontSize: 10),
          onTap: _onItemTapped,
          items: [
          BottomNavigationBarItem(
            icon: GestureDetector(
            onTap: () {
              _onItemTapped(0);
            },
            child: Image.asset("assets/icons/home.png", height: 50),
          ),
            
            label: "Songs",
          ),
          BottomNavigationBarItem(
          icon: GestureDetector(
            onTap: () {
              _onItemTapped(1);
            },
            child: Image.asset("assets/icons/playlists.png", height: 50),
          ),
          label: "Playlists",
        ),
          BottomNavigationBarItem(
            icon: GestureDetector(
            onTap: () {
              _onItemTapped(2);
            },
            child: Image.asset("assets/icons/favorite.png", height: 50),
          ),
            label: "Favorites",
          ),
          
          
          
        ]),
      body:  _bodySelector(_currentIndex)
          
    );
    
  }

  Widget _bodySelector(_currentIndex) {
    switch(_currentIndex){
      case 1: return _playlist(context);
    }
    return _home();
  }

  Widget _home() {
    return FutureBuilder<List<SongModel>>(
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
            item.data!.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));  
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
                      trailing: Image.asset("assets/icons/more.png", height: 30,), 

                      //my pathetic efforts trying to shape the song artwork
                     leading: SizedBox(
                        width: 0.15 * MediaQuery.of(context).size.width,
                        height: 0.1 * MediaQuery.of(context).size.height,
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
                      if (!isItPlaying) {
                        // hide the player and stop the audio
                        await _player.setAudioSource(
                            createPlaylist(item.data!),
                            initialIndex: index);
                            nowPlaying = index;
                            print(index);
                        changePlayingState();
                        await _player.play();
                        changePlayerVisibility();
                      } else {
                        // show the player and start the audio only if it's not already playing
                        changePlayerVisibility();
                        if (isItPlaying) {
                          if(index != nowPlaying)
                          {
                            await _player.setAudioSource(
                            createPlaylist(item.data!),
                            initialIndex: index);
                            nowPlaying = index;
                            await _player.play();
                          }
                        }
                      }
                    }



                    ),
                  )
                );
              }),
            );
          },
        );
  }




 Widget _playlist(BuildContext context) {
  void addSongToPlaylist() {
  // TODO: Add logic to add song to playlist
  toast(context, 'song added to playlist');
}

  return InkWell(
    onTap: () {
      addSongToPlaylist();
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 5)
      ),
      child: Row(children: const [
        Flexible(
          child: Icon(Icons.add)
        ),
        Flexible(
          child: Text('Add song to playlist'),
        )
      ]),
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


class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
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


