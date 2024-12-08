import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messagingapp/helper/apis.dart';
import 'package:messagingapp/helper/dialogs.dart';

import 'homescreen.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  // Future<void> _signInWithGoogle() async {
  //   // Trigger the Google sign-in flow
  //   final googleSignIn = GoogleSignIn();
  //
  //   final GoogleSignInAccount? account = await googleSignIn.signIn();
  //
  //   if (account != null) {
  //     // Handle successful sign-in
  //
  //     final GoogleSignInAuthentication auth = await account.authentication;
  //
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: auth.accessToken,
  //       idToken: auth.idToken,
  //     );
  //
  //     // Sign in to Firebase with the credential
  //
  //     await FirebaseAuth.instance.signInWithCredential(credential);
  //
  //     // Navigate to the home screen (or handle user data)
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => Homescreen()),
  //     );
  //   } else {
  //     // Handle sign-in cancellation or error
  //     print('Sign in cancelled');
  //   }
  // }

  //new on
  _handleGoogleBtnClick() {
    //for showing the ProgressBar
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      //to remove the progressbar as soon as user login
      Navigator.pop(context);
      if (user != null) {
        log('\nUser:${user.user}');
        log('\nUserAdditionalInfo:${user.additionalUserInfo}');

        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const Homescreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const Homescreen()));
          });
        }
      }
    });
  }

  //and then pasted from Federated identity & social sign-in
  //used ? as it can  also return null
  Future<UserCredential?> _signInWithGoogle() async {
    //underscore signIn for making this as private
    // Trigger the authentication flow
    //for internet check we did try catch and added first line
    try {
      await InternetAddress.lookup("google.com");
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      //for printing the error
      log("\n_signInWithGoogle:$e");
      //for dialogue snackbar checking internet
      Dialogs.showSnackbar(context, "Check internet!");
      return null;
    }
  }
  //finish

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Center(child: Text("Messaging App")),
        ),
        body: Stack(children: [
          Column(
            children: [
              Center(
                child: Container(
                  height: 400,
                  child: Image.asset("images/gossip2.png"),
                ),
              ),
              Container(
                height: 40,
                width: 380,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _handleGoogleBtnClick();
                  },
                  icon: Image.asset("images/google_image.png"),
                  label: const Text("Sign in With Google"),
                ),
              ),
            ],
          ),
        ]));
  }
}
