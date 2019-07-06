/// All the little things one might want to configure.
/// All in one neat little package. :3
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tiKey = 'targetInstance';

readTI() async {
  final prefs = await SharedPreferences.getInstance();
  targetInstance = prefs.getString(tiKey) ?? "mastodon.social";
  print('Loaded ' + targetInstance + ' from memory.');
}

saveTI() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(tiKey, targetInstance);
  print('Saved' + targetInstance + 'to memory.');
}

Color headerColor = Colors.black54;

String protocol = "https://";
String targetInstance = "mastodon.social";
String apiURL = "/api/v1/";
String apiTimelinePath = "timelines/";
String instanceInfoPath = "instance";
String timelineType = "public";
var localOnly = true;
int maxPosts = 20;

String sourceURL = "https://git.frinkel.tech/root/looking-glass";

String appDescription = "A reconnaissance tool for quickly displaying public "
    "posts from any social media website compatible with the Mastodon API.";

RegExp urlGrabber = RegExp(r"(https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,12}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*))");
String nextURL = protocol + targetInstance + apiURL + apiTimelinePath + timelineType;
String prevURL = protocol + targetInstance + apiURL + apiTimelinePath + timelineType;
String latestURL = protocol + targetInstance + apiURL + apiTimelinePath + timelineType;
String instanceInfo = protocol + targetInstance + apiURL + instanceInfoPath;

String errorFetching = "There was an error fetching the data.\nPlease try again later.";
String emptyFetching = "Nothing new!";
String sameViewFetching = "Refreshing current page...";