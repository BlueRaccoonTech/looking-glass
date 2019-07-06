import 'package:flutter/material.dart';
import 'looking_glass_icons.dart' as AppLogo;
import 'settings.dart';
import 'package:looking_glass/main.dart';
import 'interface.dart';

class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final instanceField = TextField(
      obscureText: false,
      controller: logIntoAnInstance,
      style: TextStyle(fontSize: 20),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20,15,20,15),
        hintText: targetInstance,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
      ),
    );
    final loginButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30.0),
      color: headerColor,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        onPressed: () {
          oauthWorkflow(logIntoAnInstance.text);
        },
        child: Text("Log Into Instance",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          )),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: headerColor,
        leading: Icon(AppLogo.LookingGlass.crystal_ball),
        title: Text("The Looking Glass"),
      ),
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height:45),
                instanceField,
                SizedBox(height:35),
                loginButton,
                SizedBox(height:15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}