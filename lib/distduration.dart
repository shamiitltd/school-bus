import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:school_bus/Login/Utils.dart';
import 'package:school_bus/constant.dart';
import 'package:http/http.dart' as http;

import 'directions_model.dart';
import 'directions_repository.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  late GoogleMapController googleMapController;
  final Completer<GoogleMapController> _controller = Completer();
  Location location = Location();
  final user = FirebaseAuth.instance.currentUser;
  late LatLng destination;
  LocationData? currentLocationData;
  late StreamSubscription _locationSubscription;
  List<LatLng> polylineCoordinates = [];
  late Directions _info;
  bool infoUpdate = false;

  Set<Marker> markers = {};
  Set<Map<dynamic, dynamic>> allUserCompleteData = {};

  Map<dynamic, dynamic> currentUserdata = <dynamic, dynamic>{};
  Map<dynamic, dynamic> selectedUserdata = <dynamic, dynamic>{};
  String currentUid = '';
  String selectedUid = '';



  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    getCoordinatesByRootId(1);
    getCurrentLocation();
    final user = this.user;
    if(user != null){
      currentUid=user.uid;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _locationSubscription.cancel();
    googleMapController.dispose();
  }

  Future getCoordinatesByRootId(dynamic rootId) async {
    DatabaseReference starCountRef = FirebaseDatabase.instance.ref('users');
    await starCountRef.onValue.listen((DatabaseEvent event) {
      Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
      allUserCompleteData.clear();
      data.forEach((key, value) {
        if (value['route'] == rootId && value['trackMe'] == true) {
          if(key == currentUid){
            currentUserdata = value;
            final user = this.user;
            if(user != null) {
              currentUid=user.uid;
            }
          }else{
            allUserCompleteData.add({key: value});
          }
        }
      });
      setState(() {});
    });
  }


  void getCurrentLocation() async {
    location.getLocation().then((value) {
      setState(() {
        currentLocationData = value;
      });
    });

    googleMapController = await _controller.future;
    _locationSubscription = location.onLocationChanged.listen((newlocation) async {
      setState(() {
        currentLocationData = newlocation;
        Utils().setMyCoordinates(currentLocationData!.latitude!.toString(), currentLocationData!.longitude!.toString());
        updateCoordinates();
      });
      if (focusLiveLocation) {
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                zoom: zoomMap,
                target: LatLng(currentLocationData!.latitude!,
                    currentLocationData!.longitude!))));
      }
      if(selectedUid.isNotEmpty){
        final directions = await DirectionsRepository().getDirections(
            origin: LatLng(
                currentLocationData!.latitude!, currentLocationData!.longitude!),
            destination: destination);
        setState(() {
          infoUpdate = true;
          _info = directions;
        });
      }
    });
  }

  void getPolyPoints() async {
    if(selectedUid.isEmpty) {
      return;
    }
    PolylinePoints polylinePoints = PolylinePoints();
    polylineCoordinates.clear();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(
            currentLocationData!.latitude!, currentLocationData!.longitude!),
        PointLatLng(destination.latitude, destination.longitude));
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    final directions = await DirectionsRepository().getDirections(
        origin: LatLng(
            currentLocationData!.latitude!, currentLocationData!.longitude!),
        destination: destination);
    setState(() {
      infoUpdate = true;
      _info = directions;
    });
  }


  void updateCoordinates() async{
    if(currentUid.isEmpty || currentUserdata['image'] == null) return;
    if(selectedUid.isNotEmpty){
      var val = allUserCompleteData.firstWhere((element) => element.containsKey(selectedUid));
      selectedUserdata = val[selectedUid];
      destination = LatLng(double.parse(selectedUserdata['latitude']),
          double.parse(selectedUserdata['longitude']));
      getPolyPoints();
    }

    var url = Uri.parse(currentUserdata['image']);
    var request = await http.get(url);
    var dataBytes = request.bodyBytes;

    markers.add(
      Marker(
        infoWindow: InfoWindow(
            title: '${currentUserdata['post']}: ${currentUserdata['name']}',
            snippet: 'Phone: ${currentUserdata['phone']}',
            onTap: () {
              print("Pop up clicked");
            }),
        icon: BitmapDescriptor.fromBytes(dataBytes.buffer.asUint8List()),
        markerId: MarkerId(currentUserdata['email']),
        position: LatLng(double.parse(currentUserdata['latitude']),
            double.parse(currentUserdata['longitude'])),
      ),
    );
    allUserCompleteData.forEach((element) {
      element.forEach((key, value) async {
        url = Uri.parse(value['image']);
        request = await http.get(url);
        dataBytes = request.bodyBytes;
        markers.add(
          Marker(
            onTap: () {
              selectedUid=key;
              selectedUserdata=value;
              destination = LatLng(double.parse(value['latitude']),
                  double.parse(value['longitude']));
              getPolyPoints();
            },
            infoWindow: InfoWindow(
                title: '${value['post']}: ${value['name']}',
                snippet: 'Phone: ${value['phone']}',
                onTap: () {
                  print("Pop up clicked");
                }),
            icon: BitmapDescriptor.fromBytes(dataBytes.buffer.asUint8List()),
            markerId: MarkerId(key),
            position: LatLng(double.parse(value['latitude']),
                double.parse(value['longitude'])),
          ),
        );

      });
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // getPolyPoints();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track order",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                focusLiveLocation ? 'Focus' : 'No Focus',
                style: TextStyle(color: Colors.black, fontSize: 20.0),
              ),
              SizedBox(
                height: 12.0,
              ),
              CupertinoSwitch(
                value: focusLiveLocation,
                onChanged: (value) {
                  setState(() {
                    focusLiveLocation = value;
                  });
                },
              ),
            ],
          )
        ],
      ),
      body: currentLocationData == null
          ? const Center(
        child: Text("Loading..."),
      )
          : Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
                target: LatLng(currentLocationData!.latitude!,
                    currentLocationData!.longitude!),
                zoom: zoomMap),
            polylines: {
              Polyline(
                  polylineId: PolylineId("route"),
                  points: polylineCoordinates,
                  color: primaryColor,
                  width: 6)
            },
            markers: markers,
            onMapCreated: (mapController) {
              _controller.complete(mapController);
            },
          ),
          if (infoUpdate)
            Positioned(
              top: 20.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    )
                  ],
                ),
                child: Text(
                  '${_info.totalDistance}, ${_info.totalDuration}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
