import 'package:flutter/material.dart';

class MultiTimerFunc extends StatefulWidget {
  final int timeDuration;
  final List<String> players;

  MultiTimerFunc({
    super.key,
    required this.timeDuration,
    required this.players,
  });

  @override
  State<MultiTimerFunc> createState() => _MultiTimerFuncState();
}

class _MultiTimerFuncState extends State<MultiTimerFunc> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[Text(widget.players.join())],
          ),
        ),
      ),
    );
  }
}
