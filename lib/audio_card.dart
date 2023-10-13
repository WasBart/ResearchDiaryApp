import 'package:flutter/material.dart';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';

import 'package:research_diary_app/services.dart';
import 'package:research_diary_app/styles.dart';
import 'package:research_diary_app/util.dart';

//TODO: add delete button in the upper right corner

enum LocationType { assets, local, serverBased }

class AudioCard extends StatefulWidget {
  String title;
  LocationType locationType;
  var path;
  int? dbId;

  final VoidCallback? onDeleted;

  @override
  _AudioCardState createState() => _AudioCardState();

  AudioCard(this.title, this.locationType,
      {this.path, this.dbId, this.onDeleted});
}

class _AudioCardState extends State<AudioCard> {
  AudioPlayer player = AudioPlayer();
  PlayerState state = PlayerState.paused;
  bool loaded = false;
  int timeProgress = 0;
  int audioDuration = 0;
  late Source audioSource;

  Widget slider() {
    return Container(
        width: 300,
        height: 20,
        child: Slider.adaptive(
            value: (timeProgress / 1000).floorToDouble(),
            max: (audioDuration / 1000).floorToDouble(),
            onChanged: (value) {
              seekToSec(value.toInt());
            }));
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      Duration? duration = await getDuration();
      audioDuration = duration!.inMilliseconds;
    });

    player.onPlayerStateChanged.listen((PlayerState newState) {
      setState(() {
        state = newState;
      });
    });

    player.onPositionChanged.listen((Duration duration) async {
      setState(() {
        timeProgress = duration.inMilliseconds;
        print("NewDuration: $duration");
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    player.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return mainContainer(
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                  ),
                ),
                SizedBox(width: 60),
                Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        icon: Icon(Icons.delete), onPressed: deleteVoiceNote))
              ],
            ),
            IconButton(
              icon: Icon(state == PlayerState.playing
                  ? Icons.pause
                  : Icons.play_arrow),
              onPressed: () {
                state == PlayerState.playing ? pauseAudio() : playAudio();
              },
              color: const Color(0xff212435),
              iconSize: 24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Text(
                    getTimeString(timeProgress),
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                  ),
                ),
                Expanded(child: slider()),
                Expanded(
                  child: Text(
                    getTimeString(audioDuration),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Duration?> getDuration() async {
    if (widget.locationType == LocationType.serverBased && !loaded) {
      if (widget.dbId != null) {
        // Load file from server in path variable
        widget.path = await getVoiceNoteFromServer(widget.dbId!);
      }
      loaded = true;
    }

    audioSource = getSource();
    await player.setSource(audioSource);
    Duration? duration = await player.getDuration();
    return duration;
  }

  String getTimeString(int milliseconds) {
    if (milliseconds == null) milliseconds = 0;
    String minutes =
        '${(milliseconds / 60000).floor() < 10 ? 0 : ''}${(milliseconds / 60000).floor()}';
    String seconds =
        '${(milliseconds / 1000).floor() % 60 < 10 ? 0 : ''}${(milliseconds / 1000).floor() % 60}';
    return '$minutes:$seconds';
  }

  void playAudio() async {
    await player.play(audioSource);
  }

  void pauseAudio() async {
    await player.pause();
  }

  Source getSource() {
    LocationType locationType = widget.locationType;
    if (locationType == LocationType.assets) {
      return AssetSource(widget.path);
    } else if (locationType == LocationType.local) {
      return DeviceFileSource(widget.path);
    } else {
      return BytesSource(widget.path);
    }
  }

  void deleteVoiceNote() async {
    List<Widget> deleteActions = [
      TextButton(
        child: Text("Cancel"),
        onPressed: () {
          Navigator.of(this.context).pop();
          return;
        },
      ),
      TextButton(
        child: Text("Confirm", style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () async {
          Navigator.of(this.context).pop();
          widget.onDeleted!();
          if (widget.locationType == LocationType.serverBased) {
            await deleteVoiceNoteFromServer(widget.dbId!);
          } else if (widget.locationType == LocationType.local) {
            await File(widget.path!).delete();
          }
        },
      )
    ];

    showCustomDialog(
        this.context,
        "Delete Entry?",
        "Are you sure you want to delete this entry: \"${widget.title}\"",
        deleteActions);
  }

  void seekToSec(int sec) {
    Duration newPosition = Duration(seconds: sec);
    player.seek(newPosition);
  }
}
