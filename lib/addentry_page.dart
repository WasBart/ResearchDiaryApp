import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:research_diary_app/styles.dart';
import 'package:research_diary_app/util.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'dart:async';

import 'package:research_diary_app/services.dart';
import 'package:research_diary_app/temp_audio_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const List<String> dropdownList = <String>['Text', 'Audio'];

class AddEntryPage extends StatefulWidget {
  const AddEntryPage({Key? key}) : super(key: key);

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
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
  TextField titleTextField = const TextField();
  TextField thoughtsTextField = const TextField();
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
    Future.delayed(Duration.zero, () {
      setState(() {
        thoughtsTextField = TextField(
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: AppLocalizations.of(context)!.textFieldText,
                hintStyle: const TextStyle(fontWeight: FontWeight.bold)),
            controller: textController);
        titleTextField = TextField(
            decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: AppLocalizations.of(context)!.addTitleText,
                hintStyle: const TextStyle(fontWeight: FontWeight.bold)),
            controller: titleController);
        inputWidgets.add(thoughtsTextField);
      });
    });

    _initialiseController();

    recordWaveform = AudioWaveforms(
      size: const Size(120, 60),
      recorderController: recorderController,
      waveStyle: const WaveStyle(
        spacing: 8.0,
        showBottom: false,
        extendWaveform: true,
        showMiddleLine: false,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: const Color.fromARGB(255, 228, 225, 236),
      ),
      padding: const EdgeInsets.only(left: 18),
      margin: const EdgeInsets.symmetric(horizontal: 15),
    );

    playWaveform = AudioFileWaveforms(
      size: const Size(120, 60),
      enableSeekGesture: true,
      playerController: playerController,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: const Color.fromARGB(255, 228, 225, 236),
      ),
      playerWaveStyle: const PlayerWaveStyle(
        scaleFactor: 0.8,
        fixedWaveColor: Colors.white30,
        liveWaveColor: Colors.white,
        waveCap: StrokeCap.butt,
      ),
    );

    recordOrStopButton = IconButton(
        icon: const Icon(Icons.mic),
        tooltip: 'Start recording',
        onPressed: _startRecording);
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
    audioPlayer.dispose();
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
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(AppLocalizations.of(context)!.addEntryPageTitle),
        ),
        body: Column(
          children: [
            Container(
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
                          dateController,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.calendar_today),
                          labelText: AppLocalizations.of(context)!.datePickerText,
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold)
                          ),
                      readOnly: true,
                      onTap: () async {
                        pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(
                                2000),
                            lastDate: DateTime(2101));
                        if (pickedDate != null) {
                          debugPrint(pickedDate
                              .toString());

                          setState(() {
                            dateController.text = formatDate(
                                pickedDate!);
                          });
                        } else {
                          debugPrint("Date is not selected");
                        }
                      }),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.typeHeaderText),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        underline: Container(
                          height: 2,
                        ),
                        onChanged: (String? value) {
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
                            child: Text(value,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (Widget widget in inputWidgets) widget,
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: confirmEntry,
                      child: Text(AppLocalizations.of(context)!.confirmButtonText,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          Center(child: Text(AppLocalizations.of(context)!.studyPrompt, textAlign: TextAlign.center))],
        ),
        floatingActionButton: helpButton(context: context),
      ),
    );
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
          icon: const Icon(Icons.stop),
          tooltip: 'Stop recording',
          onPressed: _stopRecording);
      inputWidgets.removeLast();
      inputWidgets.add(recordOrStopButton);
    });
  }

  void _stopRecording() async {
    path = await recorderController.stop();
    playerController.preparePlayer(path: path!);
    recordOrStopButton =
        IconButton(onPressed: playSound, icon: const Icon(Icons.play_arrow));
    setState(() {
      inputWidgets.removeLast();
      inputWidgets.add(
        TempAudioCard(
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
    List<Widget> confirmActions = [
      TextButton(
        child: const Text("OK"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      )
    ];
    if (textOrAudio == 'Text') {
      if (pickedDate == null && textController.text == "") {
        showCustomDialog(
            context,
            "Error",
            AppLocalizations.of(context)!.dateAndTextMissingText,
            confirmActions);
      } else if (textController.text == "") {
        showCustomDialog(context, "Error",
            AppLocalizations.of(context)!.textMissingText, confirmActions);
      } else if (pickedDate == null) {
        showCustomDialog(context, "Error",
            AppLocalizations.of(context)!.dateMissingText, confirmActions);
      } else if (titleController.text == "") {
        showCustomDialog(context, "Error",
            AppLocalizations.of(context)!.titleMissingText, confirmActions);
      } else {
        try {
          http.Response response = await postTextNoteToServer(
                  textController.text,
                  titleController.text,
                  pickedDate.toString())
              .timeout(const Duration(seconds: 3));
          if (response.statusCode == 200) {
            showCustomDialog(
                context,
                AppLocalizations.of(context)!.entrySavedTitleText,
                AppLocalizations.of(context)!.entrySavedText,
                confirmActions);
          }
        } on TimeoutException catch (e) {
          showCustomDialog(context, AppLocalizations.of(context)!.timeoutTitle, AppLocalizations.of(context)!.timeoutText, confirmActions);
        } on Error catch (e) {
          print('Error: $e');
        }
      }
    } else if (textOrAudio == 'Audio') {
      // TODO: delete local audio file
      if (pickedDate == null) {
        showCustomDialog(context, "Error",
            AppLocalizations.of(context)!.dateMissingText, confirmActions);
      } else if (titleController.text == "") {
        showCustomDialog(context, "Error",
            AppLocalizations.of(context)!.titleMissingText, confirmActions);
      } else if (path == null) {
        showCustomDialog(context, "Error",
            AppLocalizations.of(context)!.voiceNoteMissingText, confirmActions);
      } else {
        try {
          await postVoiceNoteToServer(
              path!, titleController.text, pickedDate.toString()).timeout(const Duration(seconds: 3));
          showCustomDialog(
              context,
              AppLocalizations.of(context)!.entrySavedTitleText,
              AppLocalizations.of(context)!.entrySavedText,
              confirmActions);
        } on TimeoutException catch (e) {
          showCustomDialog(context, AppLocalizations.of(context)!.timeoutTitle, AppLocalizations.of(context)!.timeoutText, confirmActions);
        } on Error catch (e) {
          print('Error: $e');
        }
      }
    }
  }
}
