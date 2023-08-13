import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:research_diary_app/util.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

const List<String> dropdownList = <String>['Text', 'Audio'];

class AddEntryPageSound extends StatefulWidget {
  const AddEntryPageSound({Key? key}) : super(key: key);

  @override
  State<AddEntryPageSound> createState() => _AddEntryPageSoundState();
}

class _AddEntryPageSoundState extends State<AddEntryPageSound> {
  int currentPage = 0;
  var dateController = TextEditingController();
  var textController = TextEditingController();
  var dropdownValue = dropdownList.first;
  List<Widget> inputWidgets = [];
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;
  String? textOrAudio = "Text";
  DateTime? pickedDate;
  String? inputText;
  TextField thoughtsTextField = TextField();

  @override
  void initState() {
    super.initState();
    thoughtsTextField = TextField(
        decoration: InputDecoration(
            border: OutlineInputBorder(), hintText: 'Enter your thoughts'),
        controller: textController);
    inputWidgets.add(thoughtsTextField);

    initRecorder();
  }

  @override
  void dispose() {
    recorder.closeAudioSession();
    dateController.dispose();
    textController.dispose();

    super.dispose();
  }

  Future initRecorder() async {
    final micStatus = await Permission.microphone.request();
    final storageStatus = await Permission.storage.request();
    final manageStorageStatus =
        await Permission.manageExternalStorage.request();

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
                pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(), //get today's date
                    firstDate: DateTime(
                        2000), //DateTime.now() - not to allow to choose before today.
                    lastDate: DateTime(2101));
                if (pickedDate != null) {
                  debugPrint(pickedDate
                      .toString()); //get the picked date in the format => 2022-07-04 00:00:00.000
                  //String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
                  //print(formattedDate); //formatted date output using intl package =>  2022-07-04
                  //You can format date as per your need

                  setState(() {
                    dateController.text = formatDate(
                        pickedDate!); //set foratted date to TextField value.
                  });
                } else {
                  debugPrint("Date is not selected");
                } //when click we have to show the datepicker
              }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text('Type:'),
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
                    textOrAudio = value;
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
          ElevatedButton(onPressed: confirmEntry, child: const Text('Confirm')),
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

    await recorder.startRecorder(toFile: '/sdcard/Download/test.wav');
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
      inputWidgets.add(thoughtsTextField);
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

  void confirmEntry() async {
    // TODO: make api call to post entry for specific device id
    List<Widget> confirmActions = [
      TextButton(
        child: Text("OK"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      )
    ];
    if (textOrAudio == 'Text') {
      //http.post()
      if (pickedDate == null && textController.text == "") {
        showCustomDialog(context, "Error",
            "Please select a date and enter some text.", confirmActions);
      } else if (textController.text == "") {
        showCustomDialog(context, "Error", "Please enter some text.", confirmActions);
      } else if (pickedDate == null) {
        showCustomDialog(context, "Error", "Please select a date.", confirmActions);
      } else {
        String? id = await _getId();
        http.Response response = await http.put(
            Uri.parse("http://83.229.85.185/text_notes/"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'x-token': '123' // TODO: change to actual ID
            },
            body: jsonEncode(<String, String>{'text': textController.text,
            'date': pickedDate.toString()}));
        print("statusCode: " + response.statusCode.toString());
        // TODO: status code überprüfen ob 200 sonst error message und error handling
        print("Body: " + response.body);
        showCustomDialog(
            context, "Entry saved", "Your entry has been saved.", confirmActions);
      }
    } else if (textOrAudio == 'Audio') {
      if (pickedDate == null) {
        showCustomDialog(context, "Error", "Please select a date.", confirmActions);
      }
    }
    //showCustomDialog(context, "Entry saved", "Your entry has been saved.", "OK");
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id; // unique ID on Android
    }
  }
}
