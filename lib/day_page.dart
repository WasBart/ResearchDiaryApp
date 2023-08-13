import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

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

  /*Future<File> get _localFile async {
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
  } */
}

class EntryCard {
  int listId;
  String dbId;
  String text;
  TextField tF;
  ElevatedButton dButton;

  EntryCard({required int this.listId, required String this.dbId, required String this.text, required TextField this.tF, required ElevatedButton this.dButton});

  void removeFromList(List targetList) {
    targetList.removeAt(listId);
  }

  void deleteFromDatabase() {

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
  ElevatedButton playButton = ElevatedButton(onPressed: () {}, child: const Icon(Icons.play_arrow)); //TODO: make button actually play the corresponding audio file
  ElevatedButton deleteButton = ElevatedButton(onPressed: () {}, child: const Icon(Icons.delete));
  var _controllerText = TextEditingController();
  String titleDate = "";


  @override
  void initState() {
    super.initState();
    fillCreatedEntriesList();
    print(widget.assignedEntriesList);
    titleDate = getTitleDate();
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

  /*Future<File> _incrementCounter() {
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
    //return widget.storage.writeToFile(myController.text);
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Day: $titleDate'),
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

  String getTitleDate() {
    print(widget.assignedEntriesList[0]["date"]);
    
    String fullDate = widget.assignedEntriesList[0]["date"];
    String shortDate = fullDate.substring(0, fullDate.indexOf("T"));
    return shortDate;
  }

  void fillCreatedEntriesList() {
    // TODO: fill list with textentries + delete button and voice entries + play and delete button
    // TODO: replace controller with a different solution, otherwise all entries will have the same text
    /*for(int i = 0; i < 25; i++)
    {
      _controllerText.text = "Test Text $i";
      createdEntries.add(TextField(enabled: false, controller: _controllerText));
      createdEntries.add(deleteButton);
    }*/
    int listIndex = 0;

    for(int i = 0; i < widget.assignedEntriesList.length; i++) {
      TextField tf = TextField(enabled: false, controller: TextEditingController(text: widget.assignedEntriesList[i]["text"]));
      createdEntries.add(tf);
      ElevatedButton dButton = ElevatedButton(onPressed: () => {handleDeleteDialog(widget.assignedEntriesList[i]["text"], i, widget.assignedEntriesList[i]["id"])}, child: const Icon(Icons.delete));
      createdEntries.add(dButton);
    }

    /*widget.assignedEntriesList.forEach((element) { 
      TextField tf = TextField(enabled: false, controller: TextEditingController(text: element["text"]));
      createdEntries.add(tf);
      ElevatedButton dButton = ElevatedButton(onPressed: () => {deleteEntry(listIndex, element["id"])}, child: const Icon(Icons.delete));
      createdEntries.add(dButton);
      //EntryCard ec = EntryCard(listId: listIndex, dbId: element["id"], text: element["text"], tF: tf, dButton: dButton);
      listIndex++; // TODO: Implement delete button to delete previous text entry from local list and database
      // TODO: Add confirmation text box for delete
    // TODO: add audio entry widgets (possibly as disabled textfield saying "audio entry x") with play button and delete button
    });*/
  }

  void handleDeleteDialog(String entryText, int listIndex, int entryId) {
    List<Widget> deleteActions = [TextButton(
        child: Text("Cancel"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      TextButton(
        child: Text("Confirm", style:TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          deleteEntry(listIndex, entryId);
          Navigator.of(context).pop();
        },
      )];
    showCustomDialog(context, "Delete Entry?", "Are you sure you want to delete this entry: \"$entryText\"", deleteActions);
  }

  void deleteEntry(int listIndex, int entryId) {
    // TODO: show alert "are you sure you want to delete this entry?"
    // TODO: also delete in backend
    print("list index: $listIndex");
    widget.assignedEntriesList.removeAt(listIndex);
    deleteEntryFromDb(entryId);
    setState(() {
      createdEntries = [];  
    });
    fillCreatedEntriesList();
  }

  void deleteEntryFromDb(int entryId) async {
    http.Response response = await http.delete(Uri.parse("http://83.229.85.185/text_notes/$entryId"), headers: <String, String>{
          'x-token': '123' // TODO: change to actual id
        });
        print("statusCode: "  + response.statusCode.toString());
        // TODO: status code überprüfen ob 200 sonst error message und error handling
  }
}
