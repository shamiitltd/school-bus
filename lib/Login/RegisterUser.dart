import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:school_bus/Login/LoginWidget.dart';
import 'package:school_bus/Login/Utils.dart';

import '../constant.dart';
import 'countryData.dart';

class RegisterUser extends StatefulWidget {
  const RegisterUser({Key? key}) : super(key: key);

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final _formKey = GlobalKey<FormState>();
  final displayNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassController = TextEditingController();
  String _selectedCountryCode = '';
  String _selectedCountryName = '';
  String _selectedYourPost = '';
  String _selectedYourRoute = '';
  List<String> uniquelist = [];
  Map<String, String> _countries = {};
  void addDropDownMenu() async {
    List<String> postList = [];
    List<String> routeList = [];

    final databaseReference = FirebaseDatabase.instance.ref();
    for (var i = 0; i < countryNames.length; i++) {
      _countries[countryNames[i]] = '+${countryAreaCodes[i]}';
    }

    await databaseReference
        .child("routes")
        .onValue
        .listen((DatabaseEvent event) {
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        routeList.add(value);
      });
      setState(() {
        userRoute = routeList;
        _selectedYourRoute = userRoute[0];
      });
    });
    await databaseReference
        .child("posts")
        .onValue
        .listen((DatabaseEvent event) {
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        postList.add(value);
      });
      setState(() {
        userPosts = postList;
        _selectedYourPost = userPosts[0];
      });
    });
    var seen = Set<String>();
    uniquelist = countryNames.where((country) => seen.add(country)).toList();
    _selectedCountryName = uniquelist[0];
    _selectedCountryCode = _countries[_selectedCountryName]!;
  }

  @override
  void initState() {
    super.initState();
    addDropDownMenu();
  }

  @override
  void dispose() {
    displayNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  bool isValidPhoneNumber(String? value) =>
      RegExp(r'(^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$)')
          .hasMatch(value ?? '');

  Future checkEmailVerified() async {
    var user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      user.reload();
      setState(() {
        isEmailVerified = user.emailVerified;
      });
    }
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
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Enter your Name'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 2
                    ? 'Please enter a valid name'
                    : null,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                  _formKey.currentState!.save();
                },
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text('Select Post:'),
                    flex: 2,
                  ),
                  Expanded(
                    flex: 3,
                    child: (_selectedYourPost.isNotEmpty)
                        ? DropdownButton(
                            value: _selectedYourPost,
                            items: userPosts.map((country) {
                              return DropdownMenuItem(
                                value: country,
                                child: Text(country),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedYourPost = value!;
                              });
                            },
                          )
                        : Text('Loading...'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text('Select Route:'),
                    flex: 2,
                  ),
                  Expanded(
                    flex: 3,
                    child: (_selectedYourRoute.isNotEmpty)
                        ? DropdownButton(
                            value: _selectedYourRoute,
                            items: userRoute.map((country) {
                              return DropdownMenuItem(
                                value: country,
                                child: Text(country),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedYourRoute = value!;
                              });
                            },
                          )
                        : Text('Loading...'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text('Select country:'),
                    flex: 2,
                  ),
                  Expanded(
                    flex: 3,
                    child: DropdownButton(
                      value: _selectedCountryName,
                      items: uniquelist.map((country) {
                        return DropdownMenuItem(
                          value: country,
                          child: Text(country),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCountryCode = _countries[value]!;
                          _selectedCountryName = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: phoneController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Enter phone number',
                  hintText: 'Enter phone number',
                  prefixText: _selectedCountryCode,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => !isValidPhoneNumber(value)
                    ? "Enter Correct phone number"
                    : null,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                  _formKey.currentState!.save();
                },
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: emailController,
                textInputAction: TextInputAction.next,
                decoration:
                    const InputDecoration(labelText: 'Enter your email'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) =>
                    email != null && !EmailValidator.validate(email)
                        ? 'Enter a valid email'
                        : null,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                  _formKey.currentState!.save();
                },
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: passwordController,
                textInputAction: TextInputAction.next,
                decoration:
                    const InputDecoration(labelText: 'Enter your Password'),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 6
                    ? 'Enter min 6 characters'
                    : null,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).unfocus();
                  _formKey.currentState!.save();
                },
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: confirmPassController,
                textInputAction: TextInputAction.next,
                decoration:
                    const InputDecoration(labelText: 'Confirm your Password'),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 6
                    ? 'Enter min 6 characters'
                    : null,
                onFieldSubmitted: (_) {
                  _formKey.currentState!.validate();
                  _formKey.currentState!.save();
                },
              ),
              const SizedBox(height: 5),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      registerNewUser(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                          confirmPassController.text.trim(),
                          displayNameController.text.trim(),
                          _selectedYourPost,
                          _selectedYourRoute,
                          _selectedCountryCode+phoneController.text.trim());
                      // Submit form data here...
                    }
                  },
                  icon: const Icon(
                    Icons.lock_open,
                    size: 32,
                  ),
                  label: const Text(
                    'Register',
                    style: TextStyle(fontSize: 24),
                  )),
              const SizedBox(height: 24),
              GestureDetector(
                child: Text(
                  'Back to Login',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context)
                      .pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginWidget(),
                    ),
                  )
                      .then((_) {
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

  Future registerNewUser(
      String email,
      String password,
      String confirmPassword,
      String displayName,
      _selectedYourPost,
      _selectedYourRoute,
      phoneNumber) async {
    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        displayName.isEmpty) {
      return;
    }
    if (password != confirmPassword) {
      Utils.showSnackBar('Password and Confirm Password should be same');
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      final result = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      user?.updateDisplayName(displayName);
      print('User created: ${user?.uid}');
      String iconUrl = _selectedYourPost=='Driver'?busIconUrl:personIconUrl;
      Utils().setMyMapSettings(iconUrl, _selectedYourRoute, true);
      if(_selectedYourPost == 'Driver' || _selectedYourPost == 'Director') {
        Utils().setUserInfo(_selectedYourPost, phoneNumber, displayName, true);
      }else{
        Utils().setUserInfo(_selectedYourPost, phoneNumber, displayName, false);
      }
      Location location = Location();
      location.getLocation().then((value) {
        setState(() {
          LocationData? currentLocationData = value;
          Utils().setMyCoordinates(currentLocationData.latitude!.toString(), currentLocationData.longitude!.toString());
        });
      });

      // ignore: use_build_context_synchronously
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
      Navigator.of(context).pop();
    }
  }
}
