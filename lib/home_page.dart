import 'package:flutter/material.dart';
import 'package:research_diary_app/overview_page.dart';
import 'package:research_diary_app/addentry_page.dart';
import 'package:research_diary_app/notes_page.dart';
import 'package:research_diary_app/services.dart';
import 'package:research_diary_app/util.dart';
import 'package:research_diary_app/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  int numberOfDays = 0;

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
                      return const AddEntryPage();
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
                      return const OverviewPage();
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
                      return NotesPage(numberOfDays: numberOfDays);
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

  bool setResearcherNotesButtonActive() {
    if (numberOfDays >= 3) {
      return true;
    } else {
      return false;
    }
  }

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
      }
    }
    setState(() {
      numberOfDays = datesList.length;
    });
    await showResearchDialog(numberOfDays);
  }

  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('counter') ?? 0;
    });
  }

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
        child: const Text("OK"),
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
