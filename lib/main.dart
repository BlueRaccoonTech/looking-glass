import 'package:flutter/material.dart';

import 'dart:convert';
import 'mstdn_status.dart';
import 'mstdn_api.dart';

import 'package:flutter_markdown/flutter_markdown.dart';

import 'looking_glass_icons.dart' as AppLogo;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Image rawImg;
  String instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Looking Glass',
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
  String targetInstance = "pleroma.site";
  final specifyAnInstance = TextEditingController();

  _getUsers() {
    APIConnector.getTimeline("https://" + targetInstance).then((response) {
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
    specifyAnInstance.dispose();
    super.dispose();
  }

  @override
  build(context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(AppLogo.LookingGlass.crystal_ball),
        title: Text("The Looking Glass"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
              semanticLabel: 'Refresh Timeline',
            ),
            onPressed: () {
              _getUsers();
              print('Refreshed!');
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Text('https://'),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                  child: TextField(
                    controller: specifyAnInstance,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: targetInstance,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 15, 0),
                child: IconButton(
                  icon: Icon(Icons.forward),
                  onPressed: () {
                    targetInstance = specifyAnInstance.text;
                    _getUsers();
                  },
                ),
              ),
            ],
          ),
          Divider(
            height: 0.0,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          Expanded(
            child: ListView.builder(
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
                            leading:
                                Image.network(timeline[index].account.avatar),
                            title: Text(
                              timeline[index].account.displayName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(timeline[index].account.acct),
                          )),
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
            ),
          ),
        ],
      ),
    );
  }
}
