import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:phantom_tunes/playlist_screen.dart';
import 'package:phantom_tunes/utilis/appbar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audio_service/audio_service.dart';
import 'package:phantom_tunes/screen_customization.dart';
import 'package:phantom_tunes/song_screen.dart';
import 'package:phantom_tunes/search_screen.dart';
import 'package:phantom_tunes/utilis/global_variables.dart';


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

  

  

  //request permission from initStateMethod
  @override
  void initState() {
    super.initState();
    requestStoragePermission();


    player.currentIndexStream.listen((index) {
      if(index != null){
        _updateCurrentPlayingSongDetails(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(isPlayerVisible){
      return SongScreen();
    }
    
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(),
        bottomNavigationBar:  BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xffff0505),
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.white,
          selectedLabelStyle: const TextStyle(fontFamily: 'Persona', fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Persona', fontSize: 10),
          onTap: onItemTapped,
          items: [
          BottomNavigationBarItem(
            icon: GestureDetector(
            onTap: () {
              onItemTapped(0);
            },
            child: Image.asset("assets/icons/home.png", height: 50),
          ),
            
            label: "Songs",
          ),
          BottomNavigationBarItem(
          icon: GestureDetector(
            onTap: () {
              onItemTapped(1);
            },
            child: Image.asset("assets/icons/playlists.png", height: 50),
          ),
          label: "Playlists",
        ),
          BottomNavigationBarItem(
            icon: GestureDetector(
            onTap: () {
              onItemTapped(2);
            },
            child: Image.asset("assets/icons/favorite.png", height: 50),
          ),
            label: "Favorites",
          ),
          
          
          
        ]),
      body:  _bodySelector(currenTIndex)
          
    );
    
  }

  Widget _bodySelector(currenTIndex) {
    switch(currenTIndex){
      case 1: return const PlaylistScreen();
    }
    return _home();
  }

  Widget _home() {
    return FutureBuilder<List<SongModel>>(
          future: audioQuery.querySongs(
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
                        await player.setAudioSource(
                            createPlaylist(item.data!),
                            initialIndex: index);
                            nowPlaying = index;
                            //print(index);
                        changePlayingState();
                        await player.play();
                        changePlayerVisibility();
                      } else {
                        // show the player and start the audio only if it's not already playing
                        changePlayerVisibility();
                        if (isItPlaying) {
                          if(index != nowPlaying)
                          {
                            await player.setAudioSource(
                            createPlaylist(item.data!),
                            initialIndex: index);
                            nowPlaying = index;
                            await player.play();
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




 
  
  void requestStoragePermission() async {
    //only if the platform is not web, web have no permissions
    if(!kIsWeb){
      bool permissionStatus = await audioQuery.permissionsStatus();
      if(!permissionStatus){
        await audioQuery.permissionsRequest();
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




