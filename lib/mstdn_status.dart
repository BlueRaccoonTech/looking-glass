// A class for parsing JSON-encoded statuses pulled from Mastodon API.
import 'mstdn_acct.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:intl/intl.dart';

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

  Status({this.id, this.url, this.account, this.inReplyToId,
    this.inReplyToAccountId, this.reblog, this.content,
    this.createdAt, this.repliesCount, this.reblogsCount,
    this.favouritesCount, this.reblogged, this.favourited,
    this.muted, this.sensitive, this.subjectText,
    this.visibility, this.language, this.pinned});

  factory Status.fromJson(Map<String, dynamic> parsedJson) {
    Account tempAccount = Account.fromJson(parsedJson['account']);
    if (parsedJson['reblog'] != null) {
      Status tempReblog = Status.fromJson(parsedJson['reblog']);
      tempAccount = tempReblog.account;
    }

    DateTime convertedTime = DateTime.parse(parsedJson['created_at']).toLocal();
    String readableTime = DateFormat.yMEd().add_jms().format(convertedTime);
    return Status(
      id: parsedJson['id'],
      url: parsedJson['url'],
      account: tempAccount,
      inReplyToId: parsedJson['in_reply_to_id'],
      inReplyToAccountId: parsedJson['in_reply_to_account_id'],
      //reblog: tempReblog,
      content: html2md.convert(parsedJson['content']),
      createdAt: readableTime,
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
      pinned: parsedJson['pinned']
    );
  }
}