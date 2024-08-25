import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HostScreen extends StatefulWidget {
  const HostScreen({super.key});

  @override
  State<HostScreen> createState() => _HostScreenState();
}

class _HostScreenState extends State<HostScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _roomCode = "111111";
  List<String> guests = [];

  @override
  void initState() {
    super.initState();
    generateRoomCode();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Host Screen"),
      ),
    );
  }

  void generateRoomCode() async {
    // final roomCollection = FirebaseFirestore.instance.collection('rooms');
  }
}
