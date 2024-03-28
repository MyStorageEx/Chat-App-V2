import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat_app_v2/main.dart';
import 'package:chat_app_v2/models/chat_room.dart';
import 'package:chat_app_v2/models/message.dart';
import 'package:chat_app_v2/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final UserModel userModel;
  final User firebaseUser;
  final ChatRoomModel chatRoom;

  const ChatRoomPage({
    super.key,
    required this.targetUser,
    required this.userModel,
    required this.firebaseUser,
    required this.chatRoom,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _msgInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _msgMaxWidth = MediaQuery.of(context).size.width / 1.2;
    Color mainColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  NetworkImage(widget.targetUser.profilePic.toString()),
            ),
            const SizedBox(width: 20),
            Text(
              '${widget.targetUser.fullname}',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // This is where the chat will go
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatrooms")
                      .doc(widget.chatRoom.chatroomid)
                      .collection("messages")
                      .orderBy("createdon", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        var dataSnapshot = snapshot.data as QuerySnapshot;

                        // in dữ liệu tin nhắn lên màn hình
                        return ListView.builder(
                          reverse: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            MessageModel currentMessage = MessageModel.fromMap(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>);

                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment:
                                  (currentMessage.sender == widget.userModel.uid
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start),
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 3,
                                    bottom: 3,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  constraints: BoxConstraints(
                                    maxWidth: _msgMaxWidth,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (currentMessage.sender ==
                                            widget.userModel.uid
                                        ? mainColor
                                        : Colors.grey[500]),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: AutoSizeText(
                                    currentMessage.text.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        // Trường hợp snapshot bị lỗi
                        return const Center(
                          child: Text(
                              "An error occured!\nPlease check your internet connection"),
                        );
                      } else {
                        // Trường hợp snapshot trống dữ liệu
                        return const Center(
                          child: Text("Say hi to your new friend"),
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: TextField(
                      onSubmitted: (text) => _handleSendMsg(),
                      controller: _msgInputController,
                      decoration: const InputDecoration(
                        hintText: "Enter message",
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _handleSendMsg(),
                    icon: Icon(
                      Icons.send,
                      color: mainColor,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _handleSendMsg() async {
    // Lấy dữ liệu từ field về
    String msg = _msgInputController.text.trim();

    // Thực hiện gửi tin nhắn
    if (msg.isNotEmpty) {
      // Xoá dữ liệu hiện tại trong field
      _msgInputController.clear();

      // Khởi tạo đối tượng message
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        createdon: DateTime.now(),
        text: msg,
        seen: false,
      );

      // Update dữ liệu lên firebase
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      // Lưu lại tinh nhắn cuối cùng
      widget.chatRoom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoom.chatroomid)
          .set(widget.chatRoom.toMap());

      print("Message sent!");
    }
  }
}
