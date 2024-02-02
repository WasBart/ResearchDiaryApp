import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:research_diary_app/globals.dart';
import 'package:research_diary_app/audio_card.dart';
import 'package:research_diary_app/styles.dart';
import 'package:research_diary_app/text_card.dart';
import 'package:research_diary_app/services.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:research_diary_app/util.dart';
import 'package:audioplayers/audioplayers.dart';

// TODO: insert scrollable view for if there are too many textfields and voice recording
// TODO: set the date in the appbar with the date of the day, load all files that correspond to the same date
// TODO: once an entry for a day has been made, create an entry for the day in the overview page

class DiaryEntryStorage {
  String filename;

  DiaryEntryStorage({required String this.filename});

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    debugPrint(directory.path);
    return directory.path;
  }
}

class DayPage extends StatefulWidget {
  const DayPage({super.key, required this.assignedEntriesList});

  final List<Map> assignedEntriesList;

  @override
  State<DayPage> createState() => _DayPageState();
}

class _DayPageState extends State<DayPage> {
  DateTime curDate = DateTime.now();
  var entryList = [];
  final myController = TextEditingController();
  List<Widget> entryWidgets = [];
  List<Widget> createdEntries = [];
  ElevatedButton playButton = ElevatedButton(
      onPressed: () {},
      child: const Icon(Icons
          .play_arrow)); //TODO: make button actually play the corresponding audio file
  ElevatedButton deleteButton =
      ElevatedButton(onPressed: () {}, child: const Icon(Icons.delete));
  var _controllerText = TextEditingController();
  String titleDate = "";

  List<AudioPlayer> audioPlayers = [];
  List<PlayerState> playerStates = [];

  List<Widget> entryCards = [];

  @override
  void initState() {
    super.initState();
    fillCreatedEntriesList();
    print(widget.assignedEntriesList);
    titleDate = getTitleDate();
  }

  @override
  void dispose() {
    super.dispose();
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    for (AudioPlayer ap in audioPlayers) {
      ap.dispose();
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Day: $titleDate'),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: entryCards.length,
              itemBuilder: (BuildContext context, int index) {
                return entryCards[index];
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            ))
          ]),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            debugPrint('Floating Action Button');
          },
          child: const Icon(Icons.help_outline)),
    );
  }

  String getTitleDate() {
    print(widget.assignedEntriesList[0]["date"]);

    String fullDate = widget.assignedEntriesList[0]["date"];
    String shortDate = fullDate.substring(0, fullDate.indexOf("T"));
    return shortDate;
  }

  void fillCreatedEntriesList() {
    // TODO: fill list with textentries + delete button and voice entries + play and delete button
    // TODO: replace controller with a different solution, otherwise all entries will have the same text
    int listIndex = 0;
    int voiceNoteIndex = 1;

    for (int i = 0; i < widget.assignedEntriesList.length; i++) {
      var currentText = widget.assignedEntriesList[i]["text"];
      print(currentText);
      print(widget.assignedEntriesList[i]);
      List<Widget> temp = [];
      if (currentText == null) {
        int currentId = widget.assignedEntriesList[i]["id"];

        entryCards.add(AudioCard(
            "Voice Note $voiceNoteIndex", LocationType.serverBased,
            dbId: currentId, onDeleted: () => {
              deleteCardFromList(i)
            },));
        voiceNoteIndex++;
      } else {
        TextField tf = TextField(
            enabled: true,
            controller: TextEditingController(
                text: widget.assignedEntriesList[i]["text"]));
        createdEntries.add(tf);
        ElevatedButton dButton = ElevatedButton(
            onPressed: () => {
                  handleDeleteDialog(widget.assignedEntriesList[i]["text"], i,
                      widget.assignedEntriesList[i]["id"])
                },
            child: const Icon(Icons.delete));
        createdEntries.add(dButton);

        entryCards.add(TextCard(widget.assignedEntriesList[i]["text"], widget.assignedEntriesList[i]["id"], onDeleted: () => {
          deleteCardFromList(i)
        }));
      }
    }
  }

  void handleDeleteDialog(String entryText, int listIndex, int entryId) {
    List<Widget> deleteActions = [
      TextButton(
        child: const Text("Cancel"),
        onPressed: () {
          Navigator.of(this.context).pop();
        },
      ),
      TextButton(
        child: const Text("Confirm", style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          deleteEntry(listIndex, entryId);
          Navigator.of(this.context).pop();
        },
      )
    ];
    showCustomDialog(
        this.context,
        "Delete Entry?",
        "Are you sure you want to delete this entry: \"$entryText\"",
        deleteActions);
  }

  void deleteCardFromList(int listId) {
    widget.assignedEntriesList.removeAt(listId);
    setState(() {
      createdEntries = [];
      entryCards = [];
    });
    fillCreatedEntriesList();
  }

  void deleteEntry(int listIndex, int entryId) {
    // TODO: show alert "are you sure you want to delete this entry?"
    print("list index: $listIndex");
    widget.assignedEntriesList.removeAt(listIndex);
    deleteTextNoteFromServer(entryId);
    setState(() {
      createdEntries = [];
    });
    fillCreatedEntriesList();
  }
}
