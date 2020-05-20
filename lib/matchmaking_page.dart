import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:tictactoe/game_screen.dart';
import 'package:tictactoe/stomp/event_handler.dart';

import 'player.dart';

class MatchmakingPage extends StatefulWidget {
  final Player player;
  final EventHandler eventHandler;

  const MatchmakingPage({Key key, this.player, this.eventHandler})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MatchmakingPageState();
}

class _MatchmakingPageState extends State<MatchmakingPage> {
  var _isSearching = false;

  @override
  Widget build(BuildContext context) {
    _initEventHandler();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Center(child: Text("Matchmaking"))),
          body: Center(
            child: Container(
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(child: _buildMatchMakingButton()),
                  Container(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: _buildSearchingProgressBar()),
                ],
              ),
            ),
          )),
    );
  }

  void _initEventHandler() {
    widget.eventHandler.onEvent("GameStarted", (Map<String, dynamic> eventMap) {
      Navigator.of(context)
          .push(MaterialPageRoute<Scaffold>(builder: (BuildContext context) {
        return GamePage(
            gameId: eventMap["gameId"],
            player: widget.player,
            opponentName: eventMap["opponentName"],
            isOpeningMove: eventMap["playersOpeningMove"],
            eventHandler: widget.eventHandler);
      })).then((value) =>
      {
        setState(() {
          _isSearching = false;
        })
      });
    });
  }

  Widget _buildMatchMakingButton() {
    final onPressed = () {
      http
          .post(
        "http://192.168.0.14:8080/matchmaking/" +
            (_isSearching ? "dequeue" : "enqueue"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json'
        },
        body: jsonEncode(<String, String>{'playerId': widget.player.id}),
      )
          .then((response) {
        if (response.statusCode == 200) {
          setState(() {
            _isSearching = !_isSearching;
          });
        }
      });
    };

    return RawMaterialButton(
      onPressed: onPressed,
      elevation: 2.0,
      fillColor: _isSearching ? Colors.red : Colors.blueGrey,
      child: SizedBox(
          height: 250,
          width: 250,
          child: Icon(
            _isSearching ? Icons.pause : Icons.play_arrow,
            size: _isSearching ? 150 : 250,
          )),
      padding: EdgeInsets.all(15.0),
      shape: CircleBorder(),
    );
  }

  Widget _buildSearchingProgressBar() {
    return AnimatedOpacity(
      opacity: _isSearching ? 1.0 : 0.0,
      duration: _isSearching
          ? Duration(milliseconds: 1500)
          : Duration(milliseconds: 300),
      // The green box must be a child of the AnimatedOpacity widget.
      child: Column(
        children: <Widget>[
          Text(
            "Waiting for players",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          SizedBox(height: 30),
          CircularProgressIndicator()
        ],
      ),
    );
  }
}
