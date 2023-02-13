import 'package:flutter/material.dart';
import 'package:school_bus/res/assets_res.dart';

//Default variables
const String google_api_key = 'AIzaSyA1g6mpa9tyUByIKIS0eiIW04G8OmOOGp4';
const Color primaryColor = Color(0xF44336FF);
bool isEmailVerified = false;

//Dynamic variables
double distanceTravelled = 0;
double totalDistanceTravelled=0;
bool focusLiveLocation = true;
bool focusOnOff = true;

double zoomMap = 15.5; //when you increase the value it will zoom the map
bool iconVisible = true;
int delayRecording = 10;//in seconds

double bearingMap = 0;
double tiltMap = 56.440717697143555;


//Static Variables
const double defaultPadding = 16.0;

String busIconUrl = 'https://learn.geekspool.com/wp-content/uploads/mapicons/bus.png';
String personIconUrl = 'https://learn.geekspool.com/wp-content/uploads/mapicons/person.png';

const String busIconAsset = AssetsRes.BUS;
const String busOffIconAsset = AssetsRes.BUSOFF;
const String busTopIconAsset = AssetsRes.BUSTOP;
const String busTopOffIconAsset = AssetsRes.BUSOFFTOP;
const String personIconAsset = AssetsRes.PERSON;
const String personOffIconAsset = AssetsRes.PERSONOFF;

const String visibleIcon = "assets/visible.png";
const String inVisibleIcon = "assets/invisible.png";
const String focusIcon = "assets/focus.png";
const String noFocusIcon = "assets/notfocus.png";