import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:vscode/dart/function/multi_timer_func.dart';
import 'package:vscode/dart/function/multi_turn_func.dart';

class MultiSetting extends StatefulWidget {
  final String roomCode;
  const MultiSetting({super.key, required this.roomCode});

  @override
  State<MultiSetting> createState() => _MultiSettingState();
}

class _MultiSettingState extends State<MultiSetting> {
  int _timeDuration = 60;
  List<String> _guests = [];
  double boxSize = 40;

  @override
  void initState() {
    super.initState();
    _loadGuests();
  }

  void _loadGuests() async {
    final roomCollection = FirebaseFirestore.instance.collection('rooms');
    DocumentSnapshot roomSnapshot =
        await roomCollection.doc(widget.roomCode).get();

    if (roomSnapshot.exists) {
      var roomData =
          roomSnapshot.data() as Map<String, dynamic>?; // 데이터가 있는지 확인
      if (roomData != null && roomData.containsKey('guests')) {
        List<dynamic> guestsDynamic = roomData['guests']; // guests를 가져옴
        debugPrint('Guests from Firestore: $guestsDynamic'); // 가져온 데이터 출력

        // Firestore에서 가져온 guests가 리스트인지 확인 후 변환
        setState(() {
          _guests = List<String>.from(guestsDynamic);
        });
        debugPrint('Converted Guests: $_guests'); // 변환된 _guests 출력
      } else {
        debugPrint('No guests field found in the document.');
      }
    } else {
      debugPrint('No such document found for roomCode: ${widget.roomCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: boxSize,
              ),
              Text(
                widget.roomCode,
                style: TextStyle(fontSize: 40),
              ),
              Text(_guests.toString()),
              SizedBox(
                height: boxSize,
              ),
              const Text("Seconds"),
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
              const Text(
                "0은 무제한",
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
              SizedBox(
                height: boxSize,
              ),
              const Text("Players"),
              NumberPicker(
                minValue: _guests.length,
                maxValue: _guests.length,
                value: _guests.length,
                onChanged: (value) => {
                  null,
                },
                haptics: true,
                axis: Axis.horizontal,
                itemCount: 1,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black)),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      key: ValueKey(_guests[index]),
                      title: Text(_guests[index]),
                      leading: Icon(Icons.drag_handle),
                    );
                  },
                  itemCount: _guests.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = _guests.removeAt(oldIndex);
                      _guests.insert(newIndex, item);
                    });
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _gameRoomOpen_timer();
                  if (_timeDuration > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MultiTimerFunc(
                          timeDuration: _timeDuration,
                          players: _guests,
                        ),
                      ),
                    );
                  } else if (_timeDuration == 0) {
                    _gameRoomOpen_turn();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MultiTurnFunc(
                          players: _guests,
                        ),
                      ),
                    );
                  }
                },
                child: Text("Start"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _gameRoomOpen_timer() async {
    final roomCollection = FirebaseFirestore.instance.collection('rooms');
    await roomCollection.doc(widget.roomCode).set({
      'gameRoomOpen': true,
      'timeDuration': _timeDuration,
      'players': _guests,
    });
  }

  void _gameRoomOpen_turn() async {
    final roomCollection = FirebaseFirestore.instance.collection('rooms');
    await roomCollection.doc(widget.roomCode).set({
      'gameRoomOpen': true,
      'players': _guests,
    });
  }
}
