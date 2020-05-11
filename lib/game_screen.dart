import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  final playerName;
  final opponentName;
  final firstTurnPlayerName;

  const GamePage(
      {Key key, this.playerName, this.opponentName, this.firstTurnPlayerName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => GamePageState(
      playerName, opponentName, playerName == firstTurnPlayerName);
}

class GamePageState extends State<GamePage> {
  final _playerName;
  final _opponentName;
  var _isMyTurn;

  // TODO clear
  final List<List> _field = [
    ["X", "O", "X"],
    ["O", "O", "O"],
    ["O", "X", "O"]
  ];

  GamePageState(this._playerName, this._opponentName, this._isMyTurn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SizedBox(
        width: 400,
        child: Column(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.only(top: 150),
                child: _buildHeader()),
            Divider(thickness: 3, color: Colors.blueGrey),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: _whoseTurnLine(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: _buildField(),
            )
          ],
        ),
      ),
    ));
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          children: <Widget>[_gameParticipantBadge(name: _playerName, left: true)],
        ),
        Column(
          children: <Widget>[
            Text("VS",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))
          ],
        ),
        Column(
          children: <Widget>[
            _gameParticipantBadge(name: _opponentName, left: false)
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

  Widget _whoseTurnLine() {
    final text = _isMyTurn ? "Your turn" : "$_opponentName's turn";
    return Text(text,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: _isMyTurn ? Colors.green : Colors.red));
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
            onPressed: _isMyTurn ? () => {_makeMove(x, y)} : null,
            child: Text(_field[y][x], style: TextStyle(fontSize: 50)),
          )),
    );
  }

  void _makeMove(int x, int y) {
    // TODO
  }

  void updateField() {
    setState(() {
      // TODO
    });
  }
}
