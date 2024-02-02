import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:research_diary_app/styles.dart';
import 'package:research_diary_app/util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart' as ap;

import 'package:research_diary_app/globals.dart';
import 'package:research_diary_app/services.dart';
import 'package:research_diary_app/styles.dart';
import 'package:research_diary_app/audio_card.dart';
//import 'package:audioplayers/audio_cache.dart';

// TODO: add researcher voice notes as assets in pubspec file
// TODO: delete local voice note file when uploaded or cancelled

const List<String> dropdownList = <String>['Text', 'Audio'];

class AddEntryPageWave extends StatefulWidget {
  const AddEntryPageWave({Key? key}) : super(key: key);

  @override
  State<AddEntryPageWave> createState() => _AddEntryPageWaveState();
}

class _AddEntryPageWaveState extends State<AddEntryPageWave> {
  int currentPage = 0;
  var dateController = TextEditingController();
  var textController = TextEditingController();
  var titleController = TextEditingController();
  var dropdownValue = dropdownList.first;
  List<Widget> inputWidgets = [];
  bool isRecorderReady = false;
  String? textOrAudio = "Text";
  DateTime? pickedDate;
  String? inputText;
  TextField titleTextField = TextField();
  TextField thoughtsTextField = TextField();
  late IconButton recordOrStopButton;

  late AudioWaveforms recordWaveform;
  late AudioFileWaveforms playWaveform;

  // Waveform specific
  late final RecorderController recorderController;
  late final PlayerController playerController;

  String? path;
  String? musicFile;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  late Directory appDirectory;

  ap.AudioPlayer audioPlayer = ap.AudioPlayer();
  ap.PlayerState audioPlayerState = ap.PlayerState.paused;
  ap.AudioCache ac = ap.AudioCache();

  @override
  void initState() {
    super.initState();
    thoughtsTextField = TextField(
        keyboardType: TextInputType.multiline,
        minLines: 1,
        maxLines: 3,
        decoration: InputDecoration(
            border: OutlineInputBorder(), hintText: 'Enter your thoughts', hintStyle: TextStyle(fontWeight: FontWeight.bold)),
        controller: textController);
    titleTextField = TextField(decoration: InputDecoration(
            border: OutlineInputBorder(), hintText: 'Title', hintStyle: TextStyle(fontWeight: FontWeight.bold)),
        controller: titleController);
    inputWidgets.add(thoughtsTextField);

    _initialiseController();

    recordWaveform = AudioWaveforms(
      size: Size(120, 60),
      recorderController: recorderController,
      waveStyle: WaveStyle(
        spacing: 8.0,
        showBottom: false,
        extendWaveform: true,
        showMiddleLine: false,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Color.fromARGB(255, 228, 225, 236),
      ),
      padding: const EdgeInsets.only(left: 18),
      margin: const EdgeInsets.symmetric(horizontal: 15),
    );

    playWaveform = AudioFileWaveforms(
      size: Size(120, 60),
      enableSeekGesture: true,
      playerController: playerController,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Color.fromARGB(255, 228, 225, 236),
      ),
      playerWaveStyle: const PlayerWaveStyle(
        scaleFactor: 0.8,
        fixedWaveColor: Colors.white30,
        liveWaveColor: Colors.white,
        waveCap: StrokeCap.butt,
      ),
    );

    recordOrStopButton = IconButton(
        icon: Icon(Icons.mic),
        tooltip: 'Start recording',
        onPressed: _startRecording);

