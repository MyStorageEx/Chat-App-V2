import 'package:chat_app_v2/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {
  static Future<UserModel?> getUserModelById(String uid) async {
    UserModel? user;
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (documentSnapshot.data() != null) {
      user = UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    }

    return user;
  }
}
