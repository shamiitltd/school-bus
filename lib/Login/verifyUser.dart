
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_bus/Login/Utils.dart';
import 'package:school_bus/constant.dart';

class VerifyUser {
  VerifyUser(){
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if(!isEmailVerified){
      sendVerificationEmail();
    }
  }
  Future sendVerificationEmail() async{
    try{
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      Utils.showSnackBar('Email for verification has been sent check your inbox');
    }catch(e){
      Utils.showSnackBar(e.toString());
    }
  }
}
