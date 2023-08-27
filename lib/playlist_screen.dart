import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
    onTap: () {
      addSongToPlaylist();
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 5)
      ),
      child: const Row(children: [
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
}


  void addSongToPlaylist() {
  // TODO: Add logic to add song to playlist
  Fluttertoast.showToast(msg:"song added to playlist");
}

  