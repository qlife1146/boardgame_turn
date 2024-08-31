import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vscode/dart/screen/wait_room_screen.dart';

class GuestScreen extends StatefulWidget {
  const GuestScreen({super.key});

  @override
  State<GuestScreen> createState() => _GuestScreenState();
}

class _GuestScreenState extends State<GuestScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomCodeController = TextEditingController();
  late String _hostName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Your name"),
          ),
          TextField(
            controller: _roomCodeController,
            decoration: InputDecoration(labelText: "Room code"),
          ),
          ElevatedButton(onPressed: _joinRoom, child: Text("Join"))
        ],
      ),
    );
  }

  void _joinRoom() async {
    final roomDoc = FirebaseFirestore.instance
        .collection('rooms')
        .doc(_roomCodeController.text);

    DocumentSnapshot roomSnapshot = await roomDoc.get();
    if (roomSnapshot.exists) {
      var roomData = roomSnapshot.data() as Map<String, dynamic>;
      if (roomData['isOpen'] == true) {
        _hostName = roomData['host'];

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Is this the right room?"),
            content: Text("Host: $_hostName"),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    List<String> guests = List<String>.from(roomData['guests']);
                    guests.add(_nameController.text);

                    await roomDoc.update({
                      'guests': guests,
                    });

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WaitRoomScreen(
                                roomCode: _roomCodeController.text)));
                  },
                  child: Text("Yes"))
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Room is closed.")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Room not found.")));
    }
  }
}
