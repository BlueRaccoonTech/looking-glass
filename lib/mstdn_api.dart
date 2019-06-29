import 'dart:async';
import 'package:http/http.dart' as http;

class APIConnector {
  static Future getTimeline(String baseUrl) {
    var url = "https://" + baseUrl + "/api/v1/timelines/public?local=true";
//    var url = baseUrl + "/api/v1/accounts/1/statuses?limit=40";
    return http.get(url);
  }
}