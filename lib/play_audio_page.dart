import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlayAudioPage extends StatefulWidget {
  const PlayAudioPage({Key? key}) : super(key: key);

  @override
  State<PlayAudioPage> createState() => _PlayAudioPageState();
}

class _PlayAudioPageState extends State<PlayAudioPage> {
  final player = AudioPlayer();
  PlayerState state = PlayerState.paused;
  int timeProgress = 0;
  int audioDuration = 0;

  List<Widget> buttons = [];

  Widget slider() {
    return Container(
        width: 300,
        child: Slider.adaptive(
            value: (timeProgress / 1000).floorToDouble(),
            max: (audioDuration / 1000.floorToDouble()),
            onChanged: (value) {
              seekToSec(value.toInt());
            }));
  }

  @override
  void initState() {
    super.initState();

    buttons = [IconButton(
          onPressed: _PlayAudio, icon: const Icon(Icons.play_arrow))];

    player.onPlayerStateChanged.listen((PlayerState newState) {
      state = newState;
      List<Widget> tempList = [
        IconButton(
            onPressed: () => {
                  newState == PlayerState.playing ? _pauseAudio() : _PlayAudio()
                },
            icon: newState == PlayerState.playing
                ? Icon(Icons.pause)
                : Icon(Icons.play_arrow))
      ];
      setState(() {
        buttons = tempList;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget button = updatePlayButton();
    return Scaffold(
        body: Container(
            alignment: Alignment.center,
            child: Row(children: buttons)));
  }

  Widget updatePlayButton() {
    if (state == PlayerState.paused) {
      return IconButton(
          onPressed: _PlayAudio, icon: const Icon(Icons.play_arrow));
    } else {
      return IconButton(onPressed: _pauseAudio, icon: const Icon(Icons.pause));
    }
  }

  void _PlayAudio() async {
    await player.play(AssetSource("marvinsroom.mp3"), volume: 50.0);
    IconButton(onPressed: _pauseAudio, icon: const Icon(Icons.pause));
  }

  void _pauseAudio() async {
    await player.pause();
  }

  void _resumeAudio() async {
    await player.resume();
  }

  void seekToSec(int sec) {
    Duration newPosition = Duration(seconds: sec);
    player.seek(newPosition);
  }
}
