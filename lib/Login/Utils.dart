import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:school_bus/db/location.dart';
import 'package:school_bus/db/locationdb.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  final user = FirebaseAuth.instance.currentUser;
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

  Future<void> setRoles(String role) async {
    final databaseReference = FirebaseDatabase.instance.ref().child("roles");
    Map<String, dynamic> updateValues = {
      role: role,
    };
    await databaseReference
        .update(updateValues)
        .then((_) {})
        .catchError((error) {});
  }

  Future<void> setPosts(String post) async {
    final databaseReference = FirebaseDatabase.instance.ref().child("posts");
    Map<String, dynamic> updateValues = {
      post: post,
    };
    await databaseReference
        .update(updateValues)
        .then((_) {})
        .catchError((error) {});
  }

  Future<Map> getRoutes() async {
    Map<dynamic, dynamic> data = {};
    final databaseReference = FirebaseDatabase.instance.ref().child("routes");
    await databaseReference.onValue.listen((DatabaseEvent event) {
      data = event.snapshot.value as Map<dynamic, dynamic>;
    });
    return data;
  }

  Future<Map> getPosts() async {
    Map<dynamic, dynamic> data = {};
    final databaseReference = FirebaseDatabase.instance.ref().child("posts");
    await databaseReference.onValue.listen((DatabaseEvent event) {
      data = event.snapshot.value as Map<dynamic, dynamic>;
    });
    return data;
  }

  Future<void> setMyCoordinates(
      String latitude, String longitude, double direction) async {
    final databaseReference =
        FirebaseDatabase.instance.ref().child("users/${user?.uid}");
    Map<String, dynamic> updateValues = {
      "latitude": latitude,
      "longitude": longitude,
      "direction": direction,
    };
    await databaseReference
        .update(updateValues)
        .then((_) {})
        .catchError((error) {});
  }

  Future<void> setMyMapSettings(String image, String route, bool trackMe) async {
    final databaseReference =
        FirebaseDatabase.instance.ref().child("users/${user?.uid}");
    Map<String, dynamic> updateValues = {
      "route": route,
      "trackMe": trackMe,
    };
    if (image.isNotEmpty) {
      updateValues["image"] = image;
    }
    await databaseReference
        .update(updateValues)
        .then((_) {})
        .catchError((error) {});
  }

  Future<void> setTraceMeSettings(bool trackMe) async {
    final databaseReference =
        FirebaseDatabase.instance.ref().child("users/${user?.uid}");
    Map<String, dynamic> updateValues = {
      "trackMe": trackMe,
    };
    await databaseReference
        .update(updateValues)
        .then((_) {})
        .catchError((error) {});
  }

  Future<void> setDistanceSettings(double distance) async {
    final databaseReference =
        FirebaseDatabase.instance.ref().child("users/${user?.uid}");
    Map<String, dynamic> updateValues = {
      "distance": distance,
    };
    await databaseReference
        .update(updateValues)
        .then((_) {})
        .catchError((error) {});
  }

  Future<void> setTotalDistanceTravelled(double newDistance) async {
    final prefs = await SharedPreferences.getInstance();
    double? oldDist = prefs.getDouble('totalDistance');
    if (oldDist != null) {
      newDistance += oldDist;
    }
    await prefs.setDouble('totalDistance', newDistance);
    setDistanceSettings(newDistance);
  }

  Future<void> setUserInfo(String post, String phoneNumber, String displayName,
      bool routeAccess) async {
    final databaseReference =
        FirebaseDatabase.instance.ref().child("users/${user?.uid}");
    Map<String, dynamic> updateValues = {
      "post": post, //Student, Teacher, Principle
      "phone": phoneNumber,
      "email": user?.email!,
      "name": displayName,
      "routeAccess": routeAccess, //'default'
    };
    await databaseReference
        .update(updateValues)
        .then((_) {})
        .catchError((error) {});
  }

  Future<void> addLocations(latitude, longitude) async {
    final locations = Locations(
      latitude: latitude,
      longitude: longitude,
      distanceSoFar: 0,
      isProcessed: false,
      addedDate: DateTime.now(),
    );
    await LocationDatabase.instance.create(locations);
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  double setPrecision(double number, int precision) {
    return double.parse(number.toStringAsFixed(precision));
  }

  bool compareLatLang(LatLng coordinate1, LatLng coordinate2, int precision) {
    return (setPrecision(coordinate1.longitude, precision) ==
            setPrecision(coordinate2.longitude, precision) &&
        setPrecision(coordinate1.latitude, precision) ==
            setPrecision(coordinate2.latitude, precision));
  }
}
