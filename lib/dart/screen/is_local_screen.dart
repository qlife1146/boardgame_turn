import 'package:flutter/material.dart';
import 'package:vscode/dart/test.dart';
import 'guest_screen.dart';
import 'host_screen.dart';
import 'timer_setting_screen.dart';

class IsLocalScreen extends StatefulWidget {
  const IsLocalScreen({super.key});

  @override
  State<IsLocalScreen> createState() => _IsLocalScreenState();
}

class _IsLocalScreenState extends State<IsLocalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TimerSettingScreen(),
                    ),
                  );
                },
                child: const Text("Local"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HostScreen(),
                    ),
                  );
                },
                child: Text("Host"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GuestScreen(),
                    ),
                  );
                },
                child: Text("Guest"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Test(),
                    ),
                  );
                },
                child: Text("test"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
