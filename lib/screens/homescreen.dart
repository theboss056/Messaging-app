import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messagingapp/helper/chatuser.dart';
import 'package:messagingapp/screens/loginscreen.dart';
import 'package:messagingapp/screens/profilescreen.dart';
import 'chatusercard.dart';
import 'package:messagingapp/helper/apis.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  // Future<void> _signOut() async {
  //   final auth = FirebaseAuth.instance;
  //   await auth.signOut();
  //
  //   // Optionally navigate to the login screen
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => Loginscreen()),
  //   );
  // }
  //for storing users
  List<ChatUser> list = [];
  //for storing search items
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //if search is on & back button is pressed then close search
      //or else simple close current screen on back button click
      onWillPop: () {
        if (_isSearching) {
          setState(() {
            _isSearching = !_isSearching;
          });
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        drawer: Drawer(
            backgroundColor: Colors.grey,
            child: Container(
              // decoration: BoxDecoration(
              //   image: DecorationImage(
              //       image: AssetImage('images/backgroundimage.jpg'),
              //       fit: BoxFit.cover),
              // ),
              child: ListView(
                children: [
                  ListTile(
                    tileColor: Colors.blueGrey,
                    title: const Text("settings"),
                    leading: const Icon(Icons.settings),
                    onTap: () {},
                  ),
                  // Divider(
                  //   thickness: 0.5,
                  //   color: Colors.black,
                  //   height: 20,
                  // ),
                  ListTile(
                    tileColor: Colors.blueGrey,
                    title: const Text("about"),
                    leading: const Icon(Icons.insert_chart),
                    onTap: () {},
                  ),
                  ListTile(
                    tileColor: Colors.redAccent,
                    title: const Text("LOG OUT"),
                    leading: const Icon(Icons.insert_chart),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      await GoogleSignIn().signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Loginscreen()),
                      );
                    },
                  )
                ],
              ),
            )),
        appBar: AppBar(
          backgroundColor: const Color(0x77777777),
          title: _isSearching
              ? TextField(
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: 'Name, Email, ...'),
                  autofocus: true,
                  style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                  //when search text changes then updated search list
                  onChanged: (val) {
                    //search logic
                    _searchList.clear();

                    for (var i in list) {
                      if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                          i.email.toLowerCase().contains(val.toLowerCase())) {
                        _searchList.add(i);
                        setState(() {
                          _searchList;
                        });
                      }
                    }
                  },
                )
              //from title till hera is to implement search
              : const Text('Messaging App'),
          //leading: Icon(Icons.home),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(_isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : Icons.search)),
            //IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
            //for popup
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.person),
                            title: Text('Profile'),
                            onTap: () {
                              // Handle Profile option
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Profilescreen(user: APIs.me)));
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.info),
                            title: Text('About'),
                            onTap: () {
                              // Handle About option
                              print('Navigate to About screen');
                              Navigator.pop(context); // Close the bottom sheet
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.logout),
                            title: Text('Logout'),
                            onTap: () async {
                              // Handle Logout option
                              await FirebaseAuth.instance.signOut();
                              await GoogleSignIn().signOut();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Loginscreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            //endpopup
          ],
        ),
        body: StreamBuilder(
            stream: APIs.getAllusers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

                //if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  list =
                      data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                          [];
              }

              if (list.isNotEmpty) {
                return ListView.builder(
                    itemCount: _isSearching ? _searchList.length : list.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Chatusercard(
                          user:
                              _isSearching ? _searchList[index] : list[index]);
                    });
              } else {
                return const Center(child: Text("No Connections Found"));
              }
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            //signOut add async
            // await FirebaseAuth.instance.signOut();
            // await GoogleSignIn().signOut();
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => Loginscreen()),
            // );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
