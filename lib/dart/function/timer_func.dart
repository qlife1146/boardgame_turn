import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class TimerFunc extends StatefulWidget {
  final int timeDuration;
  final int players;
  TimerFunc({
    super.key,
    required this.timeDuration,
    required this.players,
  });

  @override
  State<TimerFunc> createState() => _TimerFuncState();
}

class _TimerFuncState extends State<TimerFunc> {
  final CountDownController _timerController = CountDownController();
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
  // final List<Color> _turnSubColor = [];

  @override
  void initState() {
    super.initState();
  }

  int currentTurn = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Text(
                "$currentTurn Player's Turn",
                style: TextStyle(
                  fontSize: 30,
                  fontFeatures: [
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    if (!_timerController.isStarted.value) {
                      _timerController.start();
                    } else if (_timerController.isPaused.value) {
                      _timerController.resume();
                    } else {
                      _timerController.pause();
                    }
                  },
                  child: CircularCountDownTimer(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.7,
                    duration: widget.timeDuration,
                    // fillColor: Color(0xFF800080),
                    backgroundColor: _turnMainColor[
                        (currentTurn - 1 % _turnMainColor.length)],
                    fillColor: Color(0xFFFF0000),
                    ringColor: Color(0xFFFFFFFF),
                    strokeWidth: 20,

                    strokeCap: StrokeCap.butt,
                    textStyle: TextStyle(
                      fontSize: 70,
                      fontFeatures: [
                        FontFeature.tabularFigures(),
                      ],
                    ),
                    textFormat: CountdownTextFormat.MM_SS,
                    controller: _timerController,
                    autoStart: false,
                    isReverse: true,
                    isReverseAnimation: true,
                    onComplete: () => {
                      Vibration.vibrate(duration: 1000),
                    },
                  ),
                ),
              ),
              Visibility(
                visible: _timerController.isPaused.value ||
                    !_timerController.isStarted.value,
                child: ElevatedButton(
                  onPressed: () {
                    setState(
                      () {
                        _timerController.reset();
                        currentTurn++;
                        if (currentTurn >= widget.players + 1) {
                          currentTurn = 1;
                        }
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize:
                        // Size.fromWidth(MediaQuery.of(context).size.width / 2),
                        Size(MediaQuery.of(context).size.width / 2,
                            MediaQuery.of(context).size.height * 0.1),
                  ),
                  child: Text("Next Turn"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
