class UserModel {
  String? uid;
  String? fullname;
  String? email;
  String? profilePic;

  // Constructor
  UserModel({
    this.uid,
    this.fullname,
    this.email,
    this.profilePic,
  });

  // Method toMap, fromMap
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullname': fullname,
      'email': email,
      'profilePic': profilePic,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      fullname: map['fullname'] as String,
      email: map['email'] as String,
      profilePic: map['profilePic'] as String,
    );
  }

  @override
  String toString() {
    return 'UserModel{uid: $uid, fullname: $fullname, email: $email, profilePic: $profilePic}';
  }
}
