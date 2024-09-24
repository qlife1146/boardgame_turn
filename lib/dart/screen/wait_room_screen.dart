import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WaitRoomScreen extends StatefulWidget {
  final String roomCode;
  final String guestName;

  WaitRoomScreen({super.key, required this.roomCode, required this.guestName});
  @override
  State<WaitRoomScreen> createState() => _WaitRoomScreenState();
}

class _WaitRoomScreenState extends State<WaitRoomScreen> {
  List<String> guests = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Expanded(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('rooms')
                .doc(widget.roomCode)
                .snapshots(),
            builder: (context, snapshot) {
              //컬렉션이 있고, 데이터가 비어 있지 않을 때
              if (snapshot.hasData && snapshot.data!.data() != null) {
                var roomData = snapshot.data!.data() as Map<String, dynamic>?;
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
