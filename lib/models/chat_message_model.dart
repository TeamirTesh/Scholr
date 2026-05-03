import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final String type;
  final String? fileUrl;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.type,
    this.fileUrl,
  });

  factory ChatMessageModel.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessageModel(
      id: id,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      text: map['text'] as String,
      timestamp: ((map['timestamp'] as Timestamp?)?.toDate()) ?? DateTime.now(),
      type: map['type'] as String,
      fileUrl: map['fileUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
      'fileUrl': fileUrl,
    };
  }
}
