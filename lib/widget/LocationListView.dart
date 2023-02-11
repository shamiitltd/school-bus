import 'dart:math';

import 'package:location/location.dart';
import 'package:school_bus/db/location.dart';
import 'package:school_bus/db/locationdb.dart';
import 'package:flutter/material.dart';

class LocationListView extends StatefulWidget {
  const LocationListView({Key? key}) : super(key: key);

  @override
  State<LocationListView> createState() => _LocationListViewState();
}

class _LocationListViewState extends State<LocationListView> {
  late List<Locations> locations;
  bool isLoading = false;
  double distanceTraveled = 0.0;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();

    refreshLocations();
  }

  @override
  void dispose() {
    LocationDatabase.instance.close();
    _mounted = false;
    super.dispose();
  }
  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }
  Future refreshLocations() async {
    setState(() => isLoading = true);
    locations = await LocationDatabase.instance.readAllNotes();
    for(var i=1; i < locations.length; i++){
      distanceTraveled +=calculateDistance(locations[i-1].latitude, locations[i-1].longitude, locations[i].latitude, locations[i].longitude);
    }
    if(_mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        'Notes ${distanceTraveled.toStringAsFixed(2)}',
        style: TextStyle(fontSize: 24),
      ),
      actions: const [Icon(Icons.search), SizedBox(width: 12)],
    ),
    body: Center(
      child: Column(
        children: [
          Text(
            'Notes ${distanceTraveled.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 24),
          ),
          isLoading
              ? const CircularProgressIndicator()
              : locations.isEmpty
              ? const Text(
            'No Notes',
            style: TextStyle(color: Colors.white, fontSize: 24),
          )
              :Text('Completed')
              // : buildNotes(),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child: const Icon(Icons.add),
      onPressed: () async {
        // await Navigator.of(context).push(
        //   MaterialPageRoute(builder: (context) => AddEditNotePage()),
        // );

        refreshLocations();
      },
    ),
  );

  Widget buildNotes() => ListView.builder(
      itemCount: 20,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: const Icon(Icons.location_history),
          title: Text('${locations[index].id} ${locations[index].latitude}:${locations[index].longitude} ${locations[index].distanceSoFar} ${locations[index].isProcessed} ${locations[index].addedDate} ${locations[index].processedDate}'),
        );
      });
}

