import 'package:flutter/material.dart';
import 'package:research_diary_app/addentry_page_sound.dart';
import 'package:research_diary_app/day_page.dart';
import 'package:research_diary_app/overview_page.dart';
import 'package:research_diary_app/addentry_page.dart';
import 'package:research_diary_app/rewards_page.dart';
import 'package:research_diary_app/sound_example.dart';
import 'package:research_diary_app/util.dart';
import 'package:research_diary_app/notification_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final NotificationService notificationService;
  ElevatedButton researcherNotesButton =
      ElevatedButton(onPressed: () {}, child: Text("Researcher Notes"));
  int numberOfDays = 0;

  @override
  void initState() {
    super.initState();

    notificationService = NotificationService();
    notificationService.init().then((value) => notificationService
        .showNotification(id: 1, title: "sample title", body: "it works"));

    getEnteredDays().then((value) {
      setState(() {
        researcherNotesButton = ElevatedButton(
            onPressed: setResearcherNotesButtonActive()
                ? researcherNotesButtonOnPressed
                : null,
            child: Text(numberOfDays.toString()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (BuildContext context) {
                    return const AddEntryPageSound();
                  }),
                );
              },
              child: const Text('Create New Entry'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (BuildContext context) {
                    return OverviewPage();
                  }),
                );
              },
              child: const Text('Overview'),
            ),
            researcherNotesButton
          ]),
    );
  }

  void researcherNotesButtonOnPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return RewardsPage();
      }),
    );
  }

  bool setResearcherNotesButtonActive() {
   if(numberOfDays > 0) {
    return true;
   }
    else {
      return false;
    }
  }

  Future getEnteredDays() async {
    List entriesList = await getEntries();
    List datesList = [];
    for (var element in entriesList) {
      String entryDate = element["date"];
      entryDate = entryDate.substring(0, entryDate.indexOf("T"));
      if (!datesList.contains(entryDate)) {
        datesList.add(entryDate);
      }
    }
    numberOfDays = datesList.length;
  }

  Future<List> getEntries() async {
    http.Response response = await http.get(
        Uri.parse("http://10.0.2.2:8008/text_notes/"),
        headers: <String, String>{
          'x-token': '123' // TODO: change to actual id
        });
    //print("statusCode: "  + response.statusCode.toString());
    // TODO: status code überprüfen ob 200 sonst error message und error handling

    var convResp = response.body;
    List respList = json.decode(convResp);
    return respList;
  }
}
