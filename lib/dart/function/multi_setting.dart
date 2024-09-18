import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class MultiSetting extends StatefulWidget {
  final String roomCode;
  const MultiSetting({super.key, required this.roomCode});

  @override
  State<MultiSetting> createState() => _MultiSettingState();
}

class _MultiSettingState extends State<MultiSetting> {
  int _timeDuration = 60;
  List<String> _guests = [];

  @override
  void initState() {
    super.initState();
    // _loadGuests();
  }

  void _loadGuests() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomCode)
        .get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _guests = List<String>.from(data['guests']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Seconds"),
            NumberPicker(
              minValue: 0,
              maxValue: 180,
              value: _timeDuration,
              onChanged: (value) => {
                setState(() => _timeDuration = value),
              },
              step: 10,
              haptics: true,
              axis: Axis.horizontal,
              itemCount: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26),
              ),
            ),
            const Text(
              "0은 무제한",
              style: TextStyle(
                fontSize: 10,
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    key: ValueKey(_guests[index]),
                    title: Text(_guests[index]),
                    leading: Icon(Icons.drag_handle),
                  );
                },
                itemCount: _guests.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = _guests.removeAt(oldIndex);
                    _guests.insert(newIndex, item);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playerList() async {
    final roomDoc =
        FirebaseFirestore.instance.collection('rooms').doc(widget.roomCode);
    DocumentSnapshot listSnapshot = await roomDoc.get();
  }
}
