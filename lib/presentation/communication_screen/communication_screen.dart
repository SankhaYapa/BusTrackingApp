import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:road_map_v2/controllers/message_controller.dart';
import 'package:road_map_v2/model/message_model.dart';

class CommunicationScreen extends StatefulWidget {
  const CommunicationScreen({Key? key}) : super(key: key);

  @override
  State<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String schoolBusEmail = 'schoolbus@gmail.com';
  final MessageController _messageController2 = MessageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Communication'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream:
                  _messageController2.getMessagesForRecipient(schoolBusEmail),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No messages'));
                }
                snapshot.data!
                    .sort((a, b) => b.timestamp.compareTo(a.timestamp));
                return ListView.builder(
                  reverse: true, // Reverse the order of items
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final message = snapshot.data![index];
                    final isMe = message.sender == _auth.currentUser!.email;
                    return Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.sender,
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          Material(
                            borderRadius: BorderRadius.only(
                              topLeft: isMe
                                  ? Radius.circular(30)
                                  : Radius.circular(0),
                              topRight: isMe
                                  ? Radius.circular(0)
                                  : Radius.circular(30),
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            elevation: 5,
                            color: isMe ? Colors.lightBlueAccent : Colors.white,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              child: Column(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message.text,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: isMe
                                              ? Colors.white
                                              : Colors.black54,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                    ],
                                  ),
                                  // Text(
                                  //   DateFormat('MMM d, yyyy - HH:mm')
                                  //       .format(message.timestamp),
                                  //   style: TextStyle(
                                  //     fontSize: 12,
                                  //     color: isMe
                                  //         ? Colors.white70
                                  //         : Colors.black45,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message here...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    final currentUser = _auth.currentUser;
                    if (currentUser != null &&
                        _messageController.text.trim().isNotEmpty) {
                      await _messageController2.sendMessage(
                        text: _messageController.text,
                        sender: currentUser.email!,
                        recipient: schoolBusEmail,
                      );
                      _messageController.clear();
                    } else {
                      // Show a snackbar or alert dialog to indicate that the message is empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter a message'),
                        ),
                      );
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
