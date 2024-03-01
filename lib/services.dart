import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

import 'package:research_diary_app/globals.dart';

Future<http.Response> postTextNoteToServer(
    String text, String title, String date) async {
  http.Response response = await http.put(
      Uri.parse("https://$serverAdress/text_notes/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-token': deviceId!
      },
      body: jsonEncode(
          <String, String>{'text': text, 'title': title, 'date': date}));
  return response;
  //print("statusCode: " + response.statusCode.toString());
  // TODO: status code überprüfen ob 200 sonst error message und error handling
}

Future<List> getTextNotesFromServer() async {
  http.Response response = await http.get(
      Uri.parse("https://$serverAdress/text_notes/"),
      headers: <String, String>{'x-token': deviceId!});
  //print("statusCode: "  + response.statusCode.toString());
  // TODO: status code überprüfen ob 200 sonst error message und error handling
  return json.decode(utf8.decode(response.bodyBytes));
}

Future<void> deleteTextNoteFromServer(int textNoteId) async {
  http.Response response = await http.delete(
      Uri.parse("https://$serverAdress/text_notes/$textNoteId"),
      headers: <String, String>{'x-token': deviceId!});
  print("statusCode: " + response.statusCode.toString());
  // TODO: status code überprüfen ob 200 sonst error message und error handling
}

Future<void> postVoiceNoteToServer(
    String path, String title, String date) async {
  var uri = Uri.https(serverAdress, '/new_voice_notes/');
  //Uri.parse('http://10.0.2.2:')
  var request = http.MultipartRequest('POST', uri)
    ..headers['x-token'] = deviceId!
    ..fields['date'] = date
    ..fields['title'] = title
    ..files.add(await http.MultipartFile.fromPath('in_file', path,
        contentType: MediaType('audio', 'm4a')));
  var response = await request.send();
  print(response.statusCode);
  print(await response.stream.bytesToString());
  //if (response.statusCode == 200) print('Uploaded!');
}

Future<List> getVoiceNotesFromServer() async {
  http.Response response = await http.get(
      Uri.parse("https://$serverAdress/voice_notes/"),
      headers: <String, String>{'x-token': deviceId!});
  return json.decode(utf8.decode(response.bodyBytes));
}

Future<Uint8List> getVoiceNoteFromServer(int voiceNoteId) async {
  http.Response response = await http.get(
      Uri.parse("https://$serverAdress/voice_note/$voiceNoteId/"),
      headers: <String, String>{'x-token': deviceId!});
  //print("statusCode: "  + response.statusCode.toString());
  // TODO: status code überprüfen ob 200 sonst error message und error handling

  return response.bodyBytes;
}

Future<void> deleteVoiceNoteFromServer(int voiceNoteId) async {
  http.Response response = await http.delete(
      Uri.parse("https://$serverAdress/voice_notes/$voiceNoteId"),
      headers: <String, String>{'x-token': deviceId!});
  print("statusCode: " + response.statusCode.toString());
  // TODO: status code überprüfen ob 200 sonst error message und error handling
}
