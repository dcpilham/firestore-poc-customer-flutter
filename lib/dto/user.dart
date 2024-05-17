import 'package:cloud_firestore/cloud_firestore.dart';

class UserDTO {
  int? id;
  String? name;
  String? phoneNumber;

  UserDTO({this.id, this.name, this.phoneNumber});

  factory UserDTO.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return UserDTO(
      id: data?["id"],
      name: data?["name"],
      phoneNumber: data?["phoneNumber"]
    );
  }
}