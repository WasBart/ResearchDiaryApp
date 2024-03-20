import 'package:research_diary_app/audio_card.dart';
import 'package:research_diary_app/styles.dart';
import 'package:research_diary_app/text_card.dart';
import 'package:research_diary_app/services.dart';

import 'package:flutter/material.dart';
import 'package:research_diary_app/util.dart';
import 'package:audioplayers/audioplayers.dart';

class DiaryEntryStorage {
  String filename;

  DiaryEntryStorage({required this.filename});
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
          .play_arrow));
  ElevatedButton deleteButton =
      ElevatedButton(onPressed: () {}, child: const Icon(Icons.delete));
  String titleDate = "";

  List<AudioPlayer> audioPlayers = [];
  List<PlayerState> playerStates = [];

  List<Widget> entryCards = [];

  @override
  void initState() {
    super.initState();
    fillCreatedEntriesList();
    titleDate = getTitleDate();
  }

  @override
  void dispose() {
    super.dispose();
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
                child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: entryCards.length,
              itemBuilder: (BuildContext context, int index) {
                return entryCards[index];
              },
            ))
          ]),
      floatingActionButton: helpButton(context: context)
    );
  }

  String getTitleDate() {
    String fullDate = widget.assignedEntriesList[0]["date"];
    String shortDate = fullDate.substring(0, fullDate.indexOf("T"));
    return shortDate;
  }

  void fillCreatedEntriesList() {
    int voiceNoteIndex = 1;

    for (int i = 0; i < widget.assignedEntriesList.length; i++) {
      var currentText = widget.assignedEntriesList[i]["text"];
      List<Widget> temp = [];
      if (currentText == null) {
        int currentId = widget.assignedEntriesList[i]["id"];

        entryCards.add(AudioCard(
            widget.assignedEntriesList[i]["title"], LocationType.serverBased,
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

        entryCards.add(TextCard(widget.assignedEntriesList[i]["text"], widget.assignedEntriesList[i]["title"], widget.assignedEntriesList[i]["id"], onDeleted: () => {
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
          Navigator.of(context).pop();
        },
      ),
      TextButton(
        child: const Text("Confirm", style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          deleteEntry(listIndex, entryId);
          Navigator.of(context).pop();
        },
      )
    ];
    showCustomDialog(
        context,
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
    widget.assignedEntriesList.removeAt(listIndex);
    deleteTextNoteFromServer(entryId);
    setState(() {
      createdEntries = [];
    });
    fillCreatedEntriesList();
  }
}
