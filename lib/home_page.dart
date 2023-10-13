import 'package:flutter/material.dart';
import 'package:research_diary_app/addentry_page_sound.dart';
import 'package:research_diary_app/day_page.dart';
import 'package:research_diary_app/overview_page.dart';
import 'package:research_diary_app/addentry_page.dart';
import 'package:research_diary_app/addentry_page_wave.dart';
import 'package:research_diary_app/play_audio_page.dart';
import 'package:research_diary_app/rewards_page.dart';
import 'package:research_diary_app/services.dart';
import 'package:research_diary_app/sound_example.dart';
import 'package:research_diary_app/util.dart';
import 'package:research_diary_app/styles.dart';
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
  ElevatedButton researcherNotesButton = ElevatedButton(
      style: mainButtonStyle,
      onPressed: () {},
      child: Text("Researcher Notes"));
  int numberOfDays = 0;
  Widget researcherNotesContainer =
      mainContainer(child: Text("Researcher Notes"));

  @override
  void initState() {
    super.initState();

    notificationService = NotificationService();
    notificationService.init().then((value) => notificationService
        .showNotification(id: 1, title: "sample title", body: "it works"));

    updateNumberOfDays();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (BuildContext context) {
                      return const AddEntryPageWave();
                    }),
                  ).then((value) => updateNumberOfDays());
                },
                child: mainContainer(child: Text("Add New Entry")),
              ),
            ),
            Flexible(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (BuildContext context) {
                      return OverviewPage();
                    }),
                  ).then((value) => updateNumberOfDays());
                },
                child: mainContainer(child: const Text("Overview")),
              ),
            ),
            Flexible(child: researcherNotesContainer)
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
    if (numberOfDays > 0) {
      return true;
    } else {
      return false;
    }
  }

  void updateNumberOfDays() {
    bool buttonActive = setResearcherNotesButtonActive();
    getEnteredDays().then((value) {
      setState(() {
        researcherNotesButton = ElevatedButton(
            onPressed: setResearcherNotesButtonActive()
                ? researcherNotesButtonOnPressed
                : null,
            child: Text(numberOfDays.toString()));
        researcherNotesContainer = GestureDetector(
            onTap: () {
              buttonActive ? researcherNotesButtonOnPressed() : null;
            },
            child: buttonActive
                ? mainContainer(child: const Text("Researcher Notes"))
                : inactiveContainer(child: const Text("Researcher Notes")));
      });
    });
  }

  Future getEnteredDays() async {
    List entriesList = await getTextNotesFromServer();
    List datesList = [];
    for (var element in entriesList) {
      String entryDate = element["date"];
      entryDate = entryDate.substring(0, entryDate.indexOf("T"));
      if (!datesList.contains(entryDate)) {
        datesList.add(entryDate);
      }
    }
    setState(() {
      numberOfDays = datesList.length;
    });
  }
}
