import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys for persistent loading...
final   tiKey = 'targetInstance';

/// Keys for API info...
final   arKey = 'appRegistered';
final   liKey = 'loginInstance';
final   ciKey = 'clientID';
final   csKey = 'clientSecret';

/// Keys for login info...
final   iaKey = 'isAuthenticated';
final   rtKey = 'refreshToken';
final   atKey = 'accessToken';
final   teKey = 'tokenExpiryIn';
final   mtKey = 'madeTokenAt';

/// Preferences to be loaded...
String  targetInstance = "mastodon.social";
String  timelineType = "public";
bool    localOnly = true;
int     maxPosts = 20;

/// App info to be loaded...
bool    appRegistered;
String  loginInstance;
String  clientID;
String  clientSecret;

/// Login info to be loaded...
bool    isAuthenticated;
String  refreshToken;
String  accessToken;
int     tokenExpiryIn;
int     madeTokenAt;


readPrefs() async {
  final prefs     = await SharedPreferences.getInstance();
  targetInstance  = prefs.getString(tiKey) ?? "mastodon.social";
  appRegistered   = prefs.getBool(arKey) ?? false;
  loginInstance   = prefs.getString(liKey) ?? null;
  clientID        = prefs.getString(ciKey) ?? null;
  clientSecret    = prefs.getString(csKey) ?? null;

  isAuthenticated = prefs.getBool(iaKey) ?? false;
  refreshToken    = prefs.getString(rtKey) ?? null;
  accessToken     = prefs.getString(atKey) ?? null;
  tokenExpiryIn   = prefs.getInt(teKey) ?? null;
  madeTokenAt     = prefs.getInt(mtKey) ?? null;
  print(appRegistered);
  print(isAuthenticated);
}

saveTI() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(tiKey, targetInstance);
}

saveClientInfo() async {
  final prefs   = await SharedPreferences.getInstance();
  prefs.setBool(arKey, appRegistered);
  prefs.setString(liKey, loginInstance);
  prefs.setString(ciKey, clientID);
  prefs.setString(csKey, clientSecret);
}

saveLoginInfo() async {
  final prefs   = await SharedPreferences.getInstance();
  prefs.setBool(iaKey, isAuthenticated);
  prefs.setString(rtKey, refreshToken);
  prefs.setString(atKey, accessToken);
  prefs.setInt(teKey, tokenExpiryIn);
  prefs.setInt(mtKey, madeTokenAt);
}

final Color headerColor = Colors.black54;
final String browserTitle = "The Looking Glass";
final String protocol = "https://";
final String apiURL = "/api/v1/";
final String apiTimelinePath = "timelines/";
final String instanceInfoPath = "instance";
final String sourceURL = "https://git.frinkel.tech/root/looking-glass";
final String appDescription = "A reconnaissance tool for quickly displaying public "
    "posts from any social media website compatible with the Mastodon API.";
final RegExp urlGrabber = RegExp(r"(https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,12}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*))");
final String errorFetching = "There was an error fetching the data.\nPlease try again later.";
final String emptyFetching = "Nothing new!";
final String sameViewFetching = "Refreshing current page...";
final List<String> nonCompliantInstances = ["gab.com","gab.ai"];

/// These are escaped because otherwise it won't work. :V
final String clientName = "Looking%20Glass";
final String redirectURI = "lglass%3A%2F%2Ffedi-auth";
final String scopes = "write%20read%20follow%20push";
final String sourceURLEscaped = "https%3A%2F%2Fgit.frinkel.tech%2Froot%2Flooking-glass";
final String appRegisterPath = "/api/v1/apps?client_name=" + clientName +
    "&redirect_uris=" + redirectURI + "&scopes=" + scopes + "&website=" + sourceURLEscaped;

String nextURL = protocol + targetInstance + apiURL + apiTimelinePath + timelineType;
String prevURL = protocol + targetInstance + apiURL + apiTimelinePath + timelineType;
String latestURL = protocol + targetInstance + apiURL + apiTimelinePath + timelineType;
String instanceInfo = protocol + targetInstance + apiURL + instanceInfoPath;
String latestHomeURL;
String nextHomeURL;
String prevHomeURL;