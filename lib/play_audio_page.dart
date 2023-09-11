import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlayAudioPage extends StatefulWidget {
  const PlayAudioPage({Key? key}) : super(key: key);

  @override
  State<PlayAudioPage> createState() => _PlayAudioPageState();
}

class _PlayAudioPageState extends State<PlayAudioPage> {
  final player = AudioPlayer();
  int timeProgress = 0;
  int audioDuration = 0;

  Widget slider() {
    return Container(width: 300, child: Slider.adaptive(value: (timeProgress/1000).floorToDouble(), max: (audioDuration/1000.floorToDouble()), onChanged: (value) {
      seekToSec(value.toInt());
    }));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(
      alignment: Alignment.center,
      child: IconButton(onPressed: _PlayAudio, icon: Icon(Icons.play_arrow))
    ));
  }

  void _PlayAudio() async {
    await player.play(AssetSource("marvinsroom.mp3"), volume: 50.0);

  }
  
  void seekToSec(int sec) {
    Duration newPosition = Duration(seconds: sec);
    player.seek(newPosition);
  }
}