import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  //doc = document ID not Require
                  await _firestore.collection("cars").doc("12345").set({
                    "brand": "brandName",
                    "name": "carName",
                    "price": "carPrice",
                  });
                },
                child: Text("create"),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text("duplicate"),
              ),
              ElevatedButton(
                onPressed: () async {},
                child: Text("remove"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
