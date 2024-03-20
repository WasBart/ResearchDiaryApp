import 'package:flutter/material.dart';
import 'package:research_diary_app/day_page.dart';
import 'package:research_diary_app/services.dart';
import 'package:research_diary_app/styles.dart';
import 'package:research_diary_app/util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  List<Widget> dayList = [];
  List<Widget> loadedDayList = [];
  List<String> datesList = [];
  Map<String, List<Map>> entriesPerDayMap = {};

  @override
  void initState() {
    super.initState();

    dayList.add(Container(
        margin: const EdgeInsets.fromLTRB(150, 50, 150, 50),
        width: 0.5,
        height: 20,
        child: const CircularProgressIndicator()));
    createDaysList().then((value) {
      setState(() {
        dayList = loadedDayList;
        if (loadedDayList.isEmpty) {
          dayList.add(inactiveContainer(
              child: Text(AppLocalizations.of(context)!.noEntriesText)));
        }
      });
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppLocalizations.of(context)!.overviewPageTitle),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ListView(
                  children: dayList,
                ),
              )
            ]),
      ),
      floatingActionButton: helpButton(context: context),
    );
  }

  Future createDaysList() async {
    List<Widget> confirmActions = [
      TextButton(
        child: const Text("OK"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      )
    ];
    List entriesList = [];
    try {
      entriesList = await getTextNotesFromServer().timeout(const Duration(seconds: 5));
    }
    on TimeoutException catch (e) {
          showCustomDialog(context, AppLocalizations.of(context)!.timeoutTitle, AppLocalizations.of(context)!.timeoutText, confirmActions);
        } on Error catch (e) {
          print('Error: $e');
        }
    List temp = await getVoiceNotesFromServer();
    entriesList.addAll(temp);
    datesList = [];
    entriesPerDayMap = {};
    loadedDayList = [];
    for (var element in entriesList) {
      String entryDate = element["date"];
      entryDate = entryDate.substring(0, entryDate.indexOf("T"));
      if (!datesList.contains(entryDate)) {
        datesList.add(entryDate);
        List<Map> tempEntryList = [];
        tempEntryList.add(element);
        entriesPerDayMap.addAll({entryDate: tempEntryList});
      } else {
        entriesPerDayMap[entryDate]?.add(element);
      }
    }
    var sortedByValueMap = Map.fromEntries(entriesPerDayMap.entries.toList()
      ..sort((e2, e1) => e1.value[0]['date'].compareTo(e2.value[0]['date'])));
    entriesPerDayMap = sortedByValueMap;
    entriesPerDayMap.forEach((key, value) {
      loadedDayList.add(GestureDetector(
          onTap: () => createDayPage(value),
          child: mainContainer(child: Text(key))));
    });
  }

  void createDayPage(List<Map> entriesPerDay) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return DayPage(assignedEntriesList: entriesPerDay);
      }),
    ).then(
      (value) => createDaysList().then(
        (value) {
          setState(() {
            dayList = loadedDayList;
            if (loadedDayList.isEmpty) {
              dayList.add(inactiveContainer(
                  child: Text(AppLocalizations.of(context)!.noEntriesText)));
            }
          });
        },
      ),
    );
  }
}
