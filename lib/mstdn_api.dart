import 'dart:async';
import 'package:http/io_client.dart';
import 'settings.dart';

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
    instanceInfo = protocol + targetInstance + apiURL + instanceInfoPath;
    return client.get(instanceInfo);
  }
}