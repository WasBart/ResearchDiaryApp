import 'package:flutter/material.dart';
import 'package:research_diary_app/day_page.dart';
import 'package:research_diary_app/util.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({Key? key}) : super(key: key);

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
                child: const Text('6.4.2023'),
              ),
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
                child: const Text('5.4.2023'),
              ),
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
                child: const Text('4.4.2023'),
              ),
            ]),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            debugPrint('Floating Action Button');
          },
          child: const Icon(Icons.help_outline)),
    );
  }
}
