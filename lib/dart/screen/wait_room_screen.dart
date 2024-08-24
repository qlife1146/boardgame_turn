import 'package:flutter/material.dart';

class WaitRoomScreen extends StatefulWidget {
  const WaitRoomScreen({super.key});

  @override
  State<WaitRoomScreen> createState() => _WaitRoomScreenState();
}

class _WaitRoomScreenState extends State<WaitRoomScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wait Room Screen"),
      ),
    );
  }
}
