import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String text;
  final String sender;
  final String recipient;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.recipient,
    required this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'],
      text: map['text'],
      sender: map['sender'],
      recipient: map['recipient'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'sender': sender,
      'recipient': recipient,
      'timestamp': timestamp,
    };
  }
}
