import 'package:flutter/material.dart';
import 'package:research_diary_app/audio_card.dart';
import 'package:research_diary_app/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:research_diary_app/util.dart';

class NotesPage extends StatefulWidget {
const NotesPage({Key? key, required this.numberOfDays}) : super(key: key);

  final int numberOfDays;

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
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
        AudioCard(
          AppLocalizations.of(context)!.researchNote1Title, LocationType.assets,
          path: AppLocalizations.of(context)!.researchNote1Path),
        IntrinsicHeight(
          child: variableContainer(
              child: Text(AppLocalizations.of(context)!.researchText1)),
        )
      ];
    } else if (widget.numberOfDays < 6) {
      tempList = [
        AudioCard(
          AppLocalizations.of(context)!.researchNote1Title, LocationType.assets,
          path: AppLocalizations.of(context)!.researchNote1Path),
        IntrinsicHeight(
          child: variableContainer(
              child: Text(AppLocalizations.of(context)!.researchText1)),
        ),
        
        AudioCard(
          AppLocalizations.of(context)!.researchNote2Title, LocationType.assets,
          path: AppLocalizations.of(context)!.researchNote2Path),
        IntrinsicHeight(
          child: variableContainer(
              child: Text(AppLocalizations.of(context)!.researchText2)),
        )
      ];
    } else {
      tempList = [
        AudioCard(
          AppLocalizations.of(context)!.researchNote1Title, LocationType.assets,
          path: AppLocalizations.of(context)!.researchNote1Path),
        IntrinsicHeight(
          child: variableContainer(
              child: Text(AppLocalizations.of(context)!.researchText1)),
        ),
        AudioCard(
          AppLocalizations.of(context)!.researchNote2Title, LocationType.assets,
          path: AppLocalizations.of(context)!.researchNote2Path),
        IntrinsicHeight(
          child: variableContainer(
              child: Text(AppLocalizations.of(context)!.researchText2)),
        ),
        AudioCard(
          AppLocalizations.of(context)!.researchNote3Title, LocationType.assets,
          path: AppLocalizations.of(context)!.researchNote3Path),
        IntrinsicHeight(
          child: variableContainer(
              child: Text(AppLocalizations.of(context)!.researchText3)),
        )
      ];
    }
    return tempList;
  }
}
