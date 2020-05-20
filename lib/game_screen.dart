import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tictactoe/player.dart';
import 'package:tictactoe/stomp/event_handler.dart';

class GamePage extends StatefulWidget {
  final String gameId;
  final Player player;
  final String opponentName;
  final bool isOpeningMove;
  final EventHandler eventHandler;

  const GamePage({Key key,
    this.gameId,
    this.player,
    this.opponentName,
    this.isOpeningMove,
    this.eventHandler})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => GamePageState(isOpeningMove);

  String getMySymbol() {
    return isOpeningMove ? "0" : "X";
  }

  String getOpponentSymbol() {
    return isOpeningMove ? "X" : "0";
  }
}

enum GameOverResult { draw, player_won, opponent_won }

class GamePageState extends State<GamePage> {
  final List<List> _field = [
    ["", "", ""],
    ["", "", ""],
    ["", "", ""]
  ];

  var _isMyTurn;
  var _gameOverResult;

  GamePageState(this._isMyTurn);

  @override
  Widget build(BuildContext context) {
    _subscribeToEvents();
    return WillPopScope(
      onWillPop: _onBackButtonPressed(),
      child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildHeader(),
                  Divider(thickness: 3, color: Colors.blueGrey),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: _headerWidget(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: _buildField(),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Visibility(
                          visible: _gameOverResult != null,
                          child: _getExitButton()))
                ],
              ),
            ),
          )),
    );
  }

  Function _onBackButtonPressed() {
    if (_gameOverResult != null) {
      return () async => false;
    } else {
      return () =>
          showDialog<bool>(
              context: context, builder: (c) => _confirmLeaveAlert(c));
    }
  }

  Widget _confirmLeaveAlert(BuildContext context) {
    return AlertDialog(
      title: Text('Warning'),
      content: Text('Want to leave? Will count as a loss'),
      actions: [
        FlatButton(
          child: Text('Yes'),
          onPressed: () {
            _sendLeaveGame();
            Navigator.pop(context, true);
          },
        ),
        FlatButton(
          child: Text('No'),
          onPressed: () => Navigator.pop(context, false),
        ),
      ],
    );
  }

  void _sendLeaveGame() {
    http.post("http://192.168.0.14:8080/game/" + widget.gameId + "/leave",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json'
        },
        body: jsonEncode(<String, String>{
          'playerId': widget.player.id,
        }));
  }

  void _subscribeToEvents() {
    widget.eventHandler.onEvent("GameMove", (Map<String, dynamic> eventMap) {
      final wasMyMove = eventMap["playerName"] == widget.player.name;
      setState(() {
        _field[eventMap["y"]][eventMap["x"]] =
        wasMyMove ? widget.getMySymbol() : widget.getOpponentSymbol();
        _isMyTurn = !wasMyMove;
      });
    });

    widget.eventHandler.onEvent("GameWin", (Map<String, dynamic> eventMap) {
      setState(() {
        final playerWon = eventMap["winnerName"] == widget.player.name;
        _gameOverResult =
        playerWon ? GameOverResult.player_won : GameOverResult.opponent_won;
      });
    });

    widget.eventHandler.onEvent("GameDraw", (Map<String, dynamic> eventMap) {
      setState(() {
        _gameOverResult = GameOverResult.draw;
      });
    });
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          children: <Widget>[
            _gameParticipantBadge(
                name: "${widget.player.name} (${widget.getMySymbol()})",
                left: true)
          ],
        ),
        Column(
          children: <Widget>[
            Text("VS",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))
          ],
        ),
        Column(
          children: <Widget>[
            _gameParticipantBadge(
                name: "${widget.opponentName} (${widget.getOpponentSymbol()})",
                left: false)
          ],
        )
      ],
    );
  }

  Widget _gameParticipantBadge({String name, bool left}) {
    final padding = left
        ? const EdgeInsets.only(left: 20)
        : const EdgeInsets.only(right: 20);
    return Padding(
      padding: padding,
      child: SizedBox(
          width: 100,
          child: Text(name,
              textAlign: left ? TextAlign.left : TextAlign.right,
              style: TextStyle(fontSize: 20))),
    );
  }

  Widget _headerWidget() {
    if (_gameOverResult == null) {
      final text = _isMyTurn ? "Your turn" : "${widget.opponentName}'s turn";
      return Text(text,
          style: TextStyle(
              fontSize: 20,
              color: _isMyTurn ? Colors.greenAccent : Colors.redAccent));
    } else {
      final text = _getGameOverText();
      return Text(text,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: _getGameOverColor()));
    }
  }

  String _getGameOverText() {
    if (_gameOverResult == GameOverResult.draw) {
      return "Draw ¯\\_(ツ)_/¯";
    } else if (_gameOverResult == GameOverResult.player_won) {
      return "YOU'VE WON! Yay! :)";
    } else {
      return "You've lost :(";
    }
  }

  Color _getGameOverColor() {
    if (_gameOverResult == GameOverResult.draw) {
      return Colors.yellow;
    } else if (_gameOverResult == GameOverResult.player_won) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  Widget _buildField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey,
      ),
      child: GridView(
        padding: EdgeInsets.all(5.0),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 3,
        ),
        children: <Widget>[
          _buildCell(0, 0),
          _buildCell(1, 0),
          _buildCell(2, 0),
          _buildCell(0, 1),
          _buildCell(1, 1),
          _buildCell(2, 1),
          _buildCell(0, 2),
          _buildCell(1, 2),
          _buildCell(2, 2)
        ],
      ),
    );
  }

  Widget _buildCell(int x, int y) {
    return Container(
      child: SizedBox(
          width: 50,
          height: 50,
          child: MaterialButton(
            color: Colors.white,
            disabledColor: Colors.white70,
            onPressed: _gameOverResult == null && _isMyTurn
                ? () => {_sendMove(x, y)}
                : null,
            child: Text(_field[y][x], style: TextStyle(fontSize: 50)),
          )),
    );
  }

  void _sendMove(int x, int y) {
    print("Sending x and y: " + x.toString() + "; " + y.toString());
    http.post(
      "http://192.168.0.14:8080/game/" + widget.gameId + "/move",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json'
      },
      body: jsonEncode(<String, String>{
        'playerId': widget.player.id,
        'x': x.toString(),
        'y': y.toString(),
      }),
    );
  }

  Widget _getExitButton() {
    return RaisedButton(
      onPressed: () {
        if (_gameOverResult == null) {
          _sendLeaveGame();
        }
        Navigator.pop(context);
      },
      child: Center(child: Text('Leave game')),
    );
  }
}
