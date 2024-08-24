import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:vscode/dart/function/timer_func.dart';
import 'package:vscode/dart/function/turn_func.dart';

class TimerSettingScreen extends StatefulWidget {
  const TimerSettingScreen({super.key});

  @override
  State<TimerSettingScreen> createState() => _TimerSettingScreenState();
}

class _TimerSettingScreenState extends State<TimerSettingScreen> {
  int _timeDuration = 60;
  int _players = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Seconds"),
            NumberPicker(
              minValue: 0,
              maxValue: 180,
              value: _timeDuration,
              onChanged: (value) => {
                setState(() => _timeDuration = value),
              },
              step: 10,
              haptics: true,
              axis: Axis.horizontal,
              itemCount: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26),
              ),
            ),
            Text(
              "0은 무제한",
              style: TextStyle(
                fontSize: 10,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text("Players"),
            NumberPicker(
              minValue: 2,
              maxValue: 8,
              value: _players,
              onChanged: (value) => setState(() => _players = value),
              haptics: true,
              axis: Axis.horizontal,
              itemCount: 3,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black)),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () {
                  if (_timeDuration == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TurnFunc(
                          players: _players,
                        ),
                      ),
                    );
                  } else if (_timeDuration > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TimerFunc(
                          timeDuration: _timeDuration,
                          players: _players,
                        ),
                      ),
                    );
                  }
                },
                child: Text("OK"))
          ],
        ),
      ),
    );
  }
}
