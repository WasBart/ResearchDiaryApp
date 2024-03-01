import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:research_diary_app/globals.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:research_diary_app/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// TODO: Include audio recording capabilities
// TODO: Include storage and loading capabilities

String formatDate(DateTime date) {
  return '${date.day}.${date.month}.${date.year}';
}

showCustomDialog(BuildContext context, String title, String content, List<Widget> inputActions) {

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: 
      inputActions
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
// ---- TUTORIAL STUFF ----
/*
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RecordingPage(title: 'Flutter Demo Home Page'),
    );
  }
}

*/
class RecordingPage extends StatefulWidget {
  RecordingPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _RecordingPageState createState() => _RecordingPageState();
}
class _RecordingPageState extends State<RecordingPage> {
  FlutterSoundRecorder? _recordingSession;
  final recordingPlayer = AssetsAudioPlayer();
  String? pathToAudio;
  bool _playAudio = false;
  String _timerText = '00:00:00';
  @override
  void initState() {
    super.initState();
    initializer();
  }
  void initializer() async {
    pathToAudio = '/sdcard/Download/temp.wav';
    _recordingSession = FlutterSoundRecorder();
    await _recordingSession?.openAudioSession(
        focus: AudioFocus.requestFocusAndStopOthers,
        category: SessionCategory.playAndRecord,
        mode: SessionMode.modeDefault,
        device: AudioDevice.speaker);
    await _recordingSession?.setSubscriptionDuration(Duration(milliseconds: 10));
    await initializeDateFormatting();
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(title: Text('Audio Recording and Playing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            Container(
              child: Center(
                child: Text(
                  _timerText,
                  style: TextStyle(fontSize: 70, color: Colors.red),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                createElevatedButton(
                  icon: Icons.mic,
                  iconColor: Colors.red,
                  onPressFunc: startRecording,
                ),
                SizedBox(
                  width: 30,
                ),
                createElevatedButton(
                  icon: Icons.stop,
                  iconColor: Colors.red,
                  onPressFunc: stopRecording,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(elevation: 9.0, primary: Colors.red),
              onPressed: () {
                setState(() {
                  _playAudio = !_playAudio;
                });
                if (_playAudio) playFunc();
                if (!_playAudio) stopPlayFunc();
              },
              icon: _playAudio
                  ? Icon(
                      Icons.stop,
                    )
                  : Icon(Icons.play_arrow),
              label: _playAudio
                  ? Text(
                      "Stop",
                      style: TextStyle(
                        fontSize: 28,
                      ),
                    )
                  : Text(
                      "Play",
                      style: TextStyle(
                        fontSize: 28,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
  ElevatedButton createElevatedButton(
      {required IconData icon, required Color iconColor, required onPressFunc()}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(6.0),
        side: BorderSide(
          color: Colors.red,
          width: 4.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        primary: Colors.white,
        elevation: 9.0,
      ),
      onPressed: onPressFunc,
      icon: Icon(
        icon,
        color: iconColor,
        size: 38.0,
      ),
      label: Text(''),
    );
  }
  Future<void> startRecording() async {
    Directory directory = Directory(path.dirname(pathToAudio!));
    if (!directory.existsSync()) {
      directory.createSync();
    }
    _recordingSession!.openAudioSession();
    await _recordingSession!.startRecorder(
      toFile: pathToAudio,
      codec: Codec.pcm16WAV,
    );
    if(_recordingSession!.onProgress == null)
    {
      debugPrint('onProgress is null');
    }
    StreamSubscription recorderSubscription =
        _recordingSession!.onProgress!.listen((e) {
      var date = DateTime.fromMillisecondsSinceEpoch(e.duration.inMilliseconds,
          isUtc: true);
      var timeText = DateFormat('mm:ss:SS', 'en_GB').format(date);
      debugPrint('time text: $timeText');
      setState(() {
        _timerText = timeText.substring(0, 8);
      });
    });
    recorderSubscription.cancel();
  }
  Future<String?> stopRecording() async {
    _recordingSession!.closeAudioSession();
    return _recordingSession?.stopRecorder();
  }
  Future<void> playFunc() async {
    var audioFile = recordingPlayer.open(
      Audio.file(pathToAudio!),
      autoStart: true,
      showNotification: true,
    );
    var duration = await flutterSoundHelper.duration(pathToAudio!);
    showDialog(context: context, builder: (context) {
      return AlertDialog(content: Text('${duration!.inMinutes} min. ${duration!.inSeconds} sec.'));
    },);
    debugPrint('${duration!.inSeconds}');
    
  }
  Future<void> stopPlayFunc() async {
    recordingPlayer.stop();
  }
}

Future<void> getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      deviceId = iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      deviceId = androidDeviceInfo.id; // unique ID on Android
    }
  }

  FloatingActionButton helpButton({required BuildContext context}) {
    return FloatingActionButton(
            backgroundColor: appPrimaryColor,
            onPressed: () {
              debugPrint('Floating Action Button');
              showCustomDialog(
                  context,
                  "Info",
                  AppLocalizations.of(context)!.helpText(deviceId!),
                  List.empty());
            },
            child: const Icon(Icons.help_outline));
  }