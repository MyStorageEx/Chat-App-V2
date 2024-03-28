import 'dart:io';

import 'package:chat_app_v2/models/user.dart';
import 'package:chat_app_v2/pages/chat/home_page.dart';
import 'package:chat_app_v2/services/ui_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfilePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfilePage({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _fullnameInputController = TextEditingController();
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    Color mainColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: mainColor,
        automaticallyImplyLeading: false,
        title: const Text(
          'Complete Profile',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: ListView(
            children: [
              const SizedBox(height: 60),
              CupertinoButton(
                onPressed: () => _handleChangeAvatar(),
                padding: const EdgeInsets.all(0),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: mainColor,
                  backgroundImage:
                      imageFile != null ? FileImage(imageFile!) : null,
                  foregroundColor: Colors.white,
                  child: Icon(
                    imageFile == null ? Icons.person : null,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _fullnameInputController,
                decoration: const InputDecoration(
                  labelText: "Full name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              CupertinoButton(
                onPressed: () => _handleSubmitProfile(
                  _fullnameInputController.text.trim(),
                ),
                color: mainColor,
                child: const Text(
                  'Submit',
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
    );
  }

  void _moveToHomePage({
    required UserModel userModel,
    required User firebaseUser,
  }) {
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

  void _handleSubmitProfile(String fullname) async {
    if (_validateInput(fullname)) {
      print("Bắt đầu quá trình update dữ liệu");
      print("UserID: ${widget.userModel.uid}");

      // Hiển thị loading indicator
      UIHelper.showLoadingDialog(context);

      // Tiến trình upload ảnh lên Firestore
      UploadTask uploadTask = FirebaseStorage.instance
          .ref("profilepictures")
          .child(widget.userModel.uid.toString())
          .putFile(imageFile!);

      TaskSnapshot snapshot = await uploadTask;

      // Cập nhật lại tên đầy đủ và hình ảnh cho đối tượng
      widget.userModel.fullname = fullname;
      widget.userModel.profilePic = await snapshot.ref.getDownloadURL();

      // Cập nhật lại thông tin người dùng lên FireStore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userModel.uid)
          .set(widget.userModel.toMap())
          .then(
        (value) {
          // Thoát khỏi hiệu ứng chờ sau khi đăng ký thành công
          UIHelper.exitLoadingDialog(context);

          // Thông báo lên màn hình;
          UIHelper.showSnackBarNotify(
            context,
            "Information updated successfully!",
            Theme.of(context).colorScheme.primary,
          );

          // Di chuyển qua homePage
          _moveToHomePage(
            userModel: widget.userModel,
            firebaseUser: widget.firebaseUser,
          );
        },
      );
    }
  }

  void _handleChangeAvatar() {
    // Bấm vào ảnh thì hiển thị danh mục chọn hình ảnh
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Upload Profile Picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Select from Gallery'),
                leading: const Icon(Icons.photo_album),
                onTap: () {
                  Navigator.pop(context);
                  _selectImg(ImageSource.gallery);
                },
              ),
              ListTile(
                title: const Text('Take a photo'),
                leading: const Icon(Icons.camera_alt),
                onTap: () {
                  Navigator.pop(context);
                  _selectImg(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );

    //
  }

  void _selectImg(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      _cropImg(pickedFile);
    }
  }

  void _cropImg(XFile file) async {
    CroppedFile? croppedImg = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(
        ratioX: 1,
        ratioY: 1,
      ),
      compressQuality: 20,
    );

    if (croppedImg != null) {
      setState(() {
        imageFile = File(croppedImg.path);
      });
    }
  }

  bool _validateInput(String name) {
    bool check = true;

    // Kiểm tra xem trường có nhập đẩy đủ và người dùng đã chọn ảnh hay không
    if (name.isEmpty || imageFile == null) {
      // Nếu có lỗi thì thông báo thất bại
      UIHelper.showSnackBarNotify(
        context,
        "Please enter your full name and select avatar!",
        Colors.red,
      );
    }
    return check;
  }
}
