import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../constant.dart';

class ZoomLevelPickerDialog extends StatefulWidget {
  final double initialZoomLevel;

  const ZoomLevelPickerDialog({super.key, required this.initialZoomLevel});

  @override
  ZoomLevelPickerDialogState createState() => ZoomLevelPickerDialogState();
}

class ZoomLevelPickerDialogState extends State<ZoomLevelPickerDialog> {
  /// current selection of the slider
  late double zoomLeveVal;

  @override
  void initState() {
    super.initState();
    zoomLeveVal = widget.initialZoomLevel;
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
            "Zoom Level: ${zoomLeveVal.toStringAsFixed(2)}",
          ),
          Slider(
            label: "Zoom Map",
            value: zoomLeveVal,
            onChanged: (value) {
              zoomLeveVal = value;
              setState(() {
              });
            },
            min: 0.0,
            max: 22.0,
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
            child: const Text("Save")),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel")),
      ],
    );
  }
}