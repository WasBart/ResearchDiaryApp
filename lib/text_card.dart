import 'package:flutter/material.dart';

import 'package:research_diary_app/services.dart';
import 'package:research_diary_app/util.dart';
import 'package:research_diary_app/styles.dart';

class TextCard extends StatefulWidget {
  String text;
  int dbId;

  final VoidCallback? onDeleted;

  @override
  _TextCardState createState() => _TextCardState();

  TextCard(this.text, this.dbId, {this.onDeleted});
}

class _TextCardState extends State<TextCard> {
  @override
  Widget build(BuildContext context) {
    return mainContainer(
      child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  enabled: false,
                  controller: TextEditingController(text: widget.text)),
            ),
          Flexible(child: IconButton(onPressed: deleteTextNote, icon: const Icon(Icons.delete)))
        ],
      ),
    );
  }

  void deleteTextNote() async {
    List<Widget> deleteActions = [
      TextButton(
        child: const Text("Cancel"),
        onPressed: () {
          Navigator.of(this.context).pop();
          return;
        },
      ),
      TextButton(
        child: const Text("Confirm", style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () async {
          Navigator.of(this.context).pop();
          widget.onDeleted!();
          await deleteTextNoteFromServer(widget.dbId);
        },
      )
    ];

    showCustomDialog(
        context,
        "Delete Entry?",
        "Are you sure you want to delete this entry: \"${widget.text}\"",
        deleteActions);
  }
}