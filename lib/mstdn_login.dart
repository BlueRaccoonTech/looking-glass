/// Here it is, the file that's going to give me a headache to write.
import 'package:looking_glass/settings.dart';
import 'package:http/io_client.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';


/// First, let's define the response to /api/v1/apps...

class FediApp {
  final String clientID;
  final String clientSecret;

  FediApp({this.clientID, this.clientSecret});

  factory FediApp.fromJson(Map<String, dynamic> json){
    return FediApp(
      clientID:     json['client_id'],
      clientSecret: json['client_secret'],
    );
  }
}

/// Now what we should (hopefully) get back from the OAuth flow...
class OAuthToken {
  final String refreshToken;
  final int expiresIn;
  final int createdAt;
  final String accessToken;

  OAuthToken({this.refreshToken, this.expiresIn, this.createdAt,
    this.accessToken});

  factory OAuthToken.fromJson(Map<String, dynamic> json){
    return OAuthToken(
      refreshToken: json['refresh_token'] ?? "mastodon",
      expiresIn:    json['expires_in'] ?? 0,
      createdAt:    json['created_at'],
      accessToken:  json['access_token'],
    );
  }
}

/// Checks for known non-compliance with software license.
void checkLicenseCompliance(String instance) {
  if (nonCompliantInstances.contains(instance)) {
    exit(0); // TODO: Figure out a better way to block nazis than insta-crash
    // If, somehow, it's still running...
    throw Exception("App Usage Non-Compliant With License");
  }
}

/// Registers app with login instance.
Future<FediApp> registerApp(http.IOClient client) async {
  String siteToRegisterFrom = "https://" + loginInstance + appRegisterPath;
  final response = await client.post(siteToRegisterFrom);
  if(response.statusCode == 200) {
    return FediApp.fromJson(json.decode(response.body));
  } else {
    throw Exception("Could not register app with " + loginInstance + ".");
  }
}

/// Converts one-time auth code into an oAuth token compatible with communication.
Future<OAuthToken> instanceAuth(http.IOClient client, String authCode) async {
  String finalAuthURL = "https://" + loginInstance + "/oauth/token?client_id="
      + clientID + "&client_secret=" + clientSecret + "&grant_type=authorization_code"
      "&code=" + authCode + "&redirect_uri=" + redirectURI;
  final response = await client.post(finalAuthURL);
  if(response.statusCode == 200) {
    return OAuthToken.fromJson(json.decode(response.body));
  } else {
    throw Exception("Failed to authenticate with " + loginInstance + ".");
  }
}

void revokeLoginCredentials(http.IOClient client) async {
  String revokeURL = "https://" + loginInstance + "/oauth/revoke?client_id="
  + clientID + "&client_secret=" + clientSecret + "&token=" + accessToken;
  final response = await client.post(revokeURL);
  if(response.statusCode != 200) {
    throw Exception("Something went wrong while revoking credentials.");
  }
}