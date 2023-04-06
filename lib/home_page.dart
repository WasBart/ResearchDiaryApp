import 'package:flutter/material.dart';
import 'package:learningdart/day_page.dart';
import 'package:learningdart/overview_page.dart';
import 'package:learningdart/addentry_page.dart';
import 'package:learningdart/util.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

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
                    return DayPage(
                      storage: DiaryEntryStorage(
                        filename: formatDate(
                          DateTime.now(),
                        ),
                      ),
                    );
                  }),
                );
              },
              child: const Text('Today'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (BuildContext context) {
                    return const OverviewPage();
                  }),
                );
              },
              child: const Text('Overview'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (BuildContext context) {
                    return const AddEntryPage();
                  }),
                );
              },
              child: const Text('Add New Entry'),
            ),
          ]),
    );
  }
}
