import 'package:flutter/material.dart';
import 'package:research_diary_app/audio_card.dart';
import 'package:research_diary_app/styles.dart';

class RewardsPage extends StatefulWidget {
  RewardsPage({Key? key, required this.numberOfDays}) : super(key: key);

  final numberOfDays;

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  List<Widget> researcherNotesList = [inactiveContainer(child: Text("Check back after you have added more days to your research diary."))];

  @override
  void initState() {
    super.initState();

    researcherNotesList.add(inactiveContainer(child: Text(widget.numberOfDays.toString())));
    for (var i = 0; i < widget.numberOfDays; i++) {
      researcherNotesList.add(AudioCard("Researcher Note ${i+1}", LocationType.assets, path: "marvinsroom.mp3"));
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
                  children: researcherNotesList,
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
}