import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDTO {
  int? senderUserId;
  DateTime? createdAt;
  String? message;

  ChatDTO({this.senderUserId, this.createdAt, this.message});

  factory ChatDTO.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      ) {
    final data = snapshot.data();
    if (snapshot.data()!.isNotEmpty) {
      return ChatDTO(
          senderUserId: data?["senderUserId"],
          createdAt: DateTime.fromMillisecondsSinceEpoch(
              (data?["createdAt"] as Timestamp).millisecondsSinceEpoch),
          message: data?["message"]
      );
    }
    return ChatDTO();
  }
}