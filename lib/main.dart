import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'mstdn_status.dart';
import 'mstdn_api.dart';

import 'package:flutter_markdown/flutter_markdown.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Image rawImg;
  String instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A Fresh Post from TFTown',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyListScreen(),
    );
  }
}

class MyListScreen extends StatefulWidget {
  @override
  createState() => _MyListScreenState();
}

class _MyListScreenState extends State {
  var timeline = new List<Status>();

  _getUsers() {
    APIConnector.getTimeline().then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        timeline = list.map((model) => Status.fromJson(model)).toList();
      });
    });
  }

  initState() {
    super.initState();
    _getUsers();
  }

  dispose() {
    super.dispose();
  }

  @override
  build(context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Frinkel's Posts and Reblogs"),
        ),
        body: ListView.builder(
          itemCount: timeline.length,
          itemBuilder: (context, index) {
            return Card(
              clipBehavior: Clip.antiAlias,
              elevation: 5.0,
              margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                      child: ListTile(
                        leading: Image.network(timeline[index].account.avatar),
                        title: Text(
                          timeline[index].account.displayName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(timeline[index].account.acct),
                      )
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Visibility(
                      visible: timeline[index].subjectText.isNotEmpty,
                      child: Text(
                        timeline[index].subjectText,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: timeline[index].subjectText.isNotEmpty,
                    child: Divider(),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: MarkdownBody(data: timeline[index].content),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, 20),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(5, 0, 4, 0),
                          child: Icon(
                            Icons.reply,
                            color: Colors.blue,
                            size: 30.0,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(4, 0, 20, 0),
                          child: Text(
                            timeline[index].repliesCount.toString(),
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 4, 0),
                          child: Icon(
                            Icons.settings_input_antenna,
                            color: Colors.green,
                            size: 30.0,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(4, 0, 20, 0),
                          child: Text(
                            timeline[index].reblogsCount.toString(),
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 4, 0),
                          child: Icon(
                            Icons.favorite,
                            color: Colors.orange,
                            size: 30.0,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(4, 0, 20, 0),
                          child: Text(
                            timeline[index].favouritesCount.toString(),
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }
}