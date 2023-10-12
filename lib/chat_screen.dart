import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController messageController;
  late List<String> _chatMessages;

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
    _chatMessages = [];
    _loadChatMessages();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> _loadChatMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _chatMessages = prefs.getStringList('chat_messages') ?? [];
    });
  }

  Future<void> _saveMessage(String message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    String timestamp = "${now.hour}:${now.minute}";
    String messageWithTimestamp = "$timestamp: $message";

    setState(() {
      _chatMessages.add(messageWithTimestamp);
    });

    prefs.setStringList('chat_messages', _chatMessages);
  }

  void _deleteMessage(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _chatMessages.removeAt(index);
    });

    prefs.setStringList('chat_messages', _chatMessages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App'),
      ),
      body: Column(
        children:[
          Expanded(
            child: ListView.builder(
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                List<String> parts = _chatMessages[index].split(': ');
                String timestamp = parts[0];
                String message = parts[1];
                DateTime dateTime = DateTime.parse("2000-01-01 $timestamp:00");

                String formattedTime = timeago.format(dateTime);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Card(
                        color: Colors.deepPurple,
                        shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                message,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              subtitle: Text(
                                formattedTime,
                                style: const TextStyle(color: Colors.white54),
                              ),
                              trailing: PopupMenuButton(
                                color: Colors.white54,
                                iconSize: 18,
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onTap: () {
                                      _deleteMessage(index);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    minLines: 1,
                    maxLines: 3,
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.purple,
                  ),
                  onPressed: () async {
                    String message = messageController.text;
                    if (message.isNotEmpty) {
                      await _saveMessage(message);
                      messageController.clear();
                      _loadChatMessages();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
