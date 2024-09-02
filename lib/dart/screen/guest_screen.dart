import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    roomStream = widget.roomStream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Your name"),
            textInputAction: TextInputAction.next,
          ),
          TextFormField(
            controller: _roomCodeController,
            decoration: InputDecoration(labelText: "Room code"),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.continueAction,
          ),
          ElevatedButton(onPressed: _joinRoom, child: Text("Join")),
          StreamBuilder<DocumentSnapshot>(
              stream: roomStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active &&
                    snapshot.hasData) {
                  var roomData = snapshot.data!.data() as Map<String, dynamic>;
                  if (!roomData['guests'].contains(_nameController.text)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showBannedDialog();
                    });
                  }
                }
                return SizedBox.shrink();
              })
        ],
      ),
    );
  }

  void _joinRoom() async {
    final roomDoc = FirebaseFirestore.instance
        .collection('rooms')
        .doc(_roomCodeController.text);
    DocumentSnapshot roomSnapshot = await roomDoc.get();
    //get은 1회성 조회, snapshot은 실시간 조회. snapshot의 실시간 변화는 stream으로 전송.

    if (roomSnapshot.exists) {
      //exists = roomSnapshot에 데이터가 있다면 ture, 없다면 false.
      var roomData = roomSnapshot.data() as Map<String, dynamic>;
      if (roomData['isOpen'] == true) {
        _hostName = roomData['host'];
        roomStream = roomDoc.snapshots();

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

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WaitRoomScreen(
                                  roomCode: _roomCodeController.text,
                                  guestName: _nameController.text,
                                )));
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

  void _showBannedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("You are banned."),
        actions: [
          TextButton(
              onPressed: () =>
                  Navigator.popUntil(context, ModalRoute.withName('/')),
              child: Text("OK"))
        ],
      ),
    );
  }
}
