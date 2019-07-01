import 'dart:async';
import 'package:http/http.dart' as http;
import 'settings.dart';

class APIConnector {
  static Future getTimeline() {
    String urlOptions = "?maxPosts=" + maxPosts.toString();
    if (localOnly) {
      urlOptions = urlOptions + "&local=true";
    }
    var url = "https://" + targetInstance + apiURL + apiTimelinePath + timelineType + urlOptions;
//    var url = baseUrl + "/api/v1/accounts/1/statuses?limit=40";
    return http.get(url);
  }
}