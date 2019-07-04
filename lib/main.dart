import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

import 'dart:convert';
import 'mstdn_status.dart';
import 'mstdn_api.dart';
import 'mstdn_info.dart';
import 'interface.dart';
import 'settings.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:progress_dialog/progress_dialog.dart';
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
  ProgressDialog uiLoadingTL;
  ScrollController _plzScrollForMe;
  Instance targetInstanceInfo;

  _fetchTimeline(int selector) {
    uiLoadingTL = new ProgressDialog(context, ProgressDialogType.Normal);
    uiLoadingTL.setMessage("Loading " + targetInstance + "...");
    uiLoadingTL.show();
    APIConnector.getTimeline(selector).then((response) {
      setState(() {
        String UCNavURLs = response.headers["link"];
        Iterable CleanNavURLs = urlGrabber.allMatches(UCNavURLs);
        nextURL = CleanNavURLs.elementAt(0).group(0).toString();
        prevURL = CleanNavURLs.elementAt(1).group(0).toString();
        Iterable list = json.decode(response.body);
        timeline = list.map((model) => Status.fromJson(model)).toList();
        uiLoadingTL.hide();
      });
    });
  }

  _fetchInstanceInfo() {
    uiLoadingTL.show();
    APIConnector.getInformation().then((response) {
      setState(() {
        targetInstanceInfo = Instance.fromJson(json.decode(response.body));
        uiLoadingTL.hide();
      });
    });
  }

  updateInstance() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (specifyAnInstance.text != '') {
      targetInstance = specifyAnInstance.text;
    }
    _fetchTimeline(0);
    _fetchInstanceInfo();
    _scrollToTop();
  }

  _scrollToTop() {
    _plzScrollForMe.animateTo(_plzScrollForMe.position.minScrollExtent,
        duration: Duration(milliseconds: 1000), curve: Curves.easeIn);
  }

  Widget timelineViewer() {
    return Container(
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
        controller: _plzScrollForMe,
        itemCount: timeline.length,
        itemBuilder: (context, index) {
          return Card(
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            color: Color.fromARGB(210, 255, 255, 255),
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: ListTile(
                      leading: Image.network(timeline[index].account.avatar),
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
                  height: 0,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                Container(
                  child: InkWell(
                    child: Visibility(
                      visible: timeline[index].subjectText.isNotEmpty,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Text(
                          timeline[index].subjectText,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        if (timeline[index].isInvisible == false) {
                          timeline[index].isInvisible = true;
                        } else {
                          timeline[index].isInvisible = false;
                        }
                      });
                    },
                  ),
                ),

                Visibility(
                  visible: timeline[index].subjectText.isNotEmpty,
                  child: Divider(
                    height: 0,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                Visibility(
                  visible: timeline[index].isInvisible,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: MarkdownBody(
                      data: timeline[index].content,
                      onTapLink: (href) {
                        launch(href);
                      },
                    ),
                  ),
                ),
                Divider(
                  height: 0,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: interactionBar(
                      timeline[index].repliesCount,
                      timeline[index].reblogsCount,
                      timeline[index].favouritesCount,
                      timeline[index].url),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget instanceInfo() {
    //return Text("To Be Implemented");
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RichText(
            text: TextSpan(
              text: targetInstanceInfo.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          Divider(
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          MarkdownBody(
            data: targetInstanceInfo.description,
            onTapLink: (href) {
              launch(href);
            },
          ),
        ],
      ),
    );
  }

  initState() {
    super.initState();
    _plzScrollForMe = ScrollController();
    SchedulerBinding.instance.addPostFrameCallback((_) => _fetchTimeline(0));
    SchedulerBinding.instance.addPostFrameCallback((_) => _fetchInstanceInfo());
  }

  dispose() {
    specifyAnInstance.dispose();
    _plzScrollForMe.dispose();
    super.dispose();
  }

  @override
  build(context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          bottomNavigationBar: ColoredTabBar(
            Colors.black87,
            TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.info_outline),
                ),
                Tab(
                  icon: Icon(Icons.list),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _scrollToTop,
            child: Icon(Icons.arrow_upward),
          ),

          /// Header Bar
          appBar: AppBar(
            brightness: Brightness.dark,
            backgroundColor: headerColor,
            leading: IconButton(
              icon: Icon(AppLogo.LookingGlass.crystal_ball),
              onPressed: () {
                showAbout(context);
              },
            ),
            title: Text("The Looking Glass"),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  semanticLabel: '20 Newer',
                ),
                onPressed: () {
                  _fetchTimeline(1);
                  _scrollToTop();
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward,
                  semanticLabel: '20 Older',
                ),
                onPressed: () {
                  _fetchTimeline(2);
                  _scrollToTop();
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  semanticLabel: 'Refresh Current View',
                ),
                onPressed: () {
                  _fetchTimeline(3);
                  _scrollToTop();
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
                          updateInstance();
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
                child: TabBarView(
                  children: [
                    instanceInfo(),
                    timelineViewer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
