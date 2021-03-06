library looking_glass_ui;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'looking_glass_icons.dart' as AppLogo;
import 'settings.dart';
import 'mstdn_status.dart';
import 'main.dart';

final specifyAnInstance = TextEditingController();
final logIntoAnInstance = TextEditingController();
final likedPostSnackBar = SnackBar(
  content: Text("Liked the post!",
    textAlign: TextAlign.center,
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
  backgroundColor: Colors.deepPurple,
);
final rebloggedPostSnackBar = SnackBar(
  content: Text("Reblogged the post!",
    textAlign: TextAlign.center,
    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
  ),
  backgroundColor: Colors.green,
);

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

Widget interactionIcon(int type, int interactionCount, String id) {
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
  return InkWell(
    child: Row(
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
    ),
    onTap: () {
      if (type == 2) {
        reblogStatus(legitHTTP, id);
        scaffoldKey.currentState.showSnackBar(rebloggedPostSnackBar);
      } else if (type == 3) {
        favoriteStatus(legitHTTP, id);
        scaffoldKey.currentState.showSnackBar(likedPostSnackBar);
      }
    }
  );
}

Widget interactionBar(String id, int replies, int boosts, int favs, String url) {
  return Row(
    children: <Widget>[
      interactionIcon(1, replies, id),
      interactionIcon(2, boosts, id),
      interactionIcon(3, favs, id),
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

Future<bool> showLogoutDialog(BuildContext context) async {
  bool shouldILogOut = false;
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          title: Row(
            children: <Widget>[
              Text("Log Out?"),
            ],
          ),
          content: Text("You will be unable to use any functions that require "
              "authentication until you sign back in."),
          actions: <Widget>[
            MaterialButton(
              child: new Text("Yes", style: TextStyle(color: Colors.white)),
              color: headerColor,
              onPressed: () {
                shouldILogOut = true;
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: new Text("No"),
              onPressed: () {
                shouldILogOut = false;
                Navigator.of(context).pop();
              },
            ),
          ]);
    },
  ).then((val) {
    return shouldILogOut;
  });
  return shouldILogOut;
}

class ColoredTabBar extends Container implements PreferredSizeWidget {
  ColoredTabBar(this.color, this.tabBar);
  final Color color;
  final TabBar tabBar;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) => Container(
    color: color,
    child: tabBar,
  );
}
