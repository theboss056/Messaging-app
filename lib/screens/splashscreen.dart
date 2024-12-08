import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messagingapp/screens/homescreen.dart';
import 'loginscreen.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});
  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const Loginscreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const Homescreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: [
          Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Container(
                height: 50,
                child: Center(
                    child: Text(
                  "   Welcome to ",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w300),
                )),
              ),
              Container(
                height: 50,
                child: Center(
                    child: Text(
                  " Messaging App",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w300),
                )),
              ),
              Container(
                height: 400,
                child: Image.asset("images/gossip2.png"),
              ),
              Container(
                height: 200,
                width: 380,
                child: Center(child: Text("Made in Bharat with ❤️")),
              ),
            ],
          ),
        ]));
  }
}
