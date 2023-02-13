import 'package:flutter_compass/flutter_compass.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../Login/Utils.dart';
import '../constant.dart';

class ZoomLevelPickerDialog extends StatefulWidget {
  final double initialZoomLevel;
  final bool destSelected;
  const ZoomLevelPickerDialog(
      {super.key, required this.initialZoomLevel, required this.destSelected});

  @override
  ZoomLevelPickerDialogState createState() => ZoomLevelPickerDialogState();
}

class ZoomLevelPickerDialogState extends State<ZoomLevelPickerDialog> {
  late double zoomLeveVal;
  late bool destinationSelected;
  double? heading;
  bool _mounted = true;

  @override
  void dispose() {
    _mounted=false;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    zoomLeveVal = widget.initialZoomLevel;
    destinationSelected = widget.destSelected;
    getTotalDistanceTravelled();

    FlutterCompass.events?.listen((event) {
      if (_mounted) {
        setState(() {
          heading = event.heading;
        });
      }
    });
  }


  Future<void> getTotalDistanceTravelled() async {
    final prefs = await SharedPreferences.getInstance();
    double? distance = prefs.getDouble('totalDistance');
    if(_mounted) {
      setState(() {
      totalDistanceTravelled = distance ?? 0;
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Map settings"),
      scrollable: true,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Zoom Level: ${zoomLeveVal.toStringAsFixed(2)} [Must Save]",
          ),
          Slider(
            label: "Zoom Map",
            value: zoomLeveVal,
            onChanged: (value) {
              zoomLeveVal = value;
              setState(() {});
            },
            min: 0.0,
            max: 22.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Visible ?',
                style: TextStyle(color: Colors.black, fontSize: 20.0),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: LiteRollingSwitch(
                  width: 130,
                  //initial value
                  onTap: () => {},
                  onDoubleTap: () => {},
                  onSwipe: () => {},
                  value: iconVisible,
                  textOn: 'Visible',
                  textOff: 'InVisible',
                  colorOn: Colors.greenAccent[700] as Color,
                  colorOff: Colors.redAccent[700] as Color,
                  iconOn: Icons.remove_red_eye,
                  iconOff: Icons.highlight_off,
                  textSize: 16.0,
                  onChanged: (bool state) {
                    setState(() {
                      iconVisible = state;
                      Utils().setTraceMeSettings(state);
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Focus ?',
                style: TextStyle(color: Colors.black, fontSize: 20.0),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: LiteRollingSwitch(
                  width: 130,
                  //initial value
                  onTap: () => {},
                  onDoubleTap: () => {},
                  onSwipe: () => {},
                  value: focusOnOff,
                  textOn: 'Focus',
                  textOff: 'No Focus',
                  colorOn: Colors.greenAccent[700] as Color,
                  colorOff: Colors.redAccent[700] as Color,
                  iconOn: Icons.done,
                  iconOff: Icons.remove_circle_outline,
                  textSize: 16.0,
                  onChanged: (bool state) {
                    setState(() {
                      focusOnOff = state;
                      // focusLiveLocation = value;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Focus Me/Dest',
                style: TextStyle(color: Colors.black, fontSize: 20.0),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: LiteRollingSwitch(
                  width: 100,
                  //initial value
                  onTap: () => {},
                  onDoubleTap: () => {},
                  onSwipe: () => {},
                  value: focusLiveLocation,
                  textOn: 'Me',
                  textOff: destinationSelected ? 'Dest' : 'None',
                  colorOn: Colors.greenAccent[700] as Color,
                  colorOff: destinationSelected
                      ? Colors.blue[700] as Color
                      : Colors.redAccent[700] as Color,
                  iconOn: Icons.done,
                  iconOff: destinationSelected
                      ? Icons.other_houses
                      : Icons.remove_circle_outline,
                  textSize: 16.0,
                  onChanged: (bool state) {
                    setState(() {
                      focusLiveLocation = state;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('T-Distance',
                  style: TextStyle(color: Colors.black, fontSize: 20.0)),
              Text('${totalDistanceTravelled.toStringAsFixed(2)}Km',
                  style: const TextStyle(color: Colors.black, fontSize: 20.0)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Angle:',
                  style: TextStyle(color: Colors.black, fontSize: 20.0)),
              Text('${heading?.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.black, fontSize: 20.0)),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setDouble('zoom', zoomLeveVal);
              setState(() {
                zoomMap = zoomLeveVal.toDouble();
              });
              Navigator.pop(context);
            },
            child: const Text("Ok")),
      ],
    );
  }
}
