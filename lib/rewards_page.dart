import 'package:flutter/material.dart';
import 'package:research_diary_app/audio_card.dart';
import 'package:research_diary_app/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:research_diary_app/text_card.dart';
import 'package:research_diary_app/util.dart';

class RewardsPage extends StatefulWidget {
  RewardsPage({Key? key, required this.numberOfDays}) : super(key: key);

  final numberOfDays;

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  List<Widget> researcherNotesList = [];
  List<Widget> allResearcherNotesList = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      allResearcherNotesList.addAll([
        inactiveContainer(
            child: Text(AppLocalizations.of(context)!.researchText1)),
        inactiveContainer(
            child: Text(AppLocalizations.of(context)!.researchText2)),
        inactiveContainer(
            child: Text(AppLocalizations.of(context)!.researchText3))
      ]);
      researcherNotesList.add(inactiveContainer(
          child: Text(AppLocalizations.of(context)!.emptyResearchArea)));
      setState(() {
        researcherNotesList.addAll(allResearcherNotesList);
      });
    });

    researcherNotesList
        .add(inactiveContainer(child: Text(widget.numberOfDays.toString())));
    for (var i = 0; i < widget.numberOfDays; i++) {
      researcherNotesList.add(AudioCard(
          "Researcher Note ${i + 1}", LocationType.assets,
          path: "marvinsroom.mp3"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Research Area'),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: getVoiceNotesList().length,
              itemBuilder: (BuildContext context, int index) {
                return getVoiceNotesList()[index];
              },
              //separatorBuilder: (BuildContext context, int index) =>
              //    const Divider(),
            ))
          ]),
      floatingActionButton: helpButton(context: context),
    );
  }

  List<Widget> getVoiceNotesList() {
    List<Widget> tempList = [];
    if (widget.numberOfDays < 1) {
      tempList = [
        IntrinsicHeight(
          child: inactiveContainer(
            child: Text(AppLocalizations.of(context)!.emptyResearchArea),
          ),
        ),
      ];
    } else if (widget.numberOfDays < 3) {
      tempList = [
        IntrinsicHeight(
          child: variableContainer(
              child: Text(AppLocalizations.of(context)!.researchText1)),
        ),
      ];
    } else if (widget.numberOfDays < 6) {
      tempList = [
        IntrinsicHeight(
          child: variableContainer(
              child: Text(AppLocalizations.of(context)!.researchText1)),
        ),
        IntrinsicHeight(
          child: variableContainer(
              child: Text(AppLocalizations.of(context)!.researchText2)),
        )
      ];
    } else {
      tempList = [
        IntrinsicHeight(
          child: variableContainer(
              child: Text(AppLocalizations.of(context)!.researchText1)),
        ),
        IntrinsicHeight(
          child: variableContainer(
              child: Text(AppLocalizations.of(context)!.researchText2)),
        ),
        IntrinsicHeight(
          child: variableContainer(
              child: Text(AppLocalizations.of(context)!.researchText3)),
        )
      ];
    }
    return tempList;
  }
}
