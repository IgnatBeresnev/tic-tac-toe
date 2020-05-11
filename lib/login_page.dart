import 'package:flutter/material.dart';
import 'package:tictactoe/matchmaking_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 400,
        constraints: const BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.only(top: 150.0),
                    child: SizedBox(
                        height: 350.0,
                        child: Image.asset("logo.png", fit: BoxFit.contain))),
                Container(
                    padding: EdgeInsets.only(top: 60),
                    width: 300.0,
                    child: _buildUsernameField()),
                Container(
                    child: Container(
                        width: 300.0,
                        padding: const EdgeInsets.only(top: 20.0),
                        child: _buildLoginButton()))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextField(
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Name",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(20.0))),
    );
  }

  Widget _buildLoginButton() {
    return Material(
      borderRadius: BorderRadius.circular(20.0),
      color: Colors.blueGrey,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          // hide keyboard if shown to avoid pixel overflow errors on next page
          FocusScope.of(context).unfocus();
          Navigator.of(context).push(
              MaterialPageRoute<Scaffold>(builder: (BuildContext context) {
            return MatchmakingPage();
          }));
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
