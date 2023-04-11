import 'package:flutter/material.dart';
import 'dart:io';
import 'package:research_diary_app/util.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

const List<String> dropdownList = <String>['Text', 'Audio'];

class AddEntryPageSound extends StatefulWidget {
  const AddEntryPageSound({Key? key}) : super(key: key);

  @override
  State<AddEntryPageSound> createState() => _AddEntryPageSoundState();
}

class _AddEntryPageSoundState extends State<AddEntryPageSound> {
  int currentPage = 0;
  var dateController = TextEditingController();
  var dropdownValue = dropdownList.first;
  List<Widget> inputWidgets = [
    TextField(
      decoration: InputDecoration(
          border: OutlineInputBorder(), hintText: 'Enter your thoughts'),
    ),
  ];
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;

  @override
  void initState() {
    super.initState();

    initRecorder();
  }

  @override
  void dispose() {
    recorder.closeAudioSession();

    super.dispose();
  }

  Future initRecorder() async {
    final micStatus = await Permission.microphone.request();
    final storageStatus = await Permission.storage.request();
    final manageStorageStatus = await Permission.manageExternalStorage.request();

    if (micStatus != PermissionStatus.granted) {
      throw 'Microphone or storage permission not granted';
    }

    await recorder.openAudioSession();

    isRecorderReady = true;
    recorder.setSubscriptionDuration(
      const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Entry'),
      ),
      body: Column(
        children: [
          TextField(
              controller: dateController, //editing controller of this TextField
              decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_today), //icon of text field
                  labelText: "Enter Date" //label text of field
                  ),
              readOnly: true, // when true user cannot edit text
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(), //get today's date
                    firstDate: DateTime(
                        2000), //DateTime.now() - not to allow to choose before today.
                    lastDate: DateTime(2101));
                if (pickedDate != null) {
                  print(
                      pickedDate); //get the picked date in the format => 2022-07-04 00:00:00.000
                  //String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
                  //print(formattedDate); //formatted date output using intl package =>  2022-07-04
                  //You can format date as per your need

                  setState(() {
                    dateController.text = formatDate(
                        pickedDate); //set foratted date to TextField value.
                  });
                } else {
                  print("Date is not selected");
                } //when click we have to show the datepicker
              }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Type:'),
              DropdownButton<String>(
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                underline: Container(
                  height: 2,
                ),
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    createInputFields(value);
                    dropdownValue = value!;
                  });
                },
                items:
                    dropdownList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          for (Widget widget in inputWidgets) widget,
          ElevatedButton(onPressed: () {}, child: const Text('Confirm')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('Floating Action Button');
        },
        child: const Icon(Icons.help_outline),
      ),
    );
  }

  Future record() async {
    if (!isRecorderReady) return;

    await recorder.startRecorder(toFile: '/sdcard/Download/temp.wav');
  }

  Future stop() async {
    if (!isRecorderReady) return;

    final path = await recorder.stopRecorder();
    final audioFile = File(path!);

    print('Recorded audio: $audioFile');
    // TODO: show play button to listen to just recorded audio file. 
    // TODO: show delete button to delete just recorded audio file.
    // TODO: on confirm button, show alert "saved audio file for day: {day} with lenght {length}."
    // TODO: save audio files in separate files identified by date timestamp.
  }

  void deleteFile(String path) {
    // TODO: implement. used when audio files are not confirmed with confirm button, but deleted instead.
  }

  void createInputFields(String? selectedInputMode) {
    inputWidgets.clear();
    if (selectedInputMode == 'Text') {
      inputWidgets.add(TextField(
        decoration: InputDecoration(
            border: OutlineInputBorder(), hintText: 'Enter your thoughts'),
      ));
    } else if (selectedInputMode == 'Audio') {
      inputWidgets.add(
        StreamBuilder(
          stream: recorder.onProgress,
          builder: (context, snapshot) {
            final duration =
                snapshot.hasData ? snapshot.data!.duration : Duration.zero;
            return Text('${duration.inSeconds} s');
          },
        ),
      );
      inputWidgets.add(
        ElevatedButton(
          onPressed: () async {
            if (recorder.isRecording) {
              await stop();
            } else {
              await record();
            }

            setState(() {});
          },
          child: Icon(recorder.isRecording ? Icons.stop : Icons.mic),
        ),
      );
    }
  }
}
