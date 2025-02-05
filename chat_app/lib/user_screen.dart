import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'chat_screen.dart';

final userListProvider = StateProvider<List<String>>((ref) => []);

class SelectReceiverScreen extends ConsumerStatefulWidget {
  final String currentUser;
  SelectReceiverScreen({required this.currentUser});

  @override
  _SelectReceiverScreenState createState() => _SelectReceiverScreenState();
}

class _SelectReceiverScreenState extends ConsumerState<SelectReceiverScreen> {
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    connectToServer();
  }

  void connectToServer() {
    socket = IO.io('http://10.0.2.2:5000', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      socket.emit('login', widget.currentUser);
    });

    socket.on('userList', (data) {
      ref.read(userListProvider.notifier).state = List<String>.from(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(userListProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Select a Receiver')),
      body: users.isEmpty
          ? Center(child: Text("No users available"))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                if (user == widget.currentUser) return SizedBox.shrink();
                return ListTile(
                  title: Text(user),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          currentUser: widget.currentUser,
                          receiver: user,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
