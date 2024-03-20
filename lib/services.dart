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
}

Future<List> getTextNotesFromServer() async {
  http.Response response = await http.get(
      Uri.parse("https://$serverAdress/text_notes/"),
      headers: <String, String>{'x-token': deviceId!});
  return json.decode(utf8.decode(response.bodyBytes));
}

Future<void> deleteTextNoteFromServer(int textNoteId) async {
  await http.delete(Uri.parse("https://$serverAdress/text_notes/$textNoteId"),
      headers: <String, String>{'x-token': deviceId!});
}

Future<void> postVoiceNoteToServer(
    String path, String title, String date) async {
  var uri = Uri.https(serverAdress, '/new_voice_notes/');
  var request = http.MultipartRequest('POST', uri)
    ..headers['x-token'] = deviceId!
    ..fields['date'] = date
    ..fields['title'] = title
    ..files.add(await http.MultipartFile.fromPath('in_file', path,
        contentType: MediaType('audio', 'm4a')));
  await request.send();
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
  return response.bodyBytes;
}

Future<void> deleteVoiceNoteFromServer(int voiceNoteId) async {
  await http.delete(Uri.parse("https://$serverAdress/voice_notes/$voiceNoteId"),
      headers: <String, String>{'x-token': deviceId!});
}
