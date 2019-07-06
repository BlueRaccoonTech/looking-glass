import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/rendering.dart';

import 'dart:convert';
import 'mstdn_status.dart';
import 'mstdn_api.dart';
import 'mstdn_info.dart';
import 'interface.dart';
import 'settings.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/io_client.dart';

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
  bool tlFetchInProgress = false;
  bool infoFetchInProgress = false;
  bool scrollToTopVisible = false;
  IOClient legitHTTP = new IOClient();
  final errorSnackBar = SnackBar(
      content: Text(errorFetching,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.red,
  );
  final emptySnackBar = SnackBar(
    content: Text(emptyFetching,
    textAlign: TextAlign.center,
    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
  ),
    backgroundColor: Colors.red,
  );
  final sameViewSnackBar = SnackBar(
    content: Text(sameViewFetching,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    ),
    backgroundColor: Colors.blue,
  );
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _fetchTimeline(int selector) async {
    tlFetchInProgress = true;
    uiLoadingTL.setMessage("Loading " + targetInstance + "...");
    uiLoadingTL.show();
    await APIConnector.getTimeline(selector, legitHTTP).then((response) {
      if (response.statusCode != 200) {
        if (!infoFetchInProgress && uiLoadingTL.isShowing()) {
          uiLoadingTL.hide();
        }
        tlFetchInProgress = false;
        _scaffoldKey.currentState.showSnackBar(errorSnackBar);
      } else if(response.body == "[]") {
        if (!infoFetchInProgress && uiLoadingTL.isShowing()) {
          uiLoadingTL.hide();
        }
        tlFetchInProgress = false;
        _scaffoldKey.currentState.showSnackBar(emptySnackBar);
      } else {
        setState(() {
          String ucNavURLs = response.headers["link"];
          Iterable cleanNavURLs = urlGrabber.allMatches(ucNavURLs);
          nextURL = cleanNavURLs.elementAt(0).group(0).toString();
          prevURL = cleanNavURLs.elementAt(1).group(0).toString();
          Iterable list = json.decode(response.body);
          timeline = list.map((model) => Status.fromJson(model)).toList();
          if (!infoFetchInProgress && uiLoadingTL.isShowing()) {
            uiLoadingTL.hide();
          }
          tlFetchInProgress = false;
        });
      }
    });
  }

  _fetchInstanceInfo() async {
    infoFetchInProgress = true;
    uiLoadingTL.show();
    await APIConnector.getInformation(legitHTTP).then((response) {
      if (response.statusCode != 200 || response.body == "[]") {
        if (!tlFetchInProgress && uiLoadingTL.isShowing()) {
          uiLoadingTL.hide();
        }
        infoFetchInProgress = false;
        _scaffoldKey.currentState.showSnackBar(errorSnackBar);
      } else {
        setState(() {
          targetInstanceInfo = Instance.fromJson(json.decode(response.body));
          if (!tlFetchInProgress && uiLoadingTL.isShowing()) {
            uiLoadingTL.hide();
          }
          infoFetchInProgress = false;
        });
      }
    });
  }

  updateInstance() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (specifyAnInstance.text != '') {
      targetInstance = specifyAnInstance.text;
    }
    _fetchInstanceInfo();
    _fetchTimeline(0);
    _scrollToTop();
  }

  _scrollToTop() {
    _plzScrollForMe.animateTo(_plzScrollForMe.position.minScrollExtent,
        duration: Duration(milliseconds: 1000), curve: Curves.easeIn);
    setState((){
      scrollToTopVisible = false;
    });
  }

  Future<void> _refreshTimeline() async {
    _fetchTimeline(3);
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
          child: RefreshIndicator(
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
                            leading:
                            Image.network(timeline[index].account.avatar),
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
            onRefresh: _refreshTimeline,
          ),
        );
  }

  Widget instanceInfo() {
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
      child: Card(
        color: Color.fromARGB(230, 255, 255, 255),
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  text: targetInstanceInfo?.title ?? "Untitled Instance",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Divider(
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              MarkdownBody(
                data: targetInstanceInfo?.description ?? "Track 1",
                onTapLink: (href) {
                  launch(href);
                },
              ),
              Divider(
                color: Color.fromARGB(0, 0, 0, 0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    onPressed: null,
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.person, color: Colors.blue),
                        Text(
                          "Users: \n" +
                              (targetInstanceInfo?.stats?.userCount
                                      .toString() ??
                                  "0"),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  FlatButton(
                    onPressed: null,
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.message, color: Colors.green),
                        Text(
                          "Posts: \n" +
                              (targetInstanceInfo?.stats?.statusCount
                                      .toString() ??
                                  "0"),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  FlatButton(
                    onPressed: null,
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.cloud, color: Colors.black),
                        Text(
                          "Peers: \n" +
                              (targetInstanceInfo?.stats?.peerCount
                                      .toString() ??
                                  "0"),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                color: Color.fromARGB(0, 0, 0, 0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    onPressed: null,
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.spellcheck, color: Colors.deepPurple),
                        Text(
                          "Max Post\nLength: " +
                              (targetInstanceInfo?.postLength.toString() ??
                                  "500"),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                height: 32,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  initState() {
    super.initState();
    _plzScrollForMe = ScrollController();
    _plzScrollForMe.addListener((){
      if(!scrollToTopVisible && _plzScrollForMe.position.userScrollDirection == ScrollDirection.reverse) {
        setState(() {
          scrollToTopVisible = true;
        });
      }
    });
    SchedulerBinding.instance.addPostFrameCallback((_) =>
        uiLoadingTL = new ProgressDialog(context, ProgressDialogType.Normal));
    SchedulerBinding.instance.addPostFrameCallback((_) => _fetchInstanceInfo());
    SchedulerBinding.instance.addPostFrameCallback((_) => _fetchTimeline(0));
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
        initialIndex: 1,
        child: Scaffold(
          key: _scaffoldKey,
          bottomNavigationBar: ColoredTabBar(
            Colors.black87,
            TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.info_outline),
                  //text: "Instance Info",
                ),
                Tab(
                  icon: Icon(Icons.list),
                  //text: "Public Timeline"
                ),
              ],
            ),
          ),
          floatingActionButton: Visibility(
            visible: scrollToTopVisible,
            child: FloatingActionButton(
              onPressed: _scrollToTop,
              child: Icon(Icons.arrow_upward),
            ),
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
                  semanticLabel: 'Older',
                ),
                onPressed: () {
                  _fetchTimeline(1);
                  _scrollToTop();
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward,
                  semanticLabel: 'Newer',
                ),
                onPressed: () {
                  if (timeline.length < maxPosts) {
                    _scaffoldKey.currentState.showSnackBar(sameViewSnackBar);
                    _fetchTimeline(3);
                  } else {
                    _fetchTimeline(2);
                  }
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