    //audioCache = AudioCache(fixedPlayer: audioPlayer);
    audioPlayer.onPlayerStateChanged.listen((ap.PlayerState state) {
      audioPlayerState = state;
      setState(() {
        recordOrStopButton = IconButton(
            icon: audioPlayerState == ap.PlayerState.playing
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
            tooltip: 'Play/Pause recording',
            onPressed: () {
              audioPlayerState == ap.PlayerState.playing
                  ? pauseSound()
                  : playSound();
            });
        inputWidgets.removeLast();
        inputWidgets.add(recordOrStopButton);
      });
    });
  }

  void _initialiseController() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100
      ..bitRate = 48000;

    playerController = PlayerController();
  }

  @override
  void dispose() {
    super.dispose();

    dateController.dispose();
    textController.dispose();

    recorderController.dispose();
    playerController.dispose();

    //audioPlayer.release();
    audioPlayer.dispose();
    //audioCache.clearCache();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appBgColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text('Add New Entry'),
        ),
        body: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          width: 400,
          height: 500,
          decoration: BoxDecoration(
            color: appBgColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
          ),
          child: Column(
            children: [
              titleTextField,
              TextField(
                  controller:
                      dateController, //editing controller of this TextField
                  decoration: const InputDecoration(
                      icon: Icon(Icons.calendar_today), //icon of text field
                      labelText: "Enter Date", labelStyle: TextStyle(fontWeight: FontWeight.bold) //label text of field
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
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('Type:'),
                  const SizedBox(width: 10),
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
                    items: dropdownList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 10),
              for (Widget widget in inputWidgets) widget,
              SizedBox(height: 10),
              ElevatedButton(
                  onPressed: confirmEntry, child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            debugPrint('Floating Action Button');
          },
          child: const Icon(Icons.help_outline),
        ),
      ),
    );
  }

  void deleteFile(String path) {
    // TODO: implement. used when audio files are not confirmed with confirm button, but deleted instead.
  }

  void createInputFields(String? selectedInputMode) {
    inputWidgets.clear();
    if (selectedInputMode == 'Text') {
      inputWidgets.add(thoughtsTextField);
    } else if (selectedInputMode == 'Audio') {
      inputWidgets.add(recordWaveform);
      inputWidgets.add(recordOrStopButton);
    }
  }

  void _startRecording() async {
    await recorderController.record();
    setState(() {
      recordOrStopButton = IconButton(
          icon: Icon(Icons.stop),
          tooltip: 'Stop recording',
          onPressed: _stopRecording);
      inputWidgets.removeLast();
      inputWidgets.add(recordOrStopButton);
    });
  }

  void _stopRecording() async {
    path = await recorderController.stop();
    playerController.preparePlayer(path: path!);
    print("playerstate: $audioPlayerState");
    recordOrStopButton =
        IconButton(onPressed: playSound, icon: const Icon(Icons.play_arrow));
    setState(() {
      inputWidgets.removeLast();
      //inputWidgets.add(recordOrStopButton);
      inputWidgets.add(
        AudioCard(
          "Voice Note",
          LocationType.local,
          path: path,
          onDeleted: () => setState(
            () {
              inputWidgets.removeLast();
            },
          ),
        ),
      );
    });
  }

  void playSound() async {
    await audioPlayer.play(ap.DeviceFileSource(path!));
  }

  void pauseSound() async {
    await audioPlayer.pause();
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
        showCustomDialog(
            context, "Error", "Please enter some text.", confirmActions);
      } else if (pickedDate == null) {
        showCustomDialog(
            context, "Error", "Please select a date.", confirmActions);
      } else {
        http.Response response = await postTextNoteToServer(
            textController.text, pickedDate.toString());
        print("statusCode: " + response.statusCode.toString());
        // TODO: status code überprüfen ob 200 sonst error message und error handling
        print("Body: " + response.body);
        showCustomDialog(context, "Entry saved", "Your entry has been saved.",
            confirmActions);
      }
    } else if (textOrAudio == 'Audio') {
      // TODO: delete local audio file
      if (pickedDate == null) {
        showCustomDialog(
            context, "Error", "Please select a date.", confirmActions);
      } else if (path == null) {
        showCustomDialog(
            context, "Error", "Please record a voice note", confirmActions);
      } else {
        await postVoiceNoteToServer(path!, pickedDate.toString());
        showCustomDialog(context, "Entry saved",
            "Your sound entry has been saved.", confirmActions);
      }
    }
    //showCustomDialog(context, "Entry saved", "Your entry has been saved.", "OK");
  }
}
