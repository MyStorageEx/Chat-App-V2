import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;

  // Constructor
  MessageModel({
    this.messageid,
    this.sender,
    this.text,
    this.seen,
    this.createdon,
  });

  // Method toMap, fromMap
  Map<String, dynamic> toMap() {
    return {
      'messageid': messageid,
      'sender': sender,
      'text': text,
      'seen': seen,
      'createdon': createdon,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageid: map['messageid'] as String,
      sender: map['sender'] as String,
      text: map['text'] as String,
      seen: map['seen'] as bool,
      createdon: (map['createdon'] as Timestamp).toDate(),
    );
  }
}
