import 'package:flutter/material.dart';
import 'package:research_diary_app/home_page.dart';
import 'package:research_diary_app/notification_service.dart';

// TODO: Add 'Rewards'-page that shows all unlocked audio files

late final NotificationService notificationService;

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Research Diary'),
      ),
      body: const HomePage(),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            debugPrint('Floating Action Button');
          },
          child: const Icon(Icons.help_outline)),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'home'),
          NavigationDestination(
              icon: Icon(Icons.person_outlined), label: 'profile'),
        ],
        onDestinationSelected: (int index) {
          setState(() {
            currentPage = index;
          });
        },
        selectedIndex: currentPage,
      ),
    );
  }
}
