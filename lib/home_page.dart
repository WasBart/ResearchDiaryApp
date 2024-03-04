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
import 'package:research_diary_app/globals.dart';
import 'package:research_diary_app/notification_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final NotificationService notificationService;
  int _counter = 0;
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

    getId().then((value) => getEnteredDays());
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
                  ).then((value) => getEnteredDays());
                },
                child: mainContainer(
                    child: Text(AppLocalizations.of(context)!.addButtonText)),
              ),
            ),
            Flexible(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (BuildContext context) {
                      return OverviewPage();
                    }),
                  ).then((value) => getEnteredDays());
                },
                child: mainContainer(
                    child:
                        Text(AppLocalizations.of(context)!.overviewButtonText)),
              ),
            ),
            Flexible(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (BuildContext context) {
                      return RewardsPage(numberOfDays: numberOfDays);
                    }),
                  ).then((value) => getEnteredDays());
                },
                child: mainContainer(
                    child:
                        Text(AppLocalizations.of(context)!.researchButtonText)),
              ),
            )
          ]),
    );
  }

  /*void researcherNotesButtonOnPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return RewardsPage();
      }),
    );
  }*/

  bool setResearcherNotesButtonActive() {
    if (numberOfDays >= 3) {
      return true;
    } else {
      return false;
    }
  }

  /*void updateNumberOfDays() {
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
              buttonActive ? researcherNotesButtonOnPressed() : showCustomDialog(
                  context,
                  "Research Area",
                  "Check back after you have added more days to your research diary to find research and additional info pertaining to men's studies here.",
                  List.empty());
            },
            child: buttonActive
                ? mainContainer(child: const Text("Research Area"))
                : inactiveContainer(child: const Text("Research Area")));
      });
    });
  }*/

  Future getEnteredDays() async {
    List textEntriesList = await getTextNotesFromServer();
    List audioEntriesList = await getVoiceNotesFromServer();
    textEntriesList.addAll(audioEntriesList);
    List datesList = [];
    for (var element in textEntriesList) {
      String entryDate = element["date"];
      entryDate = entryDate.substring(0, entryDate.indexOf("T"));
      if (!datesList.contains(entryDate)) {
        datesList.add(entryDate);
        print("Entry date just added: $entryDate");
      }
    }
    setState(() {
      numberOfDays = datesList.length;
      print("Number of days: $numberOfDays");
    });
    await showResearchDialog(numberOfDays);
  }

    /// Load the initial counter value from persistent storage on start,
  /// or fallback to 0 if it doesn't exist.
  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('counter') ?? 0;
    });
  }

  /// After a click, increment the counter state and
  /// asynchronously save it to persistent storage.
  Future<void> _incrementCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = (prefs.getInt('counter') ?? 0) + 1;
      prefs.setInt('counter', _counter);
    });
  }

  Future<void> showResearchDialog(int days) async {
    List<Widget> confirmActions = [
      TextButton(
        child: Text("OK"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      )
    ];
    await _loadCounter();
    if(days >= 1 && _counter == 0)
    {
      showCustomDialog(context, AppLocalizations.of(context)!.researchNotificationTitle, AppLocalizations.of(context)!.researchNotificationBody, confirmActions);
      await _incrementCounter();
    }
    else if(days >= 3 && _counter == 1)
    {
      showCustomDialog(context, AppLocalizations.of(context)!.researchNotificationTitle, AppLocalizations.of(context)!.researchNotificationBody, confirmActions);
      await _incrementCounter();
    }
    else if(days >= 6 && _counter == 2)
    {
      showCustomDialog(context, AppLocalizations.of(context)!.researchNotificationTitle, AppLocalizations.of(context)!.researchNotificationBody, confirmActions);
      await _incrementCounter();
    }
  }
}
