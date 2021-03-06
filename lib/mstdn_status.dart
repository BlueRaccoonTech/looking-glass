// A class for parsing JSON-encoded statuses pulled from Mastodon API.
import 'mstdn_acct.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:intl/intl.dart';
import 'package:http/io_client.dart' as http;
import 'settings.dart';
import 'dart:io';
import 'dart:convert';
import 'main.dart';

class Status {
  final String id;
  final String url;
  final Account account;
  final String inReplyToId;
  final String inReplyToAccountId;
  final Status reblog; //TODO: Figure out a way to evaluate if null or not.
  final String content;
  final String createdAt;
  final int repliesCount;
  final int reblogsCount;
  final int favouritesCount;
  final bool reblogged;
  final bool favourited;
  final bool muted;
  final bool sensitive;
  final String subjectText;
  final String visibility;
  final String language;
  final bool pinned;
  bool isInvisible;

  Status({this.id, this.url, this.account, this.inReplyToId,
    this.inReplyToAccountId, this.reblog, this.content,
    this.createdAt, this.repliesCount, this.reblogsCount,
    this.favouritesCount, this.reblogged, this.favourited,
    this.muted, this.sensitive, this.subjectText,
    this.visibility, this.language, this.pinned, this.isInvisible});

  factory Status.fromJson(Map<String, dynamic> parsedJson) {
    Account tempAccount = Account.fromJson(parsedJson['account']);
    if (parsedJson['reblog'] != null) {
      Status tempReblog = Status.fromJson(parsedJson['reblog']);
      tempAccount = tempReblog.account;
    }

    return Status(
      id: parsedJson['id'],
      url: parsedJson['url'],
      account: tempAccount,
      inReplyToId: parsedJson['in_reply_to_id'],
      inReplyToAccountId: parsedJson['in_reply_to_account_id'],
      //reblog: tempReblog,
      content: html2md.convert(parsedJson['content']),
      createdAt: DateFormat.yMEd().add_jms().format(DateTime.parse(parsedJson['created_at']).toLocal()),
      repliesCount: parsedJson['replies_count'],
      reblogsCount: parsedJson['reblogs_count'],
      favouritesCount: parsedJson['favourites_count'],
      reblogged: parsedJson['reblogged'],
      favourited: parsedJson['favourited'],
      muted: parsedJson['muted'],
      sensitive: parsedJson['sensitive'],
      subjectText: parsedJson['spoiler_text'],
      visibility: parsedJson['visibility'],
      language: parsedJson['language'],
      pinned: parsedJson['pinned'],
      isInvisible: !parsedJson['spoiler_text'].isNotEmpty,
    );
  }
}

void favoriteStatus(http.IOClient client, String postID) async {
  // statuses/:id/favourite
  if(isAuthenticated) {
    String favPostURL = "https://" + loginInstance + apiURL + "statuses/" +
        postID + "/favourite";
    final response = await client.post(favPostURL, headers: {HttpHeaders.authorizationHeader: "Bearer " + accessToken});
    if(response.statusCode != 200) {
      throw Exception("Ran head-first into an issue faving that post, sorry.");
    }
  }
}

void reblogStatus(http.IOClient client, String postID) async {
  // statuses/:id/favourite
  if(isAuthenticated) {
    String reblogPostURL = "https://" + loginInstance + apiURL + "statuses/" +
        postID + "/reblog";
    final response = await client.post(reblogPostURL, headers: {HttpHeaders.authorizationHeader: "Bearer " + accessToken});
    if(response.statusCode != 200) {
      throw Exception("Ran head-first into an issue reblogging that post, sorry.");
    }
  }
}

Future<Status> snedPost(http.IOClient client, String visibility, String status, String subject) async {
  String subjectURLPart = "";

  if (subject != null) {
    subjectURLPart = "&spoiler_text=" + subject;
  }
  String postURL = "https://" + loginInstance + "/api/v1/statuses?visibility="
    + visibility + subjectURLPart + "&status=" + status;
  final response = await client.post(postURL, headers: {HttpHeaders.authorizationHeader: "Bearer " + accessToken});
  // TODO: Add idempotency key to headers created at opening of message composer
  if(response.statusCode != 200) {
    throw Exception("Something went wrong while revoking credentials.");
  }
  scaffoldKey.currentState.showSnackBar(sentPostSnackBar);
  return Status.fromJson(json.decode(response.body));
}