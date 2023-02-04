import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:school_bus/distduration.dart';
import 'package:school_bus/simplemap.dart';
import 'package:school_bus/todomain.dart';

import 'Login/LoginActivity.dart';
import 'Login/LoginWidget.dart';
import 'Login/Utils.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({Key? key}) : super(key: key);

   final Future<FirebaseApp> initializeApp = Firebase.initializeApp(
       options: const FirebaseOptions(
           apiKey: "AIzaSyAp94KJo0DDjDEHr4rgrrbv0-Q-aZRp_zA",
           authDomain: "school-erp-1.firebaseapp.com",
           databaseURL: "https://school-erp-1-default-rtdb.firebaseio.com",
           projectId: "school-erp-1",
           storageBucket: "school-erp-1.appspot.com",
           messagingSenderId: "35032464117",
           appId: "1:35032464117:web:53fe0026965ee32e07a3bc",
           measurementId: "G-4Z2VBTH0BN"
       )
   );
   final navigatorKey = GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: Utils.messangerKey,
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      // home: OrderTrackingPage(),
      // home: TodoMain(),
      home:FutureBuilder(
        future: initializeApp,
        builder: (context, snapshot) {
          if(snapshot.hasError){
            print(snapshot.error);
            print("Error is present");
          }
          if(snapshot.connectionState == ConnectionState.done){
            // return TodoMain();
            return OrderTrackingPage();
            // return LoginActivity();
          }
          return CircularProgressIndicator();
        }
      ),
    );
  }
}
