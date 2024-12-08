import 'dart:developer';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messagingapp/helper/apis.dart';
import 'package:messagingapp/helper/chatuser.dart';
import 'package:messagingapp/helper/dialogs.dart';
import 'package:messagingapp/screens/loginscreen.dart';
import 'package:messagingapp/screens/profilescreen.dart';

class Profilescreen extends StatefulWidget {
  final ChatUser user;
  const Profilescreen({Key? key, required this.user}) : super(key: key);

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  final _formkey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //to hide the keyboard when we tap anywhere on the screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Center(child: Text("  Profile            ")),
          ),
          // floatingActionButton: Padding(
          //   padding: const EdgeInsets.only(bottom: 10),
          //   child: FloatingActionButton.extended(
          //       backgroundColor: Colors.redAccent,
          //       onPressed: () async {
          //         await FirebaseAuth.instance.signOut();
          //         await GoogleSignIn().signOut();
          //         Navigator.pushReplacement(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (context) => const Loginscreen()));
          //         //for showing progress dialog
          //       },
          //       icon: const Icon(Icons.logout),
          //       label: const Text('Logout')),
          // ),
          body: Form(
            key: _formkey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(500),
                                child: Image.file(
                                  File(_image!),
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.fill,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(500),
                                child: CachedNetworkImage(
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.fill,
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                          child: Icon(CupertinoIcons.person)),
                                  imageUrl: widget.user.image,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                ),
                              ),
                        Positioned(
                          bottom: 8,
                          right: 0,
                          child: MaterialButton(
                            onPressed: () {
                              _showbottomsheet();
                            },
                            shape: CircleBorder(),
                            color: Colors.indigoAccent.shade100,
                            child: Icon(Icons.edit),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.user.email,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 350,
                    child: TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (val) => APIs.me.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person,
                              color: Colors.indigoAccent),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(200)),
                          //hintText: 'eg. Happy Singh',
                          label: const Text('Name')),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 350,
                    child: TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => APIs.me.about = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.info_outline,
                              color: Colors.indigoAccent),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(200)),
                          // hintText: 'eg. Feeling Happy',
                          label: const Text('About')),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // update profile button
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        _formkey.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnackbar(
                              context, 'Profile Updated Successfully!');
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      //  minimumSize: Size(mq.width * .5, mq.height * .06)),
                    ),
                    icon: const Icon(Icons.edit, size: 28),
                    label: const Text('UPDATE', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  void _showbottomsheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Text(
              "pick profile picture",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: Icon(Icons.sd_storage_outlined),
              title: Text(
                'Add from storage',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                // Handle About option
                // Close the bottom sheet
                final ImagePicker picker = ImagePicker();
// Pick an image.
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  log('image Path:${image.path} --MimeType:${image.mimeType}');
                  setState(() {
                    _image = image.path;
                  });
                  APIs.updateProfilePicture(File(_image!));
                  //for hiding bottom sheet
                  Navigator.pop(context);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.add_a_photo_outlined),
              title: Text(
                'Add from Camera',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                // Handle About option
                // Close the bottom sheet
                final ImagePicker picker = ImagePicker();
// Pick an image.
                final XFile? image =
                    await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  log('image Path:${image.path} ');
                  setState(() {
                    _image = image.path;
                  });
                  APIs.updateProfilePicture(File(_image!));
                  //for hiding bottom sheet
                  Navigator.pop(context);
                }
              },
            ),
          ]));
        });
  }
}
