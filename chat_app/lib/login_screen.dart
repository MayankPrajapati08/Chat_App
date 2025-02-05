import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'user_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  late IO.Socket socket;
  String errorMessage = "";

  void connectToServer(String username) {
    socket = IO.io('http://10.0.2.2:5000', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      print("🔗 Connected to WebSocket Server");
      socket.emit('login', username);
    });

    socket.on('loginSuccess', (_) {
      print("Login successful for $username");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SelectReceiverScreen(currentUser: username),
        ),
      );
    });

    socket.on('loginError', (error) {
      setState(() {
        errorMessage = error;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Enter your username',
                errorText: errorMessage.isEmpty ? null : errorMessage,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final username = _usernameController.text;
                if (username.isNotEmpty) {
                  connectToServer(username);
                } else {
                  setState(() {
                    errorMessage = "Username can't be empty!";
                  });
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
