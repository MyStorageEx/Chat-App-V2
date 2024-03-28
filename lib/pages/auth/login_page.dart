import 'package:chat_app_v2/constant/color.dart';
import 'package:chat_app_v2/constant/name.dart';
import 'package:chat_app_v2/models/user.dart';
import 'package:chat_app_v2/pages/chat/home_page.dart';
import 'package:chat_app_v2/pages/auth/signup_page.dart';
import 'package:chat_app_v2/services/ui_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailInputController = TextEditingController();
  final _passwordInputController = TextEditingController();
  final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$');

  bool _isNotShowPwd = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  ApplicationName.mainName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _emailInputController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email Address",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordInputController,
                  obscureText: _isNotShowPwd,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isNotShowPwd = !_isNotShowPwd;
                        });
                      },
                      icon: _isNotShowPwd
                          ? const Icon(Icons.visibility_off)
                          : const Icon(Icons.remove_red_eye),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                CupertinoButton(
                  onPressed: () => _handleLogin(
                    _emailInputController.text.trim(),
                    _passwordInputController.text.trim(),
                  ),
                  color: Theme.of(context).colorScheme.primary,
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account?",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            CupertinoButton(
              onPressed: () => _moveToSignUpPage(),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _moveToSignUpPage() {
    // Di chuyển tới trang đăng ký
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignUpPage(),
      ),
    );
  }

  void _moveToHomePage({
    required UserModel userModel,
    required User firebaseUser,
  }) {
    // Di chuyển tới trang chính
    print("LogIn success");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          userModel: userModel,
          firebaseUser: firebaseUser,
        ),
      ),
    );
  }

  bool _validateValueInput(String email, String password) {
    bool isValidate = true;

    // Kiểm tra xem các trường có được nhập đầy đủ hay không
    if (email.isEmpty || password.isEmpty) {
      UIHelper.showSnackBarNotify(
        context,
        "Please fill all the fields!",
        CustomColor.errColor,
      );
      return isValidate = false;
    }

    // Kiểm tra xem email có hợp lệ hay không
    if (!emailRegex.hasMatch(email)) {
      UIHelper.showSnackBarNotify(
        context,
        "Invalid email!\nPlease enter correctly!",
        CustomColor.errColor,
      );
      return isValidate = false;
    }

    // Kiểm tra nhập password có đủ số lượng ký tự không
    if (password.length < 6) {
      UIHelper.showSnackBarNotify(
        context,
        "Password length must be greater than 6",
        CustomColor.errColor,
      );
      return isValidate = false;
    }

    return isValidate;
  }

  void _handleLogin(String email, String password) async {
    if (_validateValueInput(email, password)) {
      // Hiển thị loading indicator
      UIHelper.showLoadingDialog(context);

      // Thực hiện đăng nhập
      try {
        // Đăng nhập người dùng với email và password
        UserCredential? credential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Lấy người dùng từ FireStore về App
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .get();
        UserModel userModel =
            UserModel.fromMap(userData.data() as Map<String, dynamic>);

        // Thoát khỏi hiệu ứng chờ
        UIHelper.exitLoadingDialog(context);

        // Di chuyển tới homePage
        _moveToHomePage(userModel: userModel, firebaseUser: credential.user!);

        // Thông báo cho người dùng đăng nhập thành công
        UIHelper.showSnackBarNotify(
          context,
          "Login succes! Welcome to ${ApplicationName.mainName}",
          Theme.of(context).colorScheme.primary,
        );
        // ============================================== //
      } on FirebaseAuthException catch (ex) {
        // Thoát khỏi hiệu ứng chờ sau khi đăng nhập thất bại
        Navigator.of(context).pop();

        // Nếu có lỗi thì thông báo thất bại
        UIHelper.showSnackBarNotify(
          context,
          "ErrorCode: ${ex.code.toString()}\nWrong password or email, please try again!",
          CustomColor.errColor,
        );
      }
    }
  }
}
