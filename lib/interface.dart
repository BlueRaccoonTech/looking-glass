import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';


class LookingGlassCustomUI {
  static TextSpan makeURL (String linkText, String linkUrl, BuildContext context) {
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
  static Row interactionBar(int replies, int boosts, int favs, String url) {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(5, 0, 4, 0),
          child: Icon(
            Icons.reply,
            color: Colors.blue,
            size: 30.0,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(4, 0, 15, 0),
          child: Text(
            replies.toString(),
            style: TextStyle(color: Colors.blue),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(15, 0, 4, 0),
          child: Icon(
            Icons.record_voice_over,
            color: Colors.green,
            size: 30.0,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(4, 0, 15, 0),
          child: Text(
            boosts.toString(),
            style: TextStyle(color: Colors.green),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(15, 0, 4, 0),
          child: Icon(
            Icons.favorite,
            color: Colors.deepPurple,
            size: 30.0,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(4, 0, 15, 0),
          child: Text(
            favs.toString(),
            style: TextStyle(color: Colors.deepPurple),
          ),
        ),
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
}