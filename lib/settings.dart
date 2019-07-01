/// All the little things one might want to configure.
/// All in one neat little package. :3
import 'package:flutter/material.dart';

Color headerColor = Colors.black54;

String targetInstance = "mastodon.social";
String apiURL = "/api/v1/";
String apiTimelinePath = "timelines/";
String timelineType = "public";
var localOnly = true;
int maxPosts = 20;

String sourceURL = "https://git.frinkel.tech/root/looking-glass";

String appDescription = "A reconnaissance tool for quickly displaying public "
    "posts from any social media website compatible with the Mastodon API.";

RegExp urlGrabber = new RegExp(r"(https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,12}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*))");
String nextURL = "https://" + targetInstance + apiURL + apiTimelinePath + timelineType;
String prevURL = "https://" + targetInstance + apiURL + apiTimelinePath + timelineType;
String latestURL = "https://" + targetInstance + apiURL + apiTimelinePath + timelineType;