import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:research_diary_app/util.dart';

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

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$filename.txt');
  }

  Future<String> readFromFile() async {
    final file = await _localFile;

    // Read the file
    final contents = await file.readAsString();

    return contents;
  }

  Future<File> writeToFile(String text) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$text\n', mode: FileMode.append);
  }
}

class DayPage extends StatefulWidget {
  const DayPage({super.key, required this.storage});

  final DiaryEntryStorage storage;

  @override
  State<DayPage> createState() => _DayPageState();
}

class _DayPageState extends State<DayPage> {
  DateTime curDate = DateTime.now();
  var entryList = [];
  final myController = TextEditingController();
  List<Widget> entryWidgets = [];
  List<Widget> createdEntries = [];
  ElevatedButton playButton = ElevatedButton(onPressed: () {}, child: const Icon(Icons.play_arrow)); //TODO: make button actually play the corresponding audio file
  ElevatedButton deleteButton = ElevatedButton(onPressed: () {}, child: const Icon(Icons.delete));
  var _controllerText = TextEditingController();

  @override
  void initState() {
    super.initState();
    fillCreatedEntriesList();
    /*widget.storage.readFromFile().then((value) {
      setState(() {
        //_counter = value;
      });
    });*/
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  Future<File> _incrementCounter() {
    setState(() {});

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // Retrieve the text that the user has entered by using the
          // TextEditingController.
          content: Text(myController.text),
        );
      },
    );

    // Write the variable as a string to the file.
    return widget.storage.writeToFile(myController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Day: ${widget.storage.filename}'),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListView(
                children: createdEntries,
              ),
            )
          ]),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            debugPrint('Floating Action Button');
          },
          child: const Icon(Icons.help_outline)),
    );
  }

  void fillCreatedEntriesList() {
    // TODO: fill list with textentries + delete button and voice entries + play and delete button
    // TODO: replace controller with a different solution, otherwise all entries will have the same text
    for(int i = 0; i < 25; i++)
    {
      _controllerText.text = "Test Text $i";
      createdEntries.add(TextField(enabled: false, controller: _controllerText));
      createdEntries.add(deleteButton);
    }
    // TODO: add audio entry widgets (possibly as disabled textfield saying "audio entry x") with play button and delete button
  }

  void deleteEntry(int entryIndex) {
    // TODO: show alert "are you sure you want to delete this entry?"
    // TODO: also delete in backend
    createdEntries.removeAt(entryIndex);
  }
}
