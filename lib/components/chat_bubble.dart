import 'package:firestore_poc/dto/chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  ChatDTO? chat;
  int? currentUserId;

  ChatBubble(this.chat, this.currentUserId, {super.key});

  @override
  Widget build(BuildContext context) {
    var textAlign =
        chat?.senderUserId == currentUserId ? TextAlign.right : TextAlign.left;
    final bubbleColor =
        chat?.senderUserId == currentUserId ? Colors.blue : Colors.white60;
    String minute = chat?.createdAt?.minute.toString().padLeft(2, "0") ?? "";
    String text = chat?.message ?? "";
    String createdAt =
        "${chat?.createdAt?.hour}:$minute" ?? "";
    return Container(
      child: Container(
        padding: const EdgeInsets.all(5),
        color: bubbleColor,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    textAlign: textAlign,
                    style: TextStyle(fontSize: 16),
                    softWrap: true,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    createdAt,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 10),
                    softWrap: true,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
