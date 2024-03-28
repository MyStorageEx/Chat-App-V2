import 'package:chat_app_v2/firebase_options.dart';
import 'package:chat_app_v2/pages/my_app.dart';
import 'package:chat_app_v2/services/firebase_helper.dart';
import 'package:chat_app_v2/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

void main() async {
  // Khởi động công cụ flutter và chuẩn bị cho việc hiển thị widget
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi động firebase trong dự án, thiết lập kết với máy chủ firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Lấy ra người dùng hiện tại đang đăng nhập
  // Nếu có thì trả về chính người dùng
  // Nếu không thì trả về null
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    // Logged In
    UserModel? userModel =
        await FirebaseHelper.getUserModelById(currentUser.uid);
    runApp(startAppWithLogin(
      userModel: userModel!,
      firebaseUser: currentUser,
    ));
  } else {
    // Log In
    runApp(startAppWithoutLogin());
  }
}
