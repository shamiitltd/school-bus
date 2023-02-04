import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_bus/Login/LoginWidget.dart';
import 'package:school_bus/Login/Utils.dart';

import '../constant.dart';


class RegisterUser extends StatefulWidget {
  const RegisterUser({Key? key}) : super(key: key);

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassController = TextEditingController();
  final displayNameController = TextEditingController();


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPassController.dispose();
    displayNameController.dispose();
    super.dispose();
  }

  Future checkEmailVerified() async{
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    return isEmailVerified;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form'),
        backgroundColor: Colors.orange,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 40),
              TextFormField(
                controller: displayNameController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration:const InputDecoration(
                    labelText: 'Enter your Name'
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 2? 'Please enter a valid name':null,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                  _formKey.currentState!.save();
                },
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: emailController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration:const InputDecoration(
                    labelText: 'Enter your email'
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) => email != null && !EmailValidator.validate(email)? 'Enter a valid email':null,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                  _formKey.currentState!.save();
                },
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: passwordController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    labelText: 'Enter your Password'
                ),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 6? 'Enter min 6 characters':null,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).unfocus();
                  _formKey.currentState!.save();
                },
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: confirmPassController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    labelText: 'Confirm your Password'
                ),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 6? 'Enter min 6 characters':null,
                onFieldSubmitted: (_) {
                  _formKey.currentState!.validate();
                  _formKey.currentState!.save();
                },
              ),
              const SizedBox(height: 5),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      registerNewUser(emailController.text.trim(), passwordController.text.trim(), confirmPassController.text.trim(), displayNameController.text.trim());
                      // Submit form data here...
                    }
                  },
                  icon: const Icon(Icons.lock_open, size: 32,),
                  label: const Text(
                    'Register',
                    style: TextStyle(fontSize: 24),
                  )
              ),
              const SizedBox(height: 24),
              GestureDetector(
                child: Text(
                  'Back to Login',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 20
                  ),
                ),
                onTap: (){
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginWidget(),
                    ),
                  ).then((_) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  });
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  Future registerNewUser(String email, String password, String confirmPassword, String displayName) async{
    if(email.isEmpty || password.isEmpty || confirmPassword.isEmpty || displayName.isEmpty){
      return;
    }
    if(password != confirmPassword ){
      Utils.showSnackBar('Password and Confirm Password should be same');
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context)=> const Center(child: CircularProgressIndicator())
    );

    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      final result = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      User? user = result.user;
      user?.updateDisplayName(displayName);
      print('User created: ${user?.uid}');
      // ignore: use_build_context_synchronously
      Navigator.of(context).popUntil((route) => route.isFirst);
    }  on FirebaseAuthException catch(e){
      Utils.showSnackBar(e.message);
      Navigator.of(context).pop();
    }

  }
}
