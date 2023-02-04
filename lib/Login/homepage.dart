import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_bus/FirebaseData/showDataInCard.dart';
import 'package:school_bus/Login/verifyUser.dart';
import 'package:school_bus/constant.dart';


class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    // return DataCard(databaseRef: 'todos/king');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Signed In as ${user.displayName}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              user.email!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                icon: const Icon(
                  Icons.logout,
                  size: 32,
                ),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 24),
                )),
            const SizedBox(height: 40),
            isEmailVerified
                ? const Text(
                    'Verified',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50)),
                    onPressed: () async {
                      VerifyUser();
                    },
                    icon: const Icon(
                      Icons.logout,
                      size: 32,
                    ),
                    label: const Text(
                      'Send verification',
                      style: TextStyle(fontSize: 24),
                    )),
          ],
        ),
      ),
    );
  }
}
