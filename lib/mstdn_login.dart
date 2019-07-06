/// Here it is, the file that's going to give me a headache to write.
import 'package:looking_glass/settings.dart';
import 'package:http/http.dart' as http;
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
      refreshToken: json['refresh_token'] ?? 0,
      expiresIn:    json['expires_in'] ?? 0,
      createdAt:    json['created_at'],
      accessToken:  json['access_token'],
    );
  }
}

/// What if my app got big enough for nazis and TERFs to want to use?
/// Well, it's licensed by a license that bars them, sooo...
/// let's just make sure they're compliant ;)
void checkLicenseCompliance(String instance) {
  if (nonCompliantInstances.contains(instance)) {
    exit(0);
    // If, somehow, it's still running...
    throw Exception("App Usage Non-Compliant With License");
  }
}

/// "Now, Frinkel", you might be asking yourself,
/// "That's a pretty damn simple line of code to circumvent."
/// "Couldn't nazis just fork your code and remove that line?"
/// To which I say, only if they want to get in legal trouble.
/// Your move, you discriminatory pieces of work. :)

/// Anyways, this will actually register the app.
Future<FediApp> registerApp(http.Client client) async {
  final response = await client.get(protocol + loginInstance + appRegisterPath);
  if(response.statusCode == 200) {
    return FediApp.fromJson(json.decode(response.body));
  } else {
    throw Exception("Could not register app with " + loginInstance + ".");
  }
}

Future<OAuthToken> instanceAuth(http.Client client, String authCode) async {
  String finalAuthURL = protocol + loginInstance + "/oauth/token?client_id="
      + clientID + "&client_secret=" + clientSecret + "&grant_type=authorization_code"
      "&code=" + authCode + "&redirect_uri=" + redirectURI;
  final response = await client.get(finalAuthURL);
  if(response.statusCode == 200) {
    return OAuthToken.fromJson(json.decode(response.body));
  } else {
    throw Exception("Failed to authenticate with " + loginInstance + ".");
  }
}
