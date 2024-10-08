import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      //SafeArea
      //뒤로 갈 때 해당 방 넘버의 collection을 삭제
      onPopInvokedWithResult: (didPop, result) async {
        try {
          await _firestore.collection('rooms').doc(_roomCode).delete();
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
                  inputFormatters: [LengthLimitingTextInputFormatter(10)],
                  enabled: caseInt < 1,
                ),
              ),
              Visibility(
                visible: caseInt == 0,
                child: ElevatedButton(
                    onPressed: _createRoom, child: Text("Create Room")),
              ),
              Visibility(
                visible: caseInt == 1,
                child: ElevatedButton(
                    onPressed: _closeRoom, child: Text("Close Room")),
              ),
              // Visibility(
              //     visible: caseInt == 2,
              //     child: ElevatedButton(
              //         onPressed: () {
              //           Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                   builder: (context) =>
              //                       MultiSetting(roomCode: _roomCode)));
              //         },
              //         child: Text("Next Page"))),
              Text("Room Code: $_roomCode"),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream:
                      _firestore.collection('rooms').doc(_roomCode).snapshots(),
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
    final roomCollection = _firestore.collection('rooms');
    var hostName = _nameController.text;
    debugPrint("1Host name before saving: $hostName");
    if (hostName.isEmpty) {
      _nameController.text = "HOST";
      hostName = "HOST";
      debugPrint("2Host name before saving: $hostName");
    }
    debugPrint("3Host name before saving: $hostName");
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
    final roomCollection = _firestore.collection('rooms');
    DocumentSnapshot roomSnapshot = await roomCollection.doc(_roomCode).get();
    var roomData = roomSnapshot.data() as Map<String, dynamic>;
    String host = roomData['host'] ?? '';

    if (roomSnapshot.exists) {
      List<String> guests = List<String>.from(roomData['guests'] ?? []);
      if (guests.length < 1) {
        await showDialog(
          //ok 버튼을 누를 때까지 대기.
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Warning"),
            content: Text("There are no guests in the room."),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              )
            ],
          ),
        );
        return;
      }
    }

    if (!guests.contains(host) && host.isNotEmpty) {
      guests.add(host);
      await roomCollection.doc(_roomCode).update({'guests': guests});
    }

    //방을 닫으면 해당 roomCode의 방의 개폐 유무를 false로 변경
    await roomCollection.doc(_roomCode).update({'isOpen': false});

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiSetting(
          roomCode: _roomCode,
        ),
      ),
    );

    setState(() {
      increaseInt();
    });
  }

  void _removeGuest(String guest) async {
    final roomCollection = _firestore.collection('rooms');
    guests.remove(guest);

    await roomCollection.doc(_roomCode).update({
      'guests': guests, //로컬의 guests 리스트를 문서에 그대로 박아버림
    });
    // setState(() {});
  }

  void _addTestGuest() async {
    final roomCollection = _firestore.collection('rooms');
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
