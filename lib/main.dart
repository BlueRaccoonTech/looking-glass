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
import 'mstdn_login.dart';
import 'dart:async';
import 'loginScreen.dart';
import 'dart:io';
import 'composeScreen.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/io_client.dart';
import 'package:uni_links/uni_links.dart';

import 'looking_glass_icons.dart' as AppLogo;
IOClient legitHTTP = new IOClient();

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

void oauthWorkflow(String loggingInInstance) async {

  checkLicenseCompliance(loggingInInstance);
  if(!appRegistered || loginInstance != loggingInInstance) {
    loginInstance = loggingInInstance;

    FediApp appRegistration = await registerApp(legitHTTP);

    appRegistered = true;
    clientID = appRegistration.clientID;
    clientSecret = appRegistration.clientSecret;
    saveClientInfo();
  }

  String authorizeLink = protocol + loginInstance + "/oauth/authorize?"
      "response_type=code&client_id=" + clientID + "&client_secret=" +
      clientSecret + "&redirect_uri=" + redirectURI + "&scope=" + scopes;
  launch(authorizeLink);
}

final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

class _MyListScreenState extends State {
  List timeline = new List<Status>();
  StreamSubscription _subs;
  ProgressDialog uiLoadingTL;
  ScrollController _plzScrollForMe;
  Instance targetInstanceInfo;
  bool tlFetchInProgress = false;
  bool infoFetchInProgress = false;
  bool scrollToTopVisible = false;

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

  _fetchTimeline(int selector) async {
    tlFetchInProgress = true;
    if(isAuthenticated ?? false) {
      uiLoadingTL.setMessage("Loading " + loginInstance + "...");
      uiLoadingTL.show();
      await APIConnector.getHomeTimeline(selector, legitHTTP).then((response) {
        if (response.statusCode != 200) {
          if (!infoFetchInProgress && uiLoadingTL.isShowing()) {
            uiLoadingTL.hide();
          }
          tlFetchInProgress = false;
          scaffoldKey.currentState.showSnackBar(errorSnackBar);
        } else if(response.body == "[]") {
          if (!infoFetchInProgress && uiLoadingTL.isShowing()) {
            uiLoadingTL.hide();
          }
          tlFetchInProgress = false;
          scaffoldKey.currentState.showSnackBar(emptySnackBar);
        } else {
          setState(() {
            String ucNavURLs = response.headers["link"];
            Iterable cleanNavURLs = urlGrabber.allMatches(ucNavURLs);
            nextHomeURL = cleanNavURLs.elementAt(0).group(0).toString();
            prevHomeURL = cleanNavURLs.elementAt(1).group(0).toString();
            Iterable list = json.decode(response.body);
            timeline = list.map((model) => Status.fromJson(model)).toList();
            if (!infoFetchInProgress && uiLoadingTL.isShowing()) {
              uiLoadingTL.hide();
            }
            tlFetchInProgress = false;
          });
        }
      });
    } else {
      uiLoadingTL.setMessage("Loading " + targetInstance + "...");
      uiLoadingTL.show();
      await APIConnector.getTimeline(selector, legitHTTP).then((response) {
        if (response.statusCode != 200) {
          if (!infoFetchInProgress && uiLoadingTL.isShowing()) {
            uiLoadingTL.hide();
          }
          tlFetchInProgress = false;
          scaffoldKey.currentState.showSnackBar(errorSnackBar);
        } else if(response.body == "[]") {
          if (!infoFetchInProgress && uiLoadingTL.isShowing()) {
            uiLoadingTL.hide();
          }
          tlFetchInProgress = false;
          scaffoldKey.currentState.showSnackBar(emptySnackBar);
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
        scaffoldKey.currentState.showSnackBar(errorSnackBar);
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

  /// Login-pertinent stuff begins here.

  void _disposeDeepLinkListener() {
    if (_subs != null) {
      _subs.cancel();
      _subs = null;
    }
  }

  Future<Null> initUniLinks() async {
    try {
      String initialLink = await getInitialLink();
      _checkDeepLink(initialLink);
    } on PlatformException {
    }
  }

  void _initDeepLinkListener() async {
    _subs = getLinksStream().listen((String link) {
      _checkDeepLink(link);
    }, cancelOnError: true);
  }

  void _checkDeepLink(String link) async {
    if (link != null) {
      // I've probably immensely screwed this up. But... YOLO!
      String code = link.substring(link.indexOf(RegExp('code=')) + 5,
          link.indexOf(RegExp('code=')) + 48);

      // So now I've got the auth code... we're on the home stretch!
      OAuthToken userLogin = await instanceAuth(legitHTTP, code);

      // Wow, so if I've somehow made it to this point, then we're logged in.
      // Time to save all those keys.
      setState((){
        isAuthenticated = true;
        accessToken = userLogin.accessToken;
        refreshToken = userLogin.refreshToken;
        madeTokenAt = userLogin.createdAt;
        tokenExpiryIn = userLogin.expiresIn;
        meURL = userLogin.meURL;
      });
      saveLoginInfo();
      _fetchTimeline(0);
      _fetchInstanceInfo();
    }
  }

  void burnLoginCredentials() {
    isAuthenticated = false;
    appRegistered = false;
    accessToken = null;
    refreshToken = null;
    madeTokenAt = null;
    tokenExpiryIn = null;
    meURL = null;
    saveLoginInfo();
    clientID = null;
    clientSecret = null;
    saveClientInfo();
  }

  /// Login-pertinent stuff ends here.

  Future<void> _refreshTimeline() async {
    _fetchTimeline(3);
  }

  Widget returnBasedOnAuth(Widget auth, Widget noAuth) {
    if(isAuthenticated) {
      return auth;
    } else {
      return noAuth;
    }
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
                            subtitle: returnBasedOnAuth(
                              Text(timeline[index].account.acct),
                              Text(timeline[index].createdAt)
                            ),
                          )
                      ),
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
                            timeline[index].id,
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

  Widget lookingGlassDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  AppLogo.LookingGlass.crystal_ball,
                  color: Colors.white,
                ),
                Text(
                  "   " + browserTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: headerColor,
            ),
          ),
          Visibility(
            visible: !(isAuthenticated ?? false),
            child: ListTile(
              title: Text('Login'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ),
          Visibility(
            visible: (isAuthenticated ?? false),
            child: ListTile(
              title: Text('Logout'),
              onTap: () {
                showLogoutDialog(context).then((shouldILogout) {
                  if (shouldILogout) {
                    revokeLoginCredentials(legitHTTP);
                    setState(() {
                      burnLoginCredentials();
                    });
                    updateInstance();
                  } else {
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  initState() {
    readPrefs();
    super.initState();
    initUniLinks();
    _initDeepLinkListener();

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
    logIntoAnInstance.dispose();
    specifyAnInstance.dispose();
    _plzScrollForMe.dispose();
    _disposeDeepLinkListener();
    super.dispose();
  }

  @override
  build(context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        initialIndex: 1,
        child: Scaffold(
          key: scaffoldKey,
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
            visible: (isAuthenticated ?? false),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ComposePageWidget()),
                );
              },
              child: Icon(Icons.message),
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
            title: Text(browserTitle),
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
                    scaffoldKey.currentState.showSnackBar(sameViewSnackBar);
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

          drawer: lookingGlassDrawer(),

          body: Column(
            children: <Widget>[
              Visibility(
                visible: !(isAuthenticated ?? false),
                child: Row(
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
