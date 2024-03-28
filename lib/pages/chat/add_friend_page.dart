import 'package:chat_app_v2/constant/color.dart';
import 'package:chat_app_v2/main.dart';
import 'package:chat_app_v2/models/chat_room.dart';
import 'package:chat_app_v2/models/user.dart';
import 'package:chat_app_v2/pages/chat/chat_room_page.dart';
import 'package:chat_app_v2/services/ui_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddFriendPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const AddFriendPage({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final _emailInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Color mainColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text(
          'Add Friend',
          style: TextStyle(
            color: Colors.white,
          ),
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 30),
              TextField(
                controller: _emailInputController,
                decoration: const InputDecoration(
                  labelText: "Email Address",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                color: mainColor,
                onPressed: () => _hanldeSearchBar(
                  _emailInputController.text.trim(),
                ),
                child: const Text('Add'),
              ),
              const SizedBox(height: 20),
              _resultofSearchBar()
            ],
          ),
        ),
      ),
    );
  }

  bool _validateValueInput(String email) {
    bool isValidate = true;

    // Kiểm tra xem các trường có được nhập đầy đủ hay không
    if (email.isEmpty) {
      UIHelper.showSnackBarNotify(
        context,
        'Please fill all the fields!',
        CustomColor.errColor,
      );
      return isValidate = false;
    }

    return isValidate;
  }

  void _hanldeSearchBar(String email) {
    if (_validateValueInput(email)) {
      setState(() {
        print('Search data!');
      });
    }
  }

  void _moveToChatRoom(UserModel searchedUser) async {
    ChatRoomModel? chatRoomModel = await getChatRoomModel(searchedUser);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomPage(
          targetUser: searchedUser,
          userModel: widget.userModel,
          firebaseUser: widget.firebaseUser,
          chatRoom: chatRoomModel!,
        ),
      ),
    );
  }

  Widget _resultofSearchBar() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: _emailInputController.text.trim())
          .where("email", isNotEqualTo: widget.userModel.email)
          .snapshots(),
      builder: (context, snapshot) {
        // Nếu trạng thái kết nối hiện tại là hoạt động
        if (snapshot.connectionState == ConnectionState.active) {
          // Hoạt động khi trong snapshot có dữ liệu
          if (snapshot.hasData) {
            var dataSnapshot = snapshot.data as QuerySnapshot;

            // List key-value mà snapshot không phải là rỗng thì mới in ra dạng list
            if (dataSnapshot.docs.isNotEmpty) {
              // Lây thông tin từ snapshot và gán lại cho đối tượng user
              Map<String, dynamic> userMap =
                  dataSnapshot.docs[0].data() as Map<String, dynamic>;

              // Gán cho đối tượng user
              UserModel? searchedUser = UserModel.fromMap(userMap);

              return InkWell(
                onTap: () => _moveToChatRoom(searchedUser),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      searchedUser.profilePic.toString(),
                    ),
                    backgroundColor: Colors.grey[500],
                  ),
                  title: Text(searchedUser.fullname.toString()),
                  subtitle: Text(searchedUser.email.toString()),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                ),
              );
            } else {
              return const Text("No result found!");
            }
          } else if (snapshot.hasError) {
            return const Text("An error orcured!");
          } else {
            return const Text("No result found!");
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  // Hàm lấy đối tượng chatroom từ firestore
  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    // Query lên firebase để nhận được snapshot dựa vào điều kiện 1 .Người hiện tại đang đăng nhập vào app 2. Người được chọn để nhắn tin
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    // Kiểm tra snapshot vừa được query và chia ra từng trường hợp để xử lí
    if (snapshot.docs.isNotEmpty) {
      // Lấy đối tượng chatroom vừa nhận được
      var docData = snapshot.docs[0].data();
      chatRoom = ChatRoomModel.fromMap(docData as Map<String, dynamic>);
    } else {
      // Khởi tạo đối tượng chatroom
      ChatRoomModel newChatRoom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
        users: [
          widget.userModel.uid.toString(),
          targetUser.uid.toString(),
        ],
        createdon: DateTime.now(),
      );

      // Tạo mới một chatroom lên firebase
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatRoom.chatroomid)
          .set(newChatRoom.toMap());

      chatRoom = newChatRoom;

      print("New Chatroom is create!");
    }

    return chatRoom;
  }
}
