import 'dart:async';
import 'package:http/http.dart' as http;
import 'settings.dart';

class APIConnector {
  static Future getTimeline(int selector) {
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
    return http.get(latestURL);
  }
  static Future getInformation() {
    instanceInfo = protocol + targetInstance + apiURL + instanceInfoPath;
    return http.get(instanceInfo);
  }
}