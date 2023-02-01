class UserModel {
  String? email;
  String? role;
  String? uid;
  String? name;
  String? imageUrl;
  bool?  isEmployee;
  bool? isSuperUser;
  bool? isApprover;
  bool? isActive;

// receiving data
  UserModel({this.uid, this.email, this.role, this.name,this.isEmployee,this.isSuperUser,this.isApprover,this.isActive});
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      role: map['role'],
      name: map['name'],
      isEmployee: map['isEmployee'],
      isSuperUser: map['isSuperUser'],
      isApprover: map['isApprover'],
        isActive: map['isActive']
    );
  }
// sending data
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
      'isEmployee': isEmployee,
      'isSuperUser': isSuperUser,
       'isApprover': isApprover,
      'isActive': isActive,
      'imageUrl': ""
    };
  }
}
