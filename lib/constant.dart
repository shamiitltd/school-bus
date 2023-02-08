import 'package:flutter/material.dart';

//Default variables
const String google_api_key = 'AIzaSyA1g6mpa9tyUByIKIS0eiIW04G8OmOOGp4';
const Color primaryColor = Color(0xF44336FF);
bool isEmailVerified = false;

//Dynamic variables
double distanceTravelled = 0;
bool focusLiveLocation = true;
double zoomMap = 15.5; //when you increase the value it will zoom the map
bool iconVisible = true;

//Static Variables
const double defaultPadding = 16.0;

String busIconUrl = 'https://learn.geekspool.com/wp-content/uploads/mapicons/bus.png';
String personIconUrl = 'https://learn.geekspool.com/wp-content/uploads/mapicons/person.png';

const String busIconAsset = "assets/bus.png";
const String busOffIconAsset = "assets/busoff.png";
const String personIconAsset = "assets/person.png";
const String personOffIconAsset = "assets/personoff.png";

const String focusIcon = "assets/focus.png";
const String noFocusIcon = "assets/notfocus.png";