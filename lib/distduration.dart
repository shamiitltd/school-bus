import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:school_bus/Login/Utils.dart';
import 'package:school_bus/constant.dart';
import 'package:http/http.dart' as http;
import 'package:school_bus/widget/ZoomPopup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Login/countryData.dart';
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
  late StreamSubscription _firebaseSubscription;
  List<LatLng> polylineCoordinates = [];
  late Directions _info;
  bool infoUpdate = false;

  BitmapDescriptor locationMaker = BitmapDescriptor.defaultMarker;
  Set<Marker> markers = {};
  Set<Map<dynamic, dynamic>> allUserCompleteData = {};

  Map<dynamic, dynamic> currentUserdata = <dynamic, dynamic>{};
  Map<dynamic, dynamic> selectedUserdata = <dynamic, dynamic>{};
  String currentUid = '';
  String selectedUid = '';
  String _selectedRoute = '';
  bool _mounted = true;

  void loadRouteInfo() async {
    List<String> routeList = [];
    final databaseReference = FirebaseDatabase.instance.ref();
    databaseReference.child("routes").onValue.listen((DatabaseEvent event) {
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        routeList.add(value);
      });
      if(_mounted) {
        setState(() {
        userRoute = routeList;
        _selectedRoute = userRoute[0];
      });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    loadRouteInfo();
    getCoordinatesByRootId();
    getCurrentLocation();
    final user = this.user;
    if (user != null) {
      currentUid = user.uid;
    }
    setZoomLevel();
  }
  Future<void> setZoomLevel() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      zoomMap = (prefs.getDouble('zoom'))!;
    });
  }

  @override
  void dispose() {
    _firebaseSubscription.cancel();
    _mounted = false;
    super.dispose();
  }

  Future getCoordinatesByRootId() async {
    DatabaseReference starCountRef = FirebaseDatabase.instance.ref('users');
    _firebaseSubscription = starCountRef.onValue.listen((DatabaseEvent event) {
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;
      allUserCompleteData.clear();
      data.forEach((key, value) {
        if (value['route'] == data[user?.uid]['route']) {
          if (key == currentUid) {
            currentUserdata = value;
          } else if (value['trackMe'] == true) {
            allUserCompleteData.add({key: value});
          }
        }
      });
      if (_mounted) {
        setState(() {});
      }
    });
  }

  void getCurrentLocation() async {
    location.getLocation().then((value) {
      currentLocationData = value;
      if (_mounted) {
        setState(() {});
      }
    });

    googleMapController = await _controller.future;
    location.onLocationChanged.listen((newlocation) async {
      currentLocationData = newlocation;
      Utils().setMyCoordinates(currentLocationData!.latitude!.toString(),
          currentLocationData!.longitude!.toString());
      updateCoordinates();
      if (focusLiveLocation) {
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                zoom: zoomMap,
                target: LatLng(currentLocationData!.latitude!,
                    currentLocationData!.longitude!))));
      } else if (selectedUid.isNotEmpty) {
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(zoom: zoomMap, target: destination)));
      }
      if (selectedUid.isNotEmpty) {
        final directions = await DirectionsRepository().getDirections(
            origin: LatLng(currentLocationData!.latitude!,
                currentLocationData!.longitude!),
            destination: destination);
        infoUpdate = true;
        _info = directions;
      }
      if (_mounted) {
        setState(() {});
      }
    });
    location.enableBackgroundMode(enable: true);
  }

  void getPolyPoints() async {
    if (selectedUid.isEmpty) {
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
    infoUpdate = true;
    _info = directions;
    if (_mounted) {
      setState(() {});
    }
  }

  void updateCoordinates() async {
    if (selectedUid.isNotEmpty) {
      var val = allUserCompleteData
          .firstWhere((element) => element.containsKey(selectedUid));
      selectedUserdata = val[selectedUid];
      destination = LatLng(double.parse(selectedUserdata['latitude']),
          double.parse(selectedUserdata['longitude']));
      getPolyPoints();
    }
    if (currentUserdata['image'] != null && currentUserdata['trackMe']==true) {
      var url = Uri.parse(currentUserdata['image']);
      var request = await http.get(url);
      var dataBytes = request.bodyBytes;
      locationMaker =
          BitmapDescriptor.fromBytes(dataBytes.buffer.asUint8List());
    } else {
      BitmapDescriptor.fromAssetImage(
              ImageConfiguration.empty,
              currentUserdata['post'] == 'Driver'
                  ? busIconAsset
                  : personIconAsset)
          .then((value) => locationMaker = value);
    }
    if (iconVisible==false){
      BitmapDescriptor.fromAssetImage(
          ImageConfiguration.empty,
          currentUserdata['post'] == 'Driver'
              ? busOffIconAsset
              : personOffIconAsset)
          .then((value) => locationMaker = value);
    }

    markers.add(
      Marker(
        infoWindow: InfoWindow(
            title: '${currentUserdata['post']}: ${user?.displayName}',
            snippet: 'Phone: ${currentUserdata['phone']}',
            onTap: () {
            }),
        icon: locationMaker,
        markerId: MarkerId(user?.email as String),
        position: LatLng(
            currentLocationData!.latitude!, currentLocationData!.longitude!),
      ),
    );
    allUserCompleteData.forEach((element) {
      element.forEach((key, value) async {
        if (value['image'] != null) {
          var url = Uri.parse(value['image']);
          var request = await http.get(url);
          var dataBytes = request.bodyBytes;
          locationMaker =
              BitmapDescriptor.fromBytes(dataBytes.buffer.asUint8List());
        } else {
          BitmapDescriptor.fromAssetImage(ImageConfiguration.empty,
                  value['post'] == 'Driver' ? busIconAsset : personIconAsset)
              .then((value) => locationMaker = value);
        }
        markers.add(
          Marker(
            onTap: () {
              selectedUid = key;
              selectedUserdata = value;
              destination = LatLng(double.parse(value['latitude']),
                  double.parse(value['longitude']));
              getPolyPoints();
            },
            infoWindow: InfoWindow(
                title: '${value['post']}: ${value['name']}',
                snippet: 'Call: ${value['phone']}',
                onTap: () {
                  _makePhoneCall(value['phone']);
                }),
            icon: locationMaker,
            markerId: MarkerId(key),
            position: LatLng(double.parse(value['latitude']),
                double.parse(value['longitude'])),
          ),
        );
      });
    });
    if (_mounted) {
      setState(() {});
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    if (currentUid.isNotEmpty && currentUserdata['trackMe'] != null) {
      setState(() {
        _selectedRoute = currentUserdata['route'];
        iconVisible = currentUserdata['trackMe'];
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(
              flex: 1,
              child: Text(
                'R:',
                style: TextStyle(color: Colors.black, fontSize: 20.0),
              ),
            ),
            Expanded(
              flex: 2,
              child: _selectedRoute.isNotEmpty
                  ? ((currentUserdata['post'] == 'Driver' ||
                          currentUserdata['routeAccess'] == true)
                      ? DropdownButton(
                          value: _selectedRoute,
                          items: userRoute.map((route) {
                            return DropdownMenuItem(
                              value: route,
                              child: Text(route),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRoute = value!;
                              Utils().setMyMapSettings(currentUserdata['image'],
                                  _selectedRoute, currentUserdata['trackMe']);
                            });
                          },
                        )
                      : Text(
                          currentUserdata['route'] ?? 'Loading..',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 20.0),
                        ))
                  : const Text('Loading..'),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${distanceTravelled.toStringAsFixed(2)}Km',
                style: const TextStyle(color: Colors.black, fontSize: 20.0),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Me',
                style: TextStyle(color: focusLiveLocation ? Colors.green:Colors.black, fontSize: 20.0),
              ),
              const Text('/',
                style: TextStyle(color: Colors.black, fontSize: 20.0),
              ),
              Text(selectedUid.isNotEmpty
                    ? 'Dest'
                    : 'None',
                style: TextStyle(color: !focusLiveLocation ? Colors.red:Colors.black, fontSize: 20.0),
              ),
              const SizedBox(
                height: 12.0,
              ),
              Switch(
                trackColor: MaterialStateProperty.all(Colors.black38),
                activeColor: Colors.green.withOpacity(0.4),
                inactiveThumbColor: Colors.red.withOpacity(0.4),
                activeThumbImage: AssetImage(focusIcon),
                inactiveThumbImage: AssetImage(noFocusIcon),
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
          ? Center(
              child: TextButton(
                onPressed: () {
                  getCurrentLocation();
                },
                child: const Text('Click here to Reload'),
              ),
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
                        polylineId: const PolylineId("route"),
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
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.black,
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return ZoomLevelPickerDialog( initialZoomLevel: zoomMap,);
              });
        },
        child: const Icon(Icons.settings),
      ),
    );
  }
}
