import 'dart:async';
import 'package:http/io_client.dart';
import 'settings.dart';
import 'dart:io';

class APIConnector {
  static Future getTimeline(int selector, IOClient client) {
    if (selector == 0) {
      String urlOptions = "?maxPosts=" + maxPosts.toString();
      if (localOnly) {
        urlOptions = urlOptions + "&local=true";
      }
      latestURL = "https://" + targetInstance + apiURL + apiTimelinePath + timelineType + urlOptions;
//    var url = baseUrl + "/api/v1/accounts/1/statuses?limit=40";
    } else if (selector == 1) {
      latestURL = nextURL;
    } else if (selector == 2) {
      latestURL = prevURL;
    }

    return client.get(latestURL);
  }
  static Future getInformation(IOClient client) {
    if(isAuthenticated ?? false) {
      instanceInfo = "https://" + loginInstance + apiURL + instanceInfoPath;
    } else {
      instanceInfo = "https://" + targetInstance + apiURL + instanceInfoPath;
    }
    return client.get(instanceInfo);
  }

  static Future getHomeTimeline(int selector, IOClient client) {
    if (!isAuthenticated) {
      throw Exception("Not signed in!");
    } else {
      latestHomeURL = "https://" + loginInstance + apiURL + apiTimelinePath + "home?maxPosts=" + maxPosts.toString();
      if (selector == 0) {
      } else if (selector == 1) {
        latestHomeURL = nextHomeURL;
      } else if (selector == 2) {
        latestHomeURL = prevHomeURL;
      }
      return client.get(latestHomeURL, headers: {HttpHeaders.authorizationHeader: "Bearer " + accessToken});
    }
  }
}