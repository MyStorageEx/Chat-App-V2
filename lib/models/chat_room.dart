import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastMessage;
  List<dynamic>? users;
  DateTime? createdon;

  // Constructor
  ChatRoomModel({
    this.chatroomid,
    this.participants,
    this.lastMessage,
    this.users,
    this.createdon,
  });

  // Method toMap, fromMap
  Map<String, dynamic> toMap() {
    return {
      'chatroomid': chatroomid,
      'participants': participants,
      'lastmessage': lastMessage,
      'users': users,
      'createdon': createdon,
    };
  }

  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      chatroomid: map['chatroomid'] as String,
      participants: map['participants'] as Map<String, dynamic>,
      lastMessage: map['lastmessage'] as String,
      users: map['users'] as List<dynamic>,
      createdon: (map['createdon'] as Timestamp).toDate(),
    );
  }
}
