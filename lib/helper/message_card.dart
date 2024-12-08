import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messagingapp/helper/apis.dart';
import 'package:messagingapp/helper/message.dart';
import 'package:messagingapp/helper/my_date_util.dart';
import 'package:messagingapp/screens/chatScreen.dart';

class Messagecard extends StatefulWidget {
  const Messagecard({super.key, required this.message});

  final Message message;

  @override
  State<Messagecard> createState() => _MessagecardState();
}

class _MessagecardState extends State<Messagecard> {
  Widget _blueMessage() {
    //update last read message
    if (widget.message.read.isNotEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      log("message received");
      // print("something ");
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.all(3),
            decoration: BoxDecoration(
                color: Color(0x776BF67E),
                //border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20))),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      height: 200,
                      width: 200,
                      imageUrl: widget.message.msg,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 15, right: 5),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 10),
          ),
        )
      ],
    );
  }

  Widget _greenMessage() {
    //update last read message
    if (widget.message.read.isNotEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      log("message recieved");
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.all(3),
            decoration: BoxDecoration(
                color: Color(0x77E8ECB9),
                //border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20))),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      height: 200,
                      width: 200,
                      imageUrl: widget.message.msg,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
        Container(
          // padding: EdgeInsets.only(top: 20, right: 5),
          child: Row(
            children: [
              Text(
                MyDateUtil.getFormattedTime(
                    context: context, time: widget.message.sent),
                style: TextStyle(fontSize: 12),
              ),

              //double tick blue icon when read
              if (widget.message.read.isNotEmpty)
                Icon(
                  Icons.done_all_rounded,
                  size: 15,
                  color: Colors.red,
                )
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
  }
}
