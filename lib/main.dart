import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import 'dart:convert';
import 'mstdn_status.dart';
import 'mstdn_api.dart';
import 'interface.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import 'looking_glass_icons.dart' as AppLogo;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
  String targetInstance = "mastodon.social";
  final specifyAnInstance = TextEditingController();

  _getUsers() {
    APIConnector.getTimeline("https://" + targetInstance).then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        timeline = list.map((model) => Status.fromJson(model)).toList();
      });
    });
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Row(
              children: <Widget>[
                Icon(AppLogo.LookingGlass.crystal_ball),
                Text("  The Looking Glass"),
              ],
            ),
            content: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'A reconnaissance tool for quickly displaying public '
                        'posts from any social media website compatible with the '
                        'Mastodon API.\n\n'
                        'App designed and created by ',
                    style: TextStyle(color: Colors.black),
                  ),
                  URLizer.makeURL('Frinkeldoodle', 'https://frinkel.tech',
                    context),
                  TextSpan(
                    text: '.\n\n'
                        'Crystal ball icon made by ',
                    style: TextStyle(color: Colors.black),
                  ),
                  URLizer.makeURL('Freepik', 'https://www.freepik.com/',
                    context),
                  TextSpan(
                    text: ' from ',
                    style: TextStyle(color: Colors.black),
                  ),
                  URLizer.makeURL('flaticon.com', 'https://www.flaticon.com',
                      context),
                  TextSpan(
                    text: '\n\n'
                        'Source: ',
                    style: TextStyle(color: Colors.black),
                  ),
                  URLizer.makeURL('https://git.frinkel.tech/root/looking-glass',
                    'https://git.frinkel.tech/root/looking-glass', context),
                  TextSpan(
                    text: '\n\n'
                        'A few big instances you can try with this app:\n'
                        'pleroma.site\n'
                        'mastodon.social\n'
                        'radical.town\n'
                        'hackers.town',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]);
      },
    );
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
        brightness: Brightness.dark,
        backgroundColor: Colors.black54,
        leading: IconButton(
          icon: Icon(AppLogo.LookingGlass.crystal_ball),
          onPressed: () {
            _showDialog();
          },
        ),
        title: Text("The Looking Glass"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
              semanticLabel: 'Refresh Timeline',
            ),
            onPressed: () {
              _getUsers();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 1, 0),
                child: Text(
                  'https://',
                  style: TextStyle(
                    color: Colors.green,
                    //fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
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
                padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: Container(
                  color: Colors.lightBlueAccent,
                  child: IconButton(
                    icon: Icon(Icons.forward),
                    onPressed: () {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      if (specifyAnInstance.text != '') {
                        targetInstance = specifyAnInstance.text;
                      }
                      _getUsers();
                    },
                  ),
                ),
              ),
            ],
          ),
          Divider(
            height: 0.0,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          Expanded(
            child: Container(
              //color: Colors.blueGrey,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blueGrey,
                    Colors.black87,
                  ],
                ),
              ),
              child: ListView.builder(
                itemCount: timeline.length,
                itemBuilder: (context, index) {
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 0,
                    color: Colors.white70,
                    margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                            child: ListTile(
                              leading:
                                  Image.network(timeline[index].account.avatar),
                              //title: Text(
                              //  timeline[index].account.displayName,
                              //  style: TextStyle(fontWeight: FontWeight.bold),
                              //),
                              title: RichText(
                                text: TextSpan(
                                  text: timeline[index].account.displayName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launch(timeline[index].account.url);
                                    },
                                ),
                              ),
                              subtitle: Text(timeline[index].createdAt),
                            )),
                        Divider(
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Visibility(
                            visible: timeline[index].subjectText.isNotEmpty,
                            child: Text(
                              timeline[index].subjectText,
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: timeline[index].subjectText.isNotEmpty,
                          child: Divider(
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: MarkdownBody(data: timeline[index].content),
                        ),
                        Divider(
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
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
                                padding: EdgeInsets.fromLTRB(4, 0, 15, 0),
                                child: Text(
                                  timeline[index].repliesCount.toString(),
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(15, 0, 4, 0),
                                child: Icon(
                                  Icons.record_voice_over,
                                  color: Colors.green,
                                  size: 30.0,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(4, 0, 15, 0),
                                child: Text(
                                  timeline[index].reblogsCount.toString(),
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(15, 0, 4, 0),
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.deepPurple,
                                  size: 30.0,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(4, 0, 15, 0),
                                child: Text(
                                  timeline[index].favouritesCount.toString(),
                                  style: TextStyle(color: Colors.deepPurple),
                                ),
                              ),
                              Expanded(
                                child: Text(''),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.link,
                                  color: Colors.black,
                                  size: 30.0,
                                ),
                                onPressed: () {
                                  launch(timeline[index].url);
                                },
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
          ),
        ],
      ),
    );
  }
}
