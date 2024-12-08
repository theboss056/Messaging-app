import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messagingapp/helper/apis.dart';
import 'package:messagingapp/helper/chatuser.dart';
import 'package:messagingapp/helper/message.dart';
import 'package:messagingapp/helper/my_date_util.dart';
import 'package:messagingapp/screens/chatScreen.dart';

class Chatusercard extends StatefulWidget {
  final ChatUser user;
  const Chatusercard({Key? key, required this.user}) : super(key: key);

  @override
  State<Chatusercard> createState() => _ChatusercardState();
}

class _ChatusercardState extends State<Chatusercard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => chatScreen(
                        user: widget.user,
                      )));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessages(widget.user),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) _message = list[0];

            // log('data:${jsonEncode(data![0].data())}');
            // _list = data
            //     ?.map((e) => Message.fromJson(e.data()))
            //     .toList() ??
            //     [];
            return Card(
              child: ListTile(
                title: Text(widget.user.name),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                    errorWidget: (context, url, error) =>
                        const CircleAvatar(child: Icon(CupertinoIcons.person)),
                    imageUrl: widget.user.image,
                    placeholder: (context, url) => CircularProgressIndicator(),
                  ),
                ),
                subtitle: Text(
                    _message != null
                        ? (_message!.type == Type.image
                            ? 'Image'
                            : _message!.msg)
                        : widget.user.about,
                    maxLines: 1),
                // trailing: //last message time
                trailing: _message == null
                    ? null //show nothing when no message is sent
                    :

                    // _message!.read.isEmpty &&
                    //             _message!.fromId != APIs.user.uid
                    //         ?
                    //         //show for unread message
                    //         Container(
                    //             width: 15,
                    //             height: 15,
                    //             decoration: BoxDecoration(
                    //                 color: Colors.greenAccent.shade400,
                    //                 borderRadius: BorderRadius.circular(10)),
                    //           )
                    //         :
                    //message sent time
                    Text(
                        MyDateUtil.getLastMessageTime(
                            context: context, time: _message!.sent),
                        style: const TextStyle(color: Colors.black54),
                      ),

                //here
              ),
            );
          },
        ));
  }
}
