import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:phantom_tunes/screen_customization.dart';
import 'package:phantom_tunes/utilis/global_variables.dart';
import 'package:fluttertoast/fluttertoast.dart';


class SongScreen extends StatelessWidget {
  const SongScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffff0505),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 56.0, right: 20.0, left: 20.0),
            decoration: const BoxDecoration(color: Color(0xffff0505)), 
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
                        stream: durationStateStream,
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
                                  player.seek(duration);
                                },
                              ),
                            ),
                          );

                        }
                        ),
                      ),


                      StreamBuilder<DurationState>(
                        stream: durationStateStream,
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
                            if(player.hasPrevious){
                              player.seekToPrevious();
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
                            if(player.playing){
                              player.pause();
                            }else{
                              if(player.currentIndex != null){
                                player.play();
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15.0),
                            margin: const EdgeInsets.only(right: 10.0, left: 10.0),
                            child: StreamBuilder<bool>(
                              stream: player.playingStream,
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
                            if(player.hasNext){
                              player.seekToNext();
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
                              player.setShuffleModeEnabled(false);
                              check = 0;
                              Fluttertoast.showToast(msg:"Shuffling disabled");
                            }
                            else{
                              player.setShuffleModeEnabled(true);
                              check = 1;
                              Fluttertoast.showToast(msg:"Shuffling enabled");
                            }
                            
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            margin:  const EdgeInsets.only(right: 30.0, left: 30.0),
                            child: StreamBuilder<bool>(
                              stream: player.shuffleModeEnabledStream,
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
                            player.loopMode == LoopMode.one ? player.setLoopMode(LoopMode.all) : player.setLoopMode(LoopMode.one);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: StreamBuilder<LoopMode>(
                              stream: player.loopModeStream,
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
}

class DurationState{
  DurationState({
      this.position = Duration.zero, this.total = Duration.zero
  });
  Duration position, total;
}