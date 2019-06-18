import 'dart:async';
import 'package:http/http.dart' as http;

const baseUrl = "https://transfurrmation.town";

class APIConnector {
  static Future getTimeline() {
//    var url = baseUrl + "/api/v1/timelines/public";
    var url = baseUrl + "/api/v1/accounts/1/statuses?limit=40";
    return http.get(url);
  }
}