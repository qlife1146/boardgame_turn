import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:vscode/dart/function/multi_setting.dart';
import 'package:vscode/dart/screen/timer_setting_screen.dart';

class HostScreen extends StatefulWidget {
  const HostScreen({super.key});

  @override
  State<HostScreen> createState() => _HostScreenState();
}

// Future<void> updateRoomActivity(String roomCode) async {
//   FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final roomDoc = _firestore.collection('rooms').doc(roomCode);

//   await roomDoc.update({
//     'lastActive': FieldValue.serverTimestamp(),
//   });
// }

class _HostScreenState extends State<HostScreen> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  String _roomCode = "******";
  bool isRoomOpen = false;
  List<String> guests = [];
  int _timeDuration = 60;

  @override
  void initState() {
    super.initState();
    // _generateRoomCode();
  }

  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        try {
          await FirebaseFirestore.instance
              .collection('rooms')
              .doc(_roomCode)
              .delete();
        } catch (e) {
          debugPrint("Error deleting room: $e");
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Your name"),
                ),
              ),
              Text("Seconds"),
              NumberPicker(
                minValue: 0,
                maxValue: 180,
                value: _timeDuration,
                onChanged: (value) => setState(() => _timeDuration = value),
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
              ElevatedButton(
                onPressed: isRoomOpen ? null : _createRoom,
                child: Text("Create Room"),
              ),
              Text("Room Code: $_roomCode"),
              ElevatedButton(
                onPressed: isRoomOpen ? _closeRoom : null,
                child: Text(isRoomOpen ? "Closed" : "Opened"),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('rooms')
                      .doc(_roomCode)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var roomData = snapshot.data!.data()
                        as Map<String, dynamic>?; // null 체크
                    if (roomData == null) {
                      return Center(child: Text('No room data available'));
                    }

                    guests = List<String>.from(roomData['guests'] ?? []);

                    return ListView.builder(
                      itemCount: guests.length,
                      itemBuilder: (context, index) {
                        if (index < guests.length) {
                          return ListTile(
                            title: Text(guests[index]),
                            trailing: IconButton(
                              onPressed: () {
                                _removeGuest(guests[index]);
                              },
                              icon: Icon(Icons.remove_circle),
                            ),
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MultiSetting(
                          roomCode: _roomCode,
                        ),
                      ),
                    );
                  },
                  child: Text("Next"))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateRoomCode() async {
    final roomCollection = _firestore.collection('rooms');
    String generatedRoomCode;

    do {
      final min = 100000;
      final max = 999999;

      // min과 max 사이의 랜덤 숫자 생성
      generatedRoomCode = (min + Random().nextInt(max - min + 1)).toString();
      // generatedRoomCode = (100000 +
      //         (999999 - 100000) *
      //             (new DateTime.now().millisecondsSinceEpoch % 100000))
      // .toString();

      final snapshot = await roomCollection.doc(generatedRoomCode).get();
      if (!snapshot.exists) {
        _roomCode = generatedRoomCode;
        setState(() {});
        break;
      }
    } while (true);
  }

  Future<void> _openRoom() async {
    final roomCollection = FirebaseFirestore.instance.collection('rooms');
    var hostName = _nameController.text;
    if (hostName == "") {
      hostName = "HOST";
    }
    await roomCollection.doc(_roomCode).set({
      'host': hostName,
      'guests': [],
      'isOpen': true,
    });
    setState(() {
      isRoomOpen = true;
    });
  }

  void _closeRoom() async {
    final roomCollection = FirebaseFirestore.instance.collection('rooms');
    await roomCollection.doc(_roomCode).update({'isOpen': false});

    setState(() {
      isRoomOpen = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (contexst) => TimerSettingScreen(),
      ),
    );
  }

  void _removeGuest(String guest) async {
    final roomCollection = FirebaseFirestore.instance.collection('rooms');
    guests.remove(guest);

    await roomCollection.doc(_roomCode).update({
      'guests': guests,
    });
    setState(() {});
  }

  void _createRoom() async {
    await _generateRoomCode();
    await _openRoom();

    setState(() {
      isRoomOpen = true;
    });
  }
}
