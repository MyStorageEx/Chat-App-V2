// Trong trường hợp người dùng chưa đăng nhập vào App
import 'package:chat_app_v2/constant/color.dart';
import 'package:chat_app_v2/models/user.dart';
import 'package:chat_app_v2/pages/auth/login_page.dart';
import 'package:chat_app_v2/pages/chat/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//  Trong trường hợp người dùng chưa đăng nhập vào App
class startAppWithoutLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData().copyWith(
        colorScheme: ThemeData().colorScheme.copyWith(
              primary: CustomColor.mainColor,
            ),
      ),
      home: const LoginPage(),
    );
  }
}

//  Trong trường hợp người dùng đã đăng nhập vào App
class startAppWithLogin extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const startAppWithLogin({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData().copyWith(
        colorScheme: ThemeData().colorScheme.copyWith(
              primary: CustomColor.mainColor,
            ),
      ),
      home: HomePage(
        userModel: userModel,
        firebaseUser: firebaseUser,
      ),
    );
  }
}
