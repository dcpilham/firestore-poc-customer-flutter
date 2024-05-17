import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firestore_poc/constants/user_type.dart';
import 'package:firestore_poc/pages/chat_room.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  UserType? _userType = UserType.customer;
  final TextEditingController _orderIdController = TextEditingController();
  String? _registrationToken;

  bool _isLoading = false;
  bool _isError = false;

  @override
  void initState() {
    _initializeRegistrationToken();
    super.initState();
  }

  void _initializeRegistrationToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    setState(() {
      _registrationToken = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          TextField(
            controller: _orderIdController,
            decoration: InputDecoration(labelText: "Order ID"),
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<UserType>(
                    title: Text("Customer"),
                    value: UserType.customer,
                    groupValue: _userType,
                    onChanged: (type) => _onUserTypeChange(type)),
              ),
              Expanded(
                child: RadioListTile<UserType>(
                    title: Text("Courier"),
                    value: UserType.courier,
                    groupValue: _userType,
                    onChanged: (type) => _onUserTypeChange(type)),
              ),
            ],
          ),
          TextButton(
            onPressed:
                _isLoading || _isError ? null : () => _navigateToChatRoom(),
            child: Text("Continue"),
          ),
          Text("${_registrationToken}"),
        ],
      ),
    );
  }

  _onUserTypeChange(UserType? userType) {
    setState(() {
      _userType = userType;
    });
  }

  void _navigateToChatRoom() async {
    if (_orderIdController.text.isEmpty || _userType == null) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await FirebaseFirestore.instance
          .collection("orders")
          .doc(_orderIdController.text)
          .get();
      if (!data.exists) {
        throw Error();
      }
      Navigator.of(context).pushNamed(ChatRoom.routeName,
          arguments: ChatRoomArguments(_orderIdController.text, _userType!));
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text("Order ID does not exists"),
            );
          });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
