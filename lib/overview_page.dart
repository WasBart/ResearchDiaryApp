import 'package:flutter/material.dart';
import 'package:research_diary_app/addentry_page_sound.dart';
import 'package:research_diary_app/day_page.dart';
import 'package:research_diary_app/notification_service.dart';
import 'package:research_diary_app/util.dart';
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
  List<ElevatedButton> loadedDayList = [];
  List<String> datesList = [];
  Map<String, List<Map>> entriesPerDayMap = {};

  @override
  void initState() {
    super.initState();

    // TODO: Maybe add loading icon until data has finished fetching

    createDaysList().then((value) {
      setState(() {
        dayList = loadedDayList;
        print(entriesPerDayMap);
      });
    });

    /*Navigator.of(context).push(MaterialPageRoute(
      builder: 
      (context) => DayPage(assignedEntriesList: [],),
      ),
    ).then((_) {
      createDaysList().then((value){
      setState(() {
        dayList = loadedDayList;
        print(entriesPerDayMap);
      });
    });
      // Call setState() here or handle this appropriately
    });*/

    /*Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DayPage(
                assignedEntriesList: [],
              )),
    ).then((value) => setState(() {})); */
    //dayList.add(ElevatedButton(onPressed: createDaysList, child: Text("loadData")));
    //createDaysList();
    //createTestDaysList();
    //WidgetsBinding.instance?.addPostFrameCallback((_) {
    //  createDaysList();
    //});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
    /*for (int i = 0; i < 50; i++) {
      dayList.add(
        ElevatedButton(
          onPressed: () {},
          child: Text("Test$i"),
        ),
      );
    }
    */

    // TODO: Call backend and get all entries for days and create buttons in dayList for each day
    List entriesList = await getEntries();
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
    /*for (var element in datesList) {
      loadedDayList.add(ElevatedButton(onPressed: () {}, child: Text(element)));
    }*/
    entriesPerDayMap.forEach((key, value) {
      loadedDayList.add(ElevatedButton(
          onPressed: () => createDayPage(value), child: Text(key)));
    });
    // TODO: get dates for elements and if they do not exist in daysList, add them to days list
    // TODO: create buttons for each day that link to day pages for the days
  }

  void createDayPage(List<Map> entriesPerDay) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return DayPage(assignedEntriesList: entriesPerDay);
      }),
    ).then((value) => createDaysList().then((value) {
          setState(() {
            dayList = loadedDayList;
            print(entriesPerDayMap);
          });
        }));

        
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
