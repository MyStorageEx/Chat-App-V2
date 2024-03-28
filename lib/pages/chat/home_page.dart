import 'package:chat_app_v2/models/chat_room.dart';
import 'package:chat_app_v2/models/user.dart';
import 'package:chat_app_v2/pages/auth/login_page.dart';
import 'package:chat_app_v2/pages/chat/chat_room_page.dart';
import 'package:chat_app_v2/pages/chat/add_friend_page.dart';
import 'package:chat_app_v2/pages/chat/custom_profile_page.dart';
import 'package:chat_app_v2/services/firebase_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    Color mainColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: mainColor,
        title: const Text(
          'Chat App',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _handleLogout(),
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
          ),
        ],
        leading: Padding(
          padding: const EdgeInsets.all(6),
          child: InkWell(
            onTap: () => _moveToCustomProfilePage(
              userModel: widget.userModel,
              firebaseUser: widget.firebaseUser,
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                widget.userModel.profilePic.toString(),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chatrooms")
              .where("users", arrayContains: widget.userModel.uid)
              .orderBy("createdon")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                // Trường hợp người dùng đã có nhắn tin với người dùng khác
                var chatRoomSnapshot = snapshot.data as QuerySnapshot;

                // Trả về dao diện người dùng từ dữ liệu đã fetch được
                return ListView.builder(
                  itemCount: chatRoomSnapshot.docs.length,
                  itemBuilder: (context, index) {
                    ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                        chatRoomSnapshot.docs[index].data()
                            as Map<String, dynamic>);

                    // Lấy toàn bộ uid của những người đã nói chuyện với người đăng nhập
                    Map<String, dynamic> participants =
                        chatRoomModel.participants!;
                    List<String> participantKeys = participants.keys.toList();

                    // Lọc người người đăng nhập khỏi list => Ta có một list uid gồm những người đã nhắn tin với người đăng nhập
                    participantKeys.remove(widget.userModel.uid);

                    return FutureBuilder(
                      future: FirebaseHelper.getUserModelById(
                        participantKeys[0],
                      ),
                      builder: (context, userData) {
                        if (userData.connectionState == ConnectionState.done) {
                          UserModel targetUser = userData.data as UserModel;
                          return ListTile(
                            onTap: () =>
                                _moveToChatRoom(targetUser, chatRoomModel),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                targetUser.profilePic.toString(),
                              ),
                            ),
                            title: Text(
                              targetUser.fullname.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: chatRoomModel.lastMessage.toString() != ""
                                ? Text(
                                    chatRoomModel.lastMessage.toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Text(
                                    'Say hi to your new friend',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: mainColor,
                                    ),
                                  ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    );
                  },
                );
              } else if (snapshot.hasError) {
                // Trả về màn hình lỗi
                print(snapshot.error.toString());
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                // Trong trường hợp người dùng chưa có tin nhắn nào
                return const Center(
                  child: Text("No chats"),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _moveToAddFriendPage(),
        backgroundColor: mainColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Adjust radius for size
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _moveToAddFriendPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFriendPage(
          userModel: widget.userModel,
          firebaseUser: widget.firebaseUser,
        ),
      ),
    );
  }

  void _moveToChatRoom(UserModel targetUser, ChatRoomModel chatRoomModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomPage(
          targetUser: targetUser,
          userModel: widget.userModel,
          firebaseUser: widget.firebaseUser,
          chatRoom: chatRoomModel,
        ),
      ),
    );
  }

  void _moveToCustomProfilePage({
    required UserModel userModel,
    required User firebaseUser,
  }) {
    // Di chuyển đến trang hoàn thành thông tin cá nhân
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomProfilePage(
          userModel: userModel,
          firebaseUser: firebaseUser,
        ),
      ),
    );
  }

  void _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
}
