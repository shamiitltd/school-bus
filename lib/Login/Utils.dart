import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Utils {
  final user = FirebaseAuth.instance.currentUser!;
  static final messangerKey = GlobalKey<ScaffoldMessengerState>();

  static showSnackBar(String? text) {
    if (text == null) return;
    final snackBar = SnackBar(
      content: Text(text),
      backgroundColor: Colors.red,
    );
    messangerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void setMyCoordinates(String latitude, String longitude) async {
    final databaseReference =
    FirebaseDatabase.instance.ref().child("users/${user.uid}");
    Map<String, dynamic> updateValues = {
      "latitude": latitude,
      "longitude": longitude,
    };
    await databaseReference.update(updateValues).then((_) {}).catchError((
        error) {});
  }

  void setMyMapSettings(String route, bool trackMe) async {
    final databaseReference =
    FirebaseDatabase.instance.ref().child("users/${user.uid}");
    Map<String, dynamic> updateValues = {
      "route": route,
      "trackMe": trackMe,
    };
    await databaseReference.update(updateValues).then((_) {}).catchError((
        error) {});
  }
  void setUserInfo(String post, bool mapAccess) async {
    final databaseReference =
    FirebaseDatabase.instance.ref().child("users/${user.uid}");
    Map<String, dynamic> updateValues = {
      "post": post, //Student, Teacher, Principle
      "phone": user.phoneNumber,
      "email": user.email!,
      "name": user.displayName!,
      "mapAccess": mapAccess,//'default'
    };
    await databaseReference.update(updateValues).then((_) {
    }).catchError((error) {
    });
  }

}