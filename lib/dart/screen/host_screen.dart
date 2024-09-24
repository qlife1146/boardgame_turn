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

class _HostScreenState extends State<HostScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; //Firebase 축약
  final TextEditingController _nameController =
      TextEditingController(); //Host input을 위한 컨트롤러
  String _roomCode = "******";
  bool isRoomCreated = false;
  bool isRoomOpen = false;
  List<String> guests = [];
  int caseInt = 0;

  @override
  void initState() {
    super.initState();
    debugPrint("debug: $isRoomCreated.toString()");
    debugPrint("debug: $_roomCode.toString()");
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      //SafeArea
      //뒤로 갈 때 해당 방 넘버의 collection을 삭제
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

              //elevatedButton
              // ElevatedButton(
              //   onPressed: () {
              //     //방이 만들기 전 상태라면(=false일 때)
              //     if (!isRoomCreated && _roomCode != "******") {
              //       //방장 이름 적용, 코드 생성, 방 오픈, 방 상태 변경(close => open)
              //       debugPrint(isRoomCreated.toString());
              //       debugPrint(_roomCode.toString());
              //       _createRoom();
              //     } else if (isRoomOpen && guests.isNotEmpty) {
              //       //방을 닫을 수 있는 상태
              //       _closeRoom();
              //     } else {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => MultiSetting(roomCode: _roomCode),
              //         ),
              //       );
              //     }
              //   },
              //   //버튼 텍스트 상황에 따라 변경
              //   child: Text(isRoomCreated
              //       ? (isRoomOpen ? "Close Room" : "Next")
              //       : "Create Room"),
              //   // child: Text(),
              // ),

              Visibility(
                visible: caseInt == 0,
                child: ElevatedButton(
                    onPressed: () => _createRoom(), child: Text("Create Room")),
              ),
              Visibility(
                visible: caseInt == 1,
                child: ElevatedButton(
                    onPressed: () => _closeRoom, child: Text("Close Room")),
              ),
              Visibility(
                  visible: caseInt == 2,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    MultiSetting(roomCode: _roomCode)));
                      },
                      child: Text("Next Page"))),
              Text("Room Code: $_roomCode"),

              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('rooms')
                      .doc(_roomCode)
                      .snapshots(),
                  builder: (context, snapshot) {
                    //컬렉션이 있고, 데이터가 비어 있지 않을 때
                    if (snapshot.hasData && snapshot.data!.data() != null) {
                      var roomData =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      // roomData의 guests에 데이터가 있다면 guests 데이터를, 없다면 빈 리스트 반환
                      guests = List<String>.from(roomData?['guests'] ?? []);
                      // guests가 비어있지 않다면
                      if (guests.isNotEmpty) {
                        return ListView.builder(
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(guests[index]),
                              trailing: IconButton(
                                onPressed: () => _removeGuest(guests[index]),
                                icon: const Icon(Icons.remove_circle),
                              ),
                            );
                          },
                          itemCount: guests.length,
                        );
                      } else {
                        return const Center(
                          child: Text("No guests"),
                        );
                        // TODO: Add the No guests warning message.
                      }
                    }
                    return const Center(
                      child: Text("No room data available"),
                    );
                  },
                ),
              ),
              Text(caseInt.toString()),
              ElevatedButton(
                onPressed: () {
                  _addTestGuest();
                },
                child: const Text("Add a Test Guest"),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _createRoom() async {
    await _generateRoomCode();
    await _openRoom();

    setState(() {
      // isRoomOpen = true;
      increaseInt();
    });
  }

  Future<void> _generateRoomCode() async {
    final roomCollection = _firestore.collection('rooms');
    String generatedRoomCode;

    do {
      const min = 100000;
      const max = 999999;

      // min과 max 사이의 랜덤 숫자 생성
      generatedRoomCode = (min + Random().nextInt(max - min + 1)).toString();
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
    //방을 닫으면 해당 roomCode의 방의 개폐 유무를 false로 변경
    await roomCollection.doc(_roomCode).update({'isOpen': false});

    setState(() {
      // isRoomOpen = false;
      increaseInt();
    });

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TimerSettingScreen(),
      ),
    );
  }

  void _removeGuest(String guest) async {
    final roomCollection = FirebaseFirestore.instance.collection('rooms');
    guests.remove(guest);

    await roomCollection.doc(_roomCode).update({
      'guests': guests, //로컬의 guests 리스트를 문서에 그대로 박아버림
    });
    // setState(() {});
  }

  void _addTestGuest() async {
    final roomCollection = FirebaseFirestore.instance.collection('rooms');
    List<String> testGuests = ['testGuest1', 'testGuest2', 'testGuest3'];
    guests.addAll(testGuests);

    await roomCollection.doc(_roomCode).update({
      'guests': guests,
    });

    debugPrint(guests.toString());
  }

  void increaseInt() {
    setState(() {
      caseInt++;
    });
  }
}
