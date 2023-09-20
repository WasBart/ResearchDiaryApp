import 'package:flutter/material.dart';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';

import 'package:research_diary_app/services.dart';
import 'package:research_diary_app/util.dart';

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

  @override
  void initState() {
    super.initState();

    player.onPlayerStateChanged.listen((PlayerState newState) {
      setState(() {
        state = newState;
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: TextField(
              enabled: false,
              controller: TextEditingController(text: widget.title)),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: IconButton(
                  onPressed: () => {
                        state == PlayerState.playing
                            ? pauseAudio()
                            : playAudio()
                      },
                  icon: state == PlayerState.playing
                      ? const Icon(Icons.pause)
                      : const Icon(Icons.play_arrow)),
            ),
            Flexible(
                fit: FlexFit.loose,
                child: IconButton(
                    onPressed: deleteVoiceNote, icon: Icon(Icons.delete)))
          ],
        ),
      ],
    );
  }

  void playAudio() async {
    if (widget.locationType == LocationType.serverBased && !loaded) {
      if (widget.dbId != null) {
        // Load file from server in path variable
        widget.path = await getVoiceNoteFromServer(widget.dbId!);
      }
      loaded = true;
    }

    Source curSource = getSource();
    await player.play(curSource);
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
}
