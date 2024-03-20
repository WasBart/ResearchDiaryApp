import 'package:flutter/material.dart';

import 'package:research_diary_app/services.dart';
import 'package:research_diary_app/util.dart';
import 'package:research_diary_app/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TextCard extends StatefulWidget {
  String text;
  String title;
  int dbId;

  final VoidCallback? onDeleted;

  @override
  _TextCardState createState() => _TextCardState();

  TextCard(this.text, this.title, this.dbId, {this.onDeleted});
}

class _TextCardState extends State<TextCard> {
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        alignment: Alignment.center,
      margin: const EdgeInsets.fromLTRB(50, 10, 50, 10),
      padding: const EdgeInsets.fromLTRB(5, 10, 10, 10),
      width: 200,
      decoration: BoxDecoration(
        color: appTertiaryColor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
      ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
          Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: TextField(
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: null,
                    enabled: false,
                    controller: TextEditingController(text: widget.text),
                    decoration: const InputDecoration(border: InputBorder.none)),
              ),
              Flexible(
                  child: IconButton(
                      onPressed: deleteTextNote, icon: const Icon(Icons.delete)))
            ],
          ),
        ]),
      ),
    );
  }

  void deleteTextNote() async {
    List<Widget> deleteActions = [
      TextButton(
        child: Text(AppLocalizations.of(context)!.deleteActionsCancel),
        onPressed: () {
          Navigator.of(context).pop();
          return;
        },
      ),
      TextButton(
        child: Text(AppLocalizations.of(context)!.deleteActionsConfirm,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () async {
          Navigator.of(context).pop();
          widget.onDeleted!();
          await deleteTextNoteFromServer(widget.dbId);
        },
      )
    ];

    showCustomDialog(
        context,
        AppLocalizations.of(context)!.deleteEntryTitle,
        AppLocalizations.of(context)!.deleteEntryText(widget.text),
        deleteActions);
  }
}
