import 'package:chat_app_v2/constant/color.dart';
import 'package:chat_app_v2/constant/name.dart';
import 'package:chat_app_v2/models/user.dart';
import 'package:chat_app_v2/pages/auth/complete_profile_page.dart';
import 'package:chat_app_v2/services/ui_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailInputController = TextEditingController();
  final _passwordInputController = TextEditingController();
  final _confirmPasswordInputController = TextEditingController();

  final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$');

  bool _isNotShowPwd = true;
  bool _isNotShowRePwd = true;

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
                    color: CustomColor.mainColor,
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
                const SizedBox(height: 15),
                TextField(
                  controller: _confirmPasswordInputController,
                  obscureText: _isNotShowRePwd,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isNotShowRePwd = !_isNotShowRePwd;
                        });
                      },
                      icon: _isNotShowRePwd
                          ? const Icon(Icons.visibility_off)
                          : const Icon(Icons.remove_red_eye),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                CupertinoButton(
                  onPressed: () => _handleSignUp(
                    _emailInputController.text.trim(),
                    _passwordInputController.text.trim(),
                    _confirmPasswordInputController.text.trim(),
                  ),
                  color: Theme.of(context).colorScheme.primary,
                  child: const Text(
                    'Sign Up',
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
              "Already have an account?",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            CupertinoButton(
              onPressed: () => _moveBackLogInPage(),
              child: const Text(
                'Log In',
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

  void _moveBackLogInPage() {
    // Di chuyển tới trang đăng ký (Di chuyển ngược lại để tránh chồng chất màn hình với nhau)
    Navigator.pop(context);
  }

  void _moveToCompleteProfilePage({
    required UserModel userModel,
    required User firebaseUser,
  }) {
    // Di chuyển đến trang hoàn thành thông tin cá nhân
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompleteProfilePage(
          userModel: userModel,
          firebaseUser: firebaseUser,
        ),
      ),
    );
  }

  bool _validateValueInput(String email, String password, String rePassword) {
    bool isValidate = true;

    // Kiểm tra xem các trường có được nhập đầy đủ hay không
    if (email.isEmpty || password.isEmpty || rePassword.isEmpty) {
      UIHelper.showSnackBarNotify(
        context,
        'Please fill all the fields!',
        CustomColor.errColor,
      );
      return isValidate = false;
    }

    // Kiểm tra xem email có hợp lệ hay không
    if (!emailRegex.hasMatch(email)) {
      UIHelper.showSnackBarNotify(
        context,
        'Invalid email!\nPlease enter correctly!',
        CustomColor.errColor,
      );
      return isValidate = false;
    }

    // Kiểm tra nhập password có giống repassword không
    if (password != rePassword) {
      UIHelper.showSnackBarNotify(
        context,
        'Password and re-enter password do not match\nPlease enter correctly!',
        CustomColor.errColor,
      );
      return isValidate = false;
    }

    // Kiểm tra nhập password và repassword có đủ số lượng ký tự không
    if (password.length < 6 || rePassword.length < 6) {
      UIHelper.showSnackBarNotify(
        context,
        'Password length must be greater than 6',
        CustomColor.errColor,
      );
      return isValidate = false;
    }

    return isValidate;
  }

  void _handleSignUp(String email, String password, String rePassword) async {
    if (_validateValueInput(email, password, rePassword)) {
      // Hiển thị loading indicator
      UIHelper.showLoadingDialog(context);

      // Thực hiện đăng ký
      try {
        // Đăng ký người dùng với email và password
        UserCredential? credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Khởi tạo đối tượng user
        UserModel newUser = UserModel(
          uid: credential.user!.uid,
          email: credential.user!.email,
          fullname: "",
          profilePic: "",
        );

        // Lưu đối tượng vào trong FireStore
        print("New user Create");
        await FirebaseFirestore.instance
            .collection("users")
            .doc(credential.user!.uid)
            .set(newUser.toMap())
            .then(
          (value) {
            // ============================================= //
            // Xoá các trường hiện tại
            _emailInputController.clear();
            _passwordInputController.clear();
            _confirmPasswordInputController.clear();

            // Thoát khỏi hiệu ứng chờ sau khi đăng ký thành công
            UIHelper.exitLoadingDialog(context);

            // Di chuyển sang trang tiếp theo
            _moveToCompleteProfilePage(
              userModel: newUser,
              firebaseUser: credential.user!,
            );

            // Hiển thị thông báo
            UIHelper.showSnackBarNotify(
              context,
              'Sign Up Success!\nPlease continue to provide your additional information!',
              Theme.of(context).colorScheme.primary,
            );
          },
        );
        // ============================================== //
      } on FirebaseAuthException catch (ex) {
        // Thoát khỏi hiệu ứng chờ sau khi đăng ký thất bại
        Navigator.of(context).pop();

        // Nếu có lỗi thì thông báo tại tài khoảng thất bại
        UIHelper.showSnackBarNotify(
          context,
          'ErrorCode: ${ex.code.toString()}\nUser already exists',
          CustomColor.errColor,
        );
      }
    }
  }
}
