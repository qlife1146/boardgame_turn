import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vscode/dart/screen/timer_setting_screen.dart';

class HostScreen extends StatefulWidget {
  const HostScreen({super.key});

  @override
  State<HostScreen> createState() => _HostScreenState();
}

Future<void> updateRoomActivity(String roomCode) async {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final roomDoc = _firestore.collection('rooms').doc(roomCode);

  await roomDoc.update({
    'lastActive': FieldValue.serverTimestamp(),
  });
}

class _HostScreenState extends State<HostScreen> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  String _roomCode = "111111";
  bool isRoomOpen = false;
  List<String> guests = [];

  @override
  void initState() {
    super.initState();
    _generateRoomCode();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Your name"),
          ),
          Text("Room Code: $_roomCode"),
          ElevatedButton(
            onPressed: isRoomOpen ? _closeRoom : _openRoom,
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

                var roomData = snapshot.data!.data() as Map<String, dynamic>;
                guests = List<String>.from(roomData['guests'] ?? []);

                return ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(guests[index]),
                      trailing: IconButton(
                        onPressed: () {
                          _removeGuest(guests[index]);
                        },
                        icon: Icon(Icons.remove_circle),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _generateRoomCode() async {
    final roomCollection = _firestore.collection('rooms');
    String generatedRoomCode;

    do {
      generatedRoomCode = (100000 +
              (999999 - 100000) *
                  (new DateTime.now().millisecondsSinceEpoch % 1000000))
          .toString();
      final snapshot = await roomCollection.doc(generatedRoomCode).get();
      if (!snapshot.exists) {
        _roomCode = generatedRoomCode;
        setState(() {});
        break;
      }
    } while (true);
  }

  void _openRoom() async {
    final roomCollection = FirebaseFirestore.instance.collection('rooms');
    await roomCollection.doc(_roomCode).set({
      'host': _nameController.text,
      'guests': [],
      'isOpen': true,
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
}
