import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

import 'package:research_diary_app/globals.dart';

void postTextNoteToServer(String text, String date) async {
  http.Response response = await http.put(
            Uri.parse("${localAdress}/text_notes/"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'x-token': '123' // TODO: change to actual ID
            },
            body: jsonEncode(<String, String>{
              'text': text,
              'date': date
            }));
        //print("statusCode: " + response.statusCode.toString());
        // TODO: status code überprüfen ob 200 sonst error message und error handling
}

Future<List> getTextNotesFromServer() async {
  http.Response response = await http.get(
        Uri.parse("http://${localAdress}/text_notes/"),
        headers: <String, String>{
          'x-token': '123' // TODO: change to actual id
        });
    //print("statusCode: "  + response.statusCode.toString());
    // TODO: status code überprüfen ob 200 sonst error message und error handling

    var convResp = response.body;
    return json.decode(convResp);
}

Future<void> deleteTextNoteFromServer(int textNoteId) async {
   http.Response response = await http.delete(Uri.parse("http://${localAdress}/text_notes/$textNoteId"), headers: <String, String>{
          'x-token': '123' // TODO: change to actual id
        });
        print("statusCode: "  + response.statusCode.toString());
        // TODO: status code überprüfen ob 200 sonst error message und error handling
}

void postVoiceNoteToServer(String path, String date) async {
  var uri = Uri.http('${localAdress}', '/new_voice_notes/');
    //Uri.parse('http://10.0.2.2:')
    var request = http.MultipartRequest('POST', uri)
      ..headers['x-token'] = "123" // TODO change to actual id
      ..fields['date'] = date
      ..files.add(await http.MultipartFile.fromPath(
          'in_file', path,
          contentType: MediaType('audio', 'm4a')));
    var response = await request.send();
    //print(response.statusCode);
    //print(await response.stream.bytesToString());
    //if (response.statusCode == 200) print('Uploaded!');
}

Future<List> getVoiceNotesFromServer() async {
   http.Response response = await http.get(Uri.parse("http://${localAdress}/voice_notes/"),
        headers: <String, String>{
          'x-token': '123' // TODO: change to actual id
        });
    var convResp = response.body;
    return json.decode(convResp);
}

Future<Uint8List> getVoiceNoteFromServer(int voiceNoteId) async {
  http.Response response = await http.get(
        Uri.parse("http://${localAdress}/voice_note/$voiceNoteId/"),
        headers: <String, String>{
          'x-token': '123' // TODO: change to actual id
        });
    //print("statusCode: "  + response.statusCode.toString());
    // TODO: status code überprüfen ob 200 sonst error message und error handling

    return response.bodyBytes;
}

Future<void> deleteVoiceNoteFromServer(int voiceNoteId) async {
   http.Response response = await http.delete(Uri.parse("http://${localAdress}/voice_notes/$voiceNoteId"), headers: <String, String>{
          'x-token': '123' // TODO: change to actual id
        });
        print("statusCode: "  + response.statusCode.toString());
        // TODO: status code überprüfen ob 200 sonst error message und error handling
}