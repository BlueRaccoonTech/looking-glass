// A class for parsing a Mastodon API-compatible instance's info.
import 'package:html2md/html2md.dart' as html2md;

class InstanceStats {
  final int userCount;
  final int statusCount;
  final int peerCount;

  InstanceStats({this.userCount, this.statusCount, this.peerCount});

  factory InstanceStats.fromJson(Map<String, dynamic> json){
    return InstanceStats(
      userCount: json['user_count'],
      statusCount: json['status_count'],
      peerCount: json['domain_count']
    );
  }
}

class Instance {
  final String uri;
  final String title;
  final String description;
  final String email;
  final String version;
  final InstanceStats stats;
  final bool regOpen;
  final String thumbnail;
  final int postLength;


  Instance({this.uri, this.title, this.description, this.email,
    this.version, this.stats, this.regOpen, this.thumbnail, this.postLength});

  factory Instance.fromJson(Map<String, dynamic> parsedJson){
    InstanceStats instNums = InstanceStats.fromJson(parsedJson['stats']);
    return Instance(
      uri: parsedJson['id'],
      title: parsedJson['title'],
      description: html2md.convert(parsedJson['description']),
      email: parsedJson['email'],
      version: parsedJson['version'],
      stats: instNums,
      regOpen: parsedJson['registrations'],
      thumbnail: parsedJson['thumbnail'],
      postLength: parsedJson['max_toot_chars'] ?? 500,
    );
  }
}