import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.socket, required this.name})
      : super(key: key);

  final WebSocket? socket;
  final String name;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class Message extends StatelessWidget {
  String recv = "";
  String sender = "";
  String content = "";
  Message(recv, sender, content);
  @override
  Widget build(BuildContext context) {
    return Text("$recv $sender \n$content");
  }
}

class _ChatPageState extends State<ChatPage> {
  String username = "";
  WebSocket? ws;
  List<Message> messages = [];

  void readWs() {
    ws?.listen((event) {
      var obj = jsonDecode(event);
      var recv = obj["recv"].toString();
      var sender = obj["sender"].toString();
      var content = obj["content"].toString();

      messages.add(Message(recv, sender, content));
    });
  }

  @override
  Widget build(BuildContext context) {
    ws = widget.socket;
    username = widget.name;

    readWs();

    List<Widget> widgets = [
      Text(
        "Welcome $username",
        textScaleFactor: 2.0,
      )
    ];
    for (var message in messages) {
      print(message.content);
      print(message.sender);
      print(message.recv);
      widgets.add(message);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
      ),
      body: Center(
          child: Column(
        children: widgets,
      )),
    );
  }
}
