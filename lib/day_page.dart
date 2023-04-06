import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:learningdart/util.dart';

// TODO: insert scrollable view for if there are too many textfields and voice recordings
// TODO: insert an additional textfield anytime text is entered and the confirm button is pressed
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

  @override
  void initState() {
    super.initState();
    widget.storage.readFromFile().then((value) {
      setState(() {
        //_counter = value;
      });
    });
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
      body: Column(children: [
        TextField(
          decoration: InputDecoration(
              border: OutlineInputBorder(), hintText: 'Enter your thoughts'),
          controller: myController,
        ),
        ElevatedButton(
            onPressed: _incrementCounter,
            child: const Text('Save new text entry')),
        const Icon(Icons.mic_none_outlined),
      ]),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            debugPrint('Floating Action Button');
          },
          child: const Icon(Icons.help_outline)),
    );
  }
}
