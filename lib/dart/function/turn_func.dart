import 'package:flutter/material.dart';

class TurnFunc extends StatefulWidget {
  final int players;
  const TurnFunc({required this.players});

  @override
  State<TurnFunc> createState() => _TurnFuncState();
}

class _TurnFuncState extends State<TurnFunc> {
  final List<Color> _turnMainColor = [
    Color(0xFFE59460),
    Color(0xFF5C8575),
    Color(0xFFE29AA8),
    Color(0xFF7A8A33),
    Color(0xFF5A7D9A),
    Color(0xFFB08467),
    Color(0xFFEAD875),
    Color(0xFF6E7074),
  ];
  int currentTurn = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _turnMainColor[(currentTurn - 1 % _turnMainColor.length)],
      body: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(
                () {
                  // debugPrint("touched");
                  currentTurn++;
                  if (currentTurn >= widget.players + 1) {
                    currentTurn = 1;
                  }
                },
              );
            },
          ),
          IgnorePointer(
            child: Center(
              child: Text(
                "$currentTurn Player's Turn",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontFeatures: [
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
