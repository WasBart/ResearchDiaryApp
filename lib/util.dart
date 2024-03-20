import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:research_diary_app/globals.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:research_diary_app/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';

String formatDate(DateTime date) {
  return '${date.day}.${date.month}.${date.year}';
}

showCustomDialog(BuildContext context, String title, String content,
    List<Widget> inputActions) {
  AlertDialog alert = AlertDialog(
      title: Text(title), content: Text(content), actions: inputActions);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
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
        showCustomDialog(context, "Info",
            AppLocalizations.of(context)!.helpText(deviceId!), List.empty());
      },
      child: const Icon(Icons.help_outline));
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/notificationCounter.txt');
}

Future<File> writeNotificationCounter(int counter) async {
  final file = await _localFile;
  return file.writeAsString('$counter');
}

Future<int> readNotificationCounter() async {
  try {
    final file = await _localFile;
    final contents = await file.readAsString();
    return int.parse(contents);
  } catch (e) {
    return -1;
  }
}
