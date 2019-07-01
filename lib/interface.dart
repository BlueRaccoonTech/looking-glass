library looking_glass_ui;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

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

Row interactionBar(int replies, int boosts, int favs, String url) {
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
