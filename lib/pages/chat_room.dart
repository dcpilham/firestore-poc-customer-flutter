import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firestore_poc/components/chat_bubble.dart';
import 'package:firestore_poc/constants/user_type.dart';
import 'package:firestore_poc/dto/chat.dart';
import 'package:firestore_poc/dto/chat_room.dart';
import 'package:firestore_poc/dto/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ChatRoomArguments {
  String orderId;
  UserType userType;

  ChatRoomArguments(this.orderId, this.userType);
}

class ChatRoom extends StatefulWidget {
  static const String routeName = "/chat-room";
  final ChatRoomArguments args;
  final Dio dio;

  ChatRoom(this.args, {required this.dio});

  @override
  State<StatefulWidget> createState() {
    return _ChatRoomState();
  }
}

class _ChatRoomState extends State<ChatRoom> {
  TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .doc(widget.args.orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            ChatRoomDTO chatRoomDTO = ChatRoomDTO.fromFirestore(snapshot.data);
            String? recipient = UserType.customer == widget.args.userType
                ? chatRoomDTO.courier!.name
                : chatRoomDTO.customer!.name;
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.tealAccent,
                title: Text(recipient ?? ""),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.topCenter,
                      child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("orders")
                              .doc(widget.args.orderId)
                              .collection("chats")
                              .orderBy("createdAt", descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            final currentUserId =
                                UserType.courier == widget.args.userType
                                    ? chatRoomDTO.courier?.id
                                    : chatRoomDTO.customer?.id;
                            if (snapshot.hasData) {
                              final chats = snapshot.data?.docs
                                  .map((e) => ChatDTO.fromFirestore(e))
                                  .toList();
                              return ListView.builder(
                                  shrinkWrap: true,
                                  reverse: true,
                                  itemCount: chats?.length,
                                  itemBuilder: (e, index) =>
                                      ChatBubble(chats?[index], currentUserId));
                            }
                            return Container();
                          }),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          controller: _chatController,
                        )),
                        IconButton(
                            onPressed: () => _sendDataToFireStore(chatRoomDTO),
                            icon: const Icon(
                              Icons.send,
                              color: Colors.green,
                            ))
                      ],
                    ),
                  )
                ],
              ),
            );
            return Text(snapshot.data?["customer"]["name"]);
          } else if (snapshot.hasError) {
            return Text("ERROR");
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  _sendDataToFireStore(ChatRoomDTO chatRoomDTO) async {
    if (_chatController.text.isEmpty) {
      return;
    }
    final sender = UserType.courier == widget.args.userType
        ? chatRoomDTO.courier
        : chatRoomDTO.customer;
    final recipient = UserType.customer == widget.args.userType
        ? chatRoomDTO.courier
        : chatRoomDTO.customer;
    Map<String, dynamic> data = {
      "senderUserId": sender?.id,
      "message": _chatController.text,
      "createdAt": Timestamp.now()
    };
    await FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.args.orderId)
        .collection("chats")
        .add(data);
    await _sendPushNotification(sender, recipient, _chatController.text);
    setState(() {
      _chatController.text = "";
    });
  }

  _sendPushNotification(
      UserDTO? sender, UserDTO? recipient, String message) async {
    final token = await FirebaseMessaging.instance.getToken();
    final data = {
      "title": sender?.name,
      "body": message,
      "targetTopic": "orders-${widget.args.orderId}-${recipient?.phoneNumber}",
    };
    widget.dio.options.headers["content-type"] = "application/json";
    widget.dio.post("http://10.0.2.2:8080/v1/push-notifications/send-chat",
        data: data);
  }
}
