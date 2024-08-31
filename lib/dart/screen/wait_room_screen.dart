import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WaitRoomScreen extends StatefulWidget {
  final String roomCode;

  WaitRoomScreen({required this.roomCode});
  @override
  State<WaitRoomScreen> createState() => _WaitRoomScreenState();
}

class _WaitRoomScreenState extends State<WaitRoomScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomCode)
        .snapshots()
        .listen(
      (snapshot) {
        if (snapshot.exists) {
          var roomData = snapshot.data() as Map<String, dynamic>;
          if (roomData['guests'] == null ||
              !roomData['guests'].contains('guest_name')) {
            _showDisconnectDialog();
          }
        }
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wait Room Screen"),
      ),
    );
  }

  void _showDisconnectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Disconnected"),
        content: Text("You have veen disconnected from the room."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}
