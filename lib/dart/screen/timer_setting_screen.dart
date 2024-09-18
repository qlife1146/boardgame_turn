import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:vscode/dart/function/timer_func.dart';
import 'package:vscode/dart/function/turn_func.dart';

//This screen is local timer settings screen.

class TimerSettingScreen extends StatefulWidget {
  const TimerSettingScreen({super.key});
  @override
  State<TimerSettingScreen> createState() => _TimerSettingScreenState();
}

class _TimerSettingScreenState extends State<TimerSettingScreen> {
  //numberPicker's default value.
  int _timeDuration = 60;
  int _players = 4;
  final double _sizedBoxValue = 100.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Seconds"),
            //타이머 시작 시간 설정용 NumberPicker
            NumberPicker(
              minValue: 0,
              maxValue: 180,
              value: _timeDuration,
              onChanged: (value) => {
                //Picker가 움직일 때마다 _timerDuration를 value로 변환
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
            const Text(
              "0은 무제한",
              style: TextStyle(
                fontSize: 10,
              ),
            ),
            SizedBox(
              height: _sizedBoxValue,
            ),
            const Text("Players"),
            NumberPicker(
              minValue: 2,
              maxValue: 8,
              value: _players,
              onChanged: (value) => {
                setState(() => _players = value),
              },
              haptics: true,
              axis: Axis.horizontal,
              itemCount: 3,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black)),
            ),
            SizedBox(
              height: _sizedBoxValue,
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
                          //TimerFunc로 보낼 변수들. 해당 클래스에서 쓸 이름:현재 클래스에서 쓰는 이름
                          timeDuration: _timeDuration,
                          players: _players,
                        ),
                      ),
                    );
                  }
                },
                child: const Text("OK"))
          ],
        ),
      ),
    );
  }
}
