import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
//import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messagingapp/helper/apis.dart';
import 'package:messagingapp/helper/chatuser.dart';
import 'package:messagingapp/helper/message.dart';
import 'package:messagingapp/helper/message_card.dart';
import 'package:messagingapp/screens/homescreen.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

class chatScreen extends StatefulWidget {
  final ChatUser user;
  const chatScreen({super.key, required this.user});
  @override
  State<chatScreen> createState() => _chatScreenState();
}

class _chatScreenState extends State<chatScreen> {
  bool isKeyboardVisible = false;

  Widget _appbar() {
    return SafeArea(
      child: InkWell(
        onTap: () {},
        child: Row(
          children: [
            SizedBox(width: 50),
            ClipRRect(
              borderRadius: BorderRadius.circular(150),
              child: CachedNetworkImage(
                height: 50,
                errorWidget: (context, url, error) =>
                    const CircleAvatar(child: Icon(CupertinoIcons.person)),
                imageUrl: widget.user.image,
                placeholder: (context, url) => CircularProgressIndicator(),
              ),
            ),
            SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text(
                  "last seen not available",
                  style: TextStyle(fontSize: 15),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _chatInput() {
    return Row(
      children: [
        Expanded(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      if (isKeyboardVisible) {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                      } else {
                        SystemChannels.textInput.invokeMethod('TextInput.show');
                      }
                      setState(() {
                        isKeyboardVisible = !isKeyboardVisible;
                      });
                    },
                    icon: Icon(
                      Icons.keyboard_alt_outlined,
                      size: 30,
                    )),
                Expanded(
                    child: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                      hintText: "type something...",
                      hintStyle: TextStyle(fontSize: 20),
                      border: InputBorder.none),
                )),
                IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
// Pick an image.
                      final List<XFile> images = await picker.pickMultiImage();
                      for (var i in images) {
                        log('image Path:${i.path} ');
                        await APIs.sendChatImage(widget.user, File(i.path));
                      }
                    },
                    icon: Icon(
                      Icons.file_present_outlined,
                      size: 30,
                    )),
                IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
// Pick an image.
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        log('image Path:${image.path} ');

                        await APIs.sendChatImage(widget.user, File(image.path));
                        //for hiding bottom sheet
                        // Navigator.pop(context);
                      }
                    },
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      size: 30,
                    )),
              ],
            ),
          ),
        ),
        IconButton(
          //focusColor: Colors.brown,
          //  hoverColor: Colors.orange,
          //highlightColor: Colors.yellow,
          color: Colors.green,
          onPressed: () {
            if (_textController.text.isNotEmpty) {
              APIs.sendMessage(widget.user, _textController.text, Type.text);
              _textController.text = "";
            }
          },
          icon: Icon(
            Icons.send,
            size: 35,
          ),
        )
      ],
    );
  }

  //for handling text message changes
  final _textController = TextEditingController();

  // for storing all messages
  List<Message> _list = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0x99999999),
        leading: BackButton(
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Homescreen()));
          },
        ),
        flexibleSpace: _appbar(),
      ),
      //backgroundColor: Color(0xFFDABE98),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: APIs.getAllMessages(widget.user),
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
                      // log('data:${jsonEncode(data![0].data())}');
                      _list = data
                              ?.map((e) => Message.fromJson(e.data()))
                              .toList() ??
                          [];
                  }

                  if (_list.isNotEmpty) {
                    return ListView.builder(
                        reverse: true,
                        itemCount: _list.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Messagecard(
                            message: _list[index],
                          );
                        });
                  } else {
                    return const Center(
                        child: Text(
                      "Say Hii !👋",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ));
                  }
                }),
          ),
          _chatInput(),
        ],
      ),
    );
  }
}
