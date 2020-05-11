import 'package:flutter/material.dart';

class MatchmakingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MatchmakingPageState();
}

class _MatchmakingPageState extends State<MatchmakingPage> {
  var _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Center(child: Text("Matchmaking"))),
        body: Center(
          child: Container(
            width: 400,
            child: Column(
              children: <Widget>[
            Container(
                padding: const EdgeInsets.only(top: 100.0),
                child: _buildMatchMakingButton()),
            Container(
                padding: const EdgeInsets.only(top: 40.0),
                child: _buildSearchingProgressBar()),
              ],
            ),
          ),
        ));
  }

  Widget _buildMatchMakingButton() {
    return RawMaterialButton(
      onPressed: () {
        setState(() {
          _isSearching = !_isSearching;
        });
      },
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
