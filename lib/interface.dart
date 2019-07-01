library looking_glass_ui;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'looking_glass_icons.dart' as AppLogo;
import 'settings.dart';

final specifyAnInstance = TextEditingController();

TextSpan makeURL(String linkText, String linkUrl, BuildContext context) {
  return TextSpan(
    text: linkText,
    style: TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    ),
    recognizer: TapGestureRecognizer()
      ..onTap = () {
        Navigator.of(context).pop();
        launch(linkUrl);
      },
  );
}

Widget interactionIcon(int type, int interactionCount) {
  IconData interactionIcon;
  Color interactionColor;
  if (type == 1) {
    interactionColor = Colors.blue;
    interactionIcon = Icons.reply;
  } else if (type == 2) {
    interactionColor = Colors.green;
    interactionIcon = Icons.record_voice_over;
  } else {
    interactionColor = Colors.deepPurple;
    interactionIcon = Icons.favorite;
  }
  return Row(
    children: <Widget>[
      Padding(
        padding: EdgeInsets.fromLTRB(5, 0, 4, 0),
        child: Icon(
          interactionIcon,
          color: interactionColor,
          size: 30.0,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(4, 0, 15, 0),
        child: Text(
          interactionCount.toString(),
          style: TextStyle(color: interactionColor),
        ),
      ),
    ],
  );
}

Widget interactionBar(int replies, int boosts, int favs, String url) {
  return Row(
    children: <Widget>[
      interactionIcon(1, replies),
      interactionIcon(2, boosts),
      interactionIcon(3, favs),
      Expanded(
        child: Text(''),
      ),
      IconButton(
        icon: Icon(
          Icons.link,
          color: Colors.black,
          size: 30.0,
        ),
        onPressed: () {
          launch(url);
        },
      ),
    ],
  );
}

void showAbout(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          title: Row(
            children: <Widget>[
              Icon(AppLogo.LookingGlass.crystal_ball),
              Text("  The Looking Glass"),
            ],
          ),
          content: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: appDescription + '\n\n' + 'App designed and created by ',
                  style: TextStyle(color: Colors.black),
                ),
                makeURL('Frinkeldoodle', 'https://frinkel.tech',
                    context),
                TextSpan(
                  text: '.\n\n'
                      'Crystal ball icon made by ',
                  style: TextStyle(color: Colors.black),
                ),
                makeURL('Freepik', 'https://www.freepik.com/',
                    context),
                TextSpan(
                  text: ' from ',
                  style: TextStyle(color: Colors.black),
                ),
                makeURL('flaticon.com', 'https://www.flaticon.com',
                    context),
                TextSpan(
                  text: '\n\n'
                      'Source: ',
                  style: TextStyle(color: Colors.black),
                ),
                makeURL(sourceURL, sourceURL, context),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ]);
    },
  );
}
