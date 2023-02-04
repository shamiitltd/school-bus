import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DataCard extends StatefulWidget {
  final String databaseRef;

  DataCard({required this.databaseRef});

  @override
  _DataCardState createState() => _DataCardState();
}

class _DataCardState extends State<DataCard> {
  late Map<dynamic, dynamic> data;
  Future getCoordinatesbyEmail(String email) async {
    DatabaseReference starCountRef =
    FirebaseDatabase.instance.ref('users/$email/location');
    starCountRef.onValue.listen((DatabaseEvent event) {
      // final data = event.snapshot.value;
      data = event.snapshot.value as Map<dynamic, dynamic>;
    });
    return data;
  }


  void setCoordinatesbyEmail(String email, String latlocation, String langlocation) async {
    final databaseReference = FirebaseDatabase.instance.ref().child("users/$email/location");
    Map<String, dynamic> updateValues = {
      "latlocation": latlocation,
      "langlocation": langlocation,
    };
    databaseReference.update(updateValues).then((_) {
      print("Values updated successfully");
    }).catchError((error) {
      print("Error updating values: $error");
    });
  }


  @override
  void initState() {
    super.initState();
 }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Text('Name: ${data != null ? data['subtitle'] : 'Loading...'}'),
            Text('Age: ${data != null ? data['title'] : 'Loading...'}'),
          ],
        ),
      ),
    );
  }
}


Future getCoordinatesbyEmail(String email) async {
  Map<dynamic, dynamic> data = <dynamic, dynamic>{};
  DatabaseReference starCountRef =
  FirebaseDatabase.instance.ref('users/$email/location');
  starCountRef.onValue.listen((DatabaseEvent event) {
    // final data = event.snapshot.value;
    data = event.snapshot.value as Map<dynamic, dynamic>;
  });
  return data;
}


void setCoordinatesbyEmail(String email, String latlocation, String langlocation) async {
  final databaseReference = FirebaseDatabase.instance.ref().child("users/$email/location");
// create a Map to store the updated values
  Map<String, dynamic> updateValues = {
    "latlocation": latlocation,
    "langlocation": langlocation,
  };
// update the values in the database
  databaseReference.update(updateValues).then((_) {
    print("Values updated successfully");
  }).catchError((error) {
    print("Error updating values: $error");
  });
}
