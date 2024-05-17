import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_poc/pages/chat_room.dart';
import 'package:firestore_poc/dto/chat.dart';
import 'package:firestore_poc/dto/user.dart';

class ChatRoomDTO {
  UserDTO? customer;
  UserDTO? courier;
  List<ChatDTO>? chats;

  ChatRoomDTO({this.customer, this.courier, this.chats});
  
  factory ChatRoomDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>>? snapshot) {
    final data = snapshot;

    return ChatRoomDTO(
      customer: UserDTO(id: data?["customer"]["id"], name: data?["customer"]["name"], phoneNumber: data?["customer"]["phoneNumber"]),
      courier: UserDTO(id: data?["courier"]["id"], name: data?["courier"]["name"], phoneNumber: data?["courier"]["phoneNumber"]),
    );
  }
}