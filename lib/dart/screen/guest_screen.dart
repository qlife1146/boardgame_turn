import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vscode/dart/screen/wait_room_screen.dart';

class GuestScreen extends StatefulWidget {
  final Stream<DocumentSnapshot>? roomStream;
  const GuestScreen({super.key, this.roomStream});

  @override
  State<GuestScreen> createState() => _GuestScreenState();
}

class _GuestScreenState extends State<GuestScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomCodeController = TextEditingController();
  late String _hostName;
  late Stream<DocumentSnapshot>? roomStream;
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    roomStream = widget.roomStream;
    _nameController.addListener(_updateButtonState);
    _roomCodeController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      isButtonEnabled = _nameController.text.isNotEmpty &&
          _roomCodeController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Your name"),
                  textInputAction: TextInputAction.next,
                  inputFormatters: [LengthLimitingTextInputFormatter(10)],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: TextField(
                  controller: _roomCodeController,
                  decoration: InputDecoration(labelText: "Room code"),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: isButtonEnabled ? _joinRoom : null,
                child: Text("Join"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _joinRoom() async {
    //go to waiting room.
    final roomDoc = FirebaseFirestore.instance
        .collection('rooms')
        .doc(_roomCodeController.text);
    DocumentSnapshot roomSnapshot = await roomDoc.get();
    //get은 1회성 조회, snapshot은 실시간 조회. snapshot의 실시간 변화는 stream으로 전송.

    String name = _nameController.text.trimRight();

    if (roomSnapshot.exists) {
      //exists = roomSnapshot에 데이터가 있다면 ture, 없다면 false.
      var roomData = roomSnapshot.data() as Map<String, dynamic>;
      List<String> guests = List<String>.from(roomData['guests'] ?? []);

      if (guests.contains(_nameController.text)) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Duplicate Name"),
            content: Text("This name is already in the room."),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    _nameController.clear();
                  },
                  child: Text("OK"))
            ],
          ),
        );
        return;
      }
      if (roomData['isOpen'] == true) {
        _hostName = roomData['host'];
        roomStream = roomDoc.snapshots();

        if (!mounted) return;
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
                    guests.add(_nameController.text); // =guest name

                    await roomDoc.update({
                      'guests': guests,
                    });

                    var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WaitRoomScreen(
                          roomCode: _roomCodeController.text,
                          guestName: name,
                        ),
                      ),
                    );
                    if (result == true) {
                      _clearTextFields();
                    }
                  },
                  child: Text("Yes"))
            ],
          ),
        );
      } else {
        if (!mounted) return; // mounted 체크 추가
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Room is closed.")));
      }
    } else {
      if (!mounted) return; // mounted 체크 추가
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text("Room not found.")));
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(""),
          content: Text("Room not found."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            )
          ],
        ),
      );
    }
  }

  void _clearTextFields() {
    _roomCodeController.clear();
  }
}
