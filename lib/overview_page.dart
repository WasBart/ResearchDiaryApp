import 'package:flutter/material.dart';
import 'package:research_diary_app/addentry_page_sound.dart';
import 'package:research_diary_app/day_page.dart';
import 'package:research_diary_app/notification_service.dart';
import 'package:research_diary_app/services.dart';
import 'package:research_diary_app/styles.dart';
import 'package:research_diary_app/util.dart';
import 'package:research_diary_app/globals.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// TODO: Make a scrollable view that loads clickable entries for days
// days are determined by what entries per day exist for users
// if an entry exists, show the day here

// TODO: Pass entriesPerDayMap to day pages accessed via elevated buttons.

class OverviewPage extends StatefulWidget {
  OverviewPage({Key? key}) : super(key: key);

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

    // TODO: Maybe add loading icon until data has finished fetching

    createDaysList().then((value) {
      setState(() {
        dayList = loadedDayList;
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
        title: const Text('Overview'),
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
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            debugPrint('Floating Action Button');
          },
          child: const Icon(Icons.help_outline)),
    );
  }

  Future createDaysList() async {
    List entriesList = await getTextNotesFromServer();
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
    var sortedByValueMap = Map.fromEntries(
    entriesPerDayMap.entries.toList()..sort((e2, e1) => e1.value[0]['date'].compareTo(e2.value[0]['date'])));
    entriesPerDayMap = sortedByValueMap;
    entriesPerDayMap.forEach((key, value) {
      loadedDayList.add(GestureDetector(
        onTap: () => createDayPage(value),
        child: mainContainer(child: Text(key))
      ));
    });
  }

  void createDayPage(List<Map> entriesPerDay) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return DayPage(assignedEntriesList: entriesPerDay);
      }),
    ).then((value) => createDaysList().then((value) {
          setState(() {
            dayList = loadedDayList;
          });
        }));
  }
}
