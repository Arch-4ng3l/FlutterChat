import 'dart:convert';
import 'dart:io';
import 'package:chat_app/chat.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(title: 'Login'),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  WebSocket? ws;
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  String message = "";
  String token = "";
  String username = "";

  @override
  void dispose() {
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  void connect() async {
    ws = await WebSocket.connect("ws://localhost:3000/api",
        headers: <String, String>{
          "token": token,
        });
    if (ws == null) {
      return;
    }
  }

  void _readText() async {
    message = "";
    username = usernameController.text;
    var response = await http.post(Uri.parse("http://localhost:3000/api/login"),
        body: jsonEncode(<String, String>{
          "username": username,
          "password": passwordController.text,
        }));
    var obj = jsonDecode(response.body);
    if (obj["token"] == null) {
      message = obj["error"];
      return;
    }
    token = obj["token"];
    connect();
    openChat();
  }

  void openChat() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ChatPage(socket: ws, name: username);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              message,
              textScaleFactor: 10,
              selectionColor: const Color.fromRGBO(255, 0, 0, 100),
            ),
            const Text("Password"),
            TextField(
              obscureText: true,
              controller: passwordController,
            ),
            const Text("Email"),
            TextField(
              controller: usernameController,
            ),
            ElevatedButton(onPressed: _readText, child: const Icon(Icons.add)),
          ],
        ),
      ),
    );
  }
}
