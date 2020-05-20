import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tictactoe/matchmaking_page.dart';
import 'package:tictactoe/player.dart';
import 'package:tictactoe/stomp/event_handler.dart';
import 'package:uuid/uuid.dart';

import 'stomp/stomp_client.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  var _loginErrorText = null;

  @override
  Widget build(BuildContext context) {
    final nameText = TextEditingController();
    return Scaffold(
      body: Container(
        width: 400,
        constraints: const BoxConstraints.expand(),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    child: SizedBox(
                        height: 350.0,
                        child: Image.asset("logo.png", fit: BoxFit.contain))),
                Container(
                    padding: EdgeInsets.only(top: 30),
                    width: 300.0,
                    child: _buildUsernameField(nameText)),
                Container(
                    child: Container(
                        width: 300.0,
                        padding: const EdgeInsets.only(top: 20.0),
                        child: _buildLoginButton(nameText)))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField(TextEditingController textController) {
    return TextField(
      style: style,
      controller: textController,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Name",
          errorText: _loginErrorText,
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(20.0))),
    );
  }

  Widget _buildLoginButton(TextEditingController nameText) {
    return Material(
      borderRadius: BorderRadius.circular(20.0),
      color: Colors.blueGrey,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          final loginError = validateLoginErrors(nameText.text);
          if (loginError != null) {
            setState(() {
              _loginErrorText = loginError;
            });
            return;
          }

          http
              .post(
            "https://tictac-api.beresnev.me/registration",
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json'
            },
            body: jsonEncode(<String, String>{
              'name': nameText.text,
            }),
          )
              .then((response) {
            if (response.statusCode == 200) {
              final player = Player.fromJson(json.decode(response.body));
              final eventHandler = _stompSubscribe(player.id);

              // hide keyboard if shown to avoid pixel overflow errors on next page
              FocusScope.of(context).unfocus();
              Navigator.of(context).push(
                  MaterialPageRoute<Scaffold>(builder: (BuildContext context) {
                    return MatchmakingPage(
                        player: player, eventHandler: eventHandler);
                  }));
            } else if (response.statusCode == 409) {
              setState(() {
                _loginErrorText = "Name already taken";
              });
            } else {
              setState(() {
                _loginErrorText = "Unsuccessful: $response";
              });
            }
          });
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  String validateLoginErrors(String login) {
    if (login.isEmpty) {
      return "Am I a joke to you?";
    } else if (login.contains(" ")) {
      return "Cannot contain whitespaces";
    } else if (login.length > 15) {
      return "Cannot be over 15 chars";
    } else {
      return null;
    }
  }

  EventHandler _stompSubscribe(String playerId) {
    final eventHandler = EventHandler();
    connect("wss://tictac-api.beresnev.me/ws/stomp/websocket").then((client) {
      client.subscribeString(Uuid().v4(), "/user/events",
              (Map<String, String> headers, String message) {
            final eventMap = json.decode(message);
            final eventName = eventMap["eventName"];
            eventHandler.handle(eventName, eventMap);
          });
      client.sendString("/app/link-acc", "$playerId");
    });
    return eventHandler;
  }
}
