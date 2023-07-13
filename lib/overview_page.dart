import 'package:flutter/material.dart';
import 'package:research_diary_app/day_page.dart';
import 'package:research_diary_app/util.dart';

// TODO: Make a scrollable view that loads clickable entries for days
// days are determined by what entries per day exist for users
// if an entry exists, show the day here

class OverviewPage extends StatefulWidget {
  OverviewPage({Key? key}) : super(key: key);

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  List<ElevatedButton> dayList = [];

  @override
  void initState() {
    super.initState();

    createDaysList();
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

  void createDaysList() {
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
  }
}
