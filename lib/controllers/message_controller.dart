import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:road_map_v2/model/message_model.dart';

class MessageController {
  final CollectionReference _messageCollection =
      FirebaseFirestore.instance.collection('messages');

  Future<void> sendMessage({
    required String text,
    required String sender,
    required String recipient,
  }) async {
    try {
      await _messageCollection.add({
        'text': text,
        'sender': sender,
        'recipient': recipient,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw e;
    }
  }

  Stream<List<MessageModel>> getMessagesForRecipient(String recipientEmail) {
    return _messageCollection
        .where('recipient', isEqualTo: recipientEmail)
        // .orderBy('timestamp', descending: true) // Order by timestamp
        .snapshots()
        .map((snapshot) {
      final List<MessageModel> messages = [];
      snapshot.docs.forEach((doc) {
        final data = doc.data() as Map<String, dynamic>;
        messages.add(MessageModel.fromMap({
          ...data,
          'id': doc.id,
        }));
      });
      return messages;
    });
  }
}
