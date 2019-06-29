import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';


class URLizer {
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
}