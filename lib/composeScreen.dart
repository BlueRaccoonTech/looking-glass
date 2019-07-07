import 'package:flutter/material.dart';
import 'looking_glass_icons.dart' as AppLogo;
import 'settings.dart';
import 'package:looking_glass/main.dart';
import 'interface.dart';
import 'package:looking_glass/mstdn_status.dart';
import 'package:http/io_client.dart';
import 'main.dart';

final subjectComposer = TextEditingController();
final messageComposer = TextEditingController();

final IOClient anotherLegitHTTP = new IOClient();

class ComposePageWidget extends StatefulWidget {
  @override
  ComposePage createState() => ComposePage();
}

class ComposePage extends State<ComposePageWidget> {
  bool visDM = false;
  bool visLock = false;
  bool visUnli = false;
  bool visPub = true;     // TODO: Make default visibility user choice.

  String returnVisibility() {
    if (visDM) {
      return "direct";
    } else if (visLock) {
      return "private";
    } else if (visUnli) {
      return "unlisted";
    } else {
      return "public";
    }
  }

  void changeSelectedVisibility(int visLevel) {
    // Reset all bools to false.
    visDM = false;
    visLock = false;
    visUnli = false;
    visPub = false;
    //Set appropriate level to true based on selection.
    setState(() {
      if (visLevel == 0) {        // Visibility = DM
        visDM = true;
      } else if (visLevel == 1) { // Visibility = Locked
        visLock = true;
      } else if (visLevel == 2) { // Visibility = Unlisted
        visUnli = true;
      } else {                    // Visibility = Public
        visPub = true;
      }
    });
  }

  Color colorIfSelected(bool isSelected) {
    if (isSelected) {
      return Colors.green;
    } else {
      return Colors.blueGrey;
    }
  }

  Widget interactionBar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon:Icon(Icons.mail_outline),
          color: colorIfSelected(visDM),
          onPressed: () {
            changeSelectedVisibility(0);
          }
        ),
        IconButton(
            icon:Icon(Icons.lock_outline),
            color: colorIfSelected(visLock),
            onPressed: () {
              changeSelectedVisibility(1);
            }
        ),
        IconButton(
            icon:Icon(Icons.lock_open),
            color: colorIfSelected(visUnli),
            onPressed: () {
              changeSelectedVisibility(2);
            }
        ),
        IconButton(
            icon:Icon(Icons.all_inclusive),
            color: colorIfSelected(visPub),
            onPressed: () {
              changeSelectedVisibility(3);
            }
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Implement creation of random key for idempotency-key header

    final postButton = RaisedButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: headerColor,
        onPressed: () {
          // TODO: Add function to send visibility, spoiler_text, and status to /api/v1/status endpoint
          snedPost(anotherLegitHTTP, returnVisibility(), messageComposer.text, (subjectComposer.text ?? ""));
          Navigator.of(context).pop();
        },
        child: Text(postLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
      );

    final subjectTextBox = TextField(
      controller: subjectComposer,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Subject (optional)',
      ),
    );

    final postTextBox = TextField(
      controller: messageComposer,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: "What's up?",
      ),
    );

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: headerColor,
        leading: IconButton(
            icon:Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            }
        ),
        title: Text("Compose Message"),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blueGrey,
                Colors.black87,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                /// TODO: Add user avatar
                /// TODO: Add visibility bar
                Card(child: interactionBar()),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: <Widget>[
                        subjectTextBox,
                        Divider(),
                        postTextBox,
                      ],
                    ),
                  ),
                ),
                Divider(height: 8, color: Color.fromARGB(0,0,0,0)),
                postButton,
              ],
            ),
          ),
        ),
      ),
    );
  }
}