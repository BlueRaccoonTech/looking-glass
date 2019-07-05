// A class for parsing JSON-encoded accounts pulled from Mastodon API.

class Account {
  final String id;
  final String username;
  final String acct;
  final String displayName;
  final bool locked;
  final String createdAt;
  final int followersCount;
  final int followingCount;
  final int statusesCount;
  final String note;
  final String url;
  final String avatar;
  final String header;
  //final Account moved; TODO: Handle null properly.
  final bool bot;

  Account({this.id, this.username, this.acct, this.displayName,
    this.locked, this.createdAt, this.followersCount,
    this.followingCount, this.statusesCount, this.note,
    this.url, this.avatar, this.header, this.bot});

  factory Account.fromJson(Map<String, dynamic> json){
    String finalDisplay;
    if (json['display_name'] == "") {
      finalDisplay = json['username'];
    } else {
      finalDisplay = json['display_name'];
    }
    return Account(
      id: json['id'],
      username: json['username'],
      acct: json['acct'],
      displayName: finalDisplay,
      locked: json['locked'],
      createdAt: json['created_at'],
      followersCount: json['followers_count'],
      followingCount: json['following_count'],
      statusesCount: json['statuses_count'],
      note: json['note'],
      url: json['url'],
      avatar: json['avatar'],
      header: json['header'],
      //moved: Account.fromJson(json['moved']),
      bot: json['bot']
    );
  }
}