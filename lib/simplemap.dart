import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class smOrderTrackingPage extends StatefulWidget {
  const smOrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<smOrderTrackingPage> createState() => smOrderTrackingPageState();
}

class smOrderTrackingPageState extends State<smOrderTrackingPage> {

  static const LatLng sourceLocation = LatLng(37.411, -122.072);
  static const LatLng destination = LatLng(37.4227, -122.084);


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    // getPolyPoints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track order",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body:GoogleMap(
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        initialCameraPosition: CameraPosition(
            target: sourceLocation,
        ),
      ),
    );
  }
}
