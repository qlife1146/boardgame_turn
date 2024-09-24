import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vscode/dart/function/multi_timer_func.dart';

class WaitRoomScreen extends StatefulWidget {
  final String roomCode;
  final String guestName;

  WaitRoomScreen({super.key, required this.roomCode, required this.guestName});
  @override
  State<WaitRoomScreen> createState() => _WaitRoomScreenState();
}

class _WaitRoomScreenState extends State<WaitRoomScreen> {
  List<String> guests = [];
  bool _dialogShown = false;
  bool _navigatedToNextPage = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        try {
          await FirebaseFirestore.instance
              .collection('rooms')
              .doc(widget.roomCode)
              .update({
            'guests': FieldValue.arrayRemove([widget.guestName])
          });
        } catch (e) {
          debugPrint("Error remove guest: $e");
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Text(widget.roomCode),
              Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(widget.roomCode)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    // 방이 삭제되었을 경우 처리
                    if (!_dialogShown) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _showDisconnectDialog("Room has been deleted.");
                      });
                      _dialogShown = true;
                    }
                    return const Center(
                      child: Text("Room no longer exists."),
                    );
                  }

                  var roomData = snapshot.data!.data() as Map<String, dynamic>?;
                  guests = List<String>.from(roomData?['guests'] ?? []);

                  // 방에 남아있지 않은 경우
                  if (!guests.contains(widget.guestName)) {
                    if (!_dialogShown) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _showDisconnectDialog(
                            "You have been removed from the room.");
                      });
                      _dialogShown = true;
                    }
                    return const Center(
                      child: Text("You have been removed from the room."),
                    );
                  }

                  if (roomData != null &&
                      roomData.containsKey('gameRoomOpen')) {
                    if (roomData['gameRoomOpen'] == true &&
                        !_navigatedToNextPage) {
                      _navigatedToNextPage = true;
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MultiTimerFunc(
                                timeDuration: roomData['timeDuration'],
                                players: roomData['players'],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }

                  if (guests.isNotEmpty) {
                    return ListView.builder(
                      itemCount: guests.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(guests[index]),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text("No guests"),
                    );
                  }
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showDisconnectDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Disconnected"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                _clear_GuestNameController();
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _clear_GuestNameController() async {
    try {
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomCode)
          .update({
        'guests': FieldValue.arrayRemove([widget.guestName])
      });
    } catch (e) {
      debugPrint("Error removing guests: $e");
    }
    Navigator.pop(context, true);
  }
}
