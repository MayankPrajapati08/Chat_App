import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';

final messageProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);

class ChatScreen extends ConsumerStatefulWidget {
  final String currentUser;
  final String receiver;

  ChatScreen({required this.currentUser, required this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late IO.Socket socket;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    connectToServer();
    fetchChatHistory();
  }

  void connectToServer() {
    socket = IO.io('http://10.0.2.2:5000', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.emit('login', widget.currentUser);

    socket.on('receiveMessage', (data) {
      ref.read(messageProvider.notifier).state = [
        ...ref.read(messageProvider),
        data,
      ];
    });
  }

  void fetchChatHistory() async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:5000/messages?sender=${widget.currentUser}&receiver=${widget.receiver}'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['messages'];
      ref.read(messageProvider.notifier).state = List<Map<String, dynamic>>.from(data);
    }
  }

  void sendMessage() {
    final messageText = _controller.text.trim();
    if (messageText.isEmpty) return;

    final msgData = {
      'sender': widget.currentUser,
      'receiver': widget.receiver,
      'message': messageText,
    };
    socket.emit('sendMessage', msgData);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messageProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.receiver}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message['sender'] == widget.currentUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: message['sender'] == widget.currentUser
                          ? Colors.blue[300]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message['message']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: sendMessage,
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
