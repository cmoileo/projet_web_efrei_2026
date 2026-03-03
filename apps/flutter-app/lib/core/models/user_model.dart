import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student,
  volunteer;

  static UserRole fromString(String value) {
    return switch (value) {
      'student' => UserRole.student,
      'volunteer' => UserRole.volunteer,
      _ => UserRole.student,
    };
  }

  String get value => switch (this) {
        UserRole.student => 'student',
        UserRole.volunteer => 'volunteer',
      };
}

class UserModel {
  const UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.nickname,
    required this.email,
    required this.birthdate,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  final String uid;
  final String firstName;
  final String lastName;
  final String nickname;
  final String email;
  final DateTime birthdate;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      firstName: data['first_name'] as String,
      lastName: data['last_name'] as String,
      nickname: data['nickname'] as String,
      email: data['email'] as String,
      birthdate: (data['birthdate'] as Timestamp).toDate(),
      role: UserRole.fromString(data['role'] as String),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'first_name': firstName,
        'last_name': lastName,
        'nickname': nickname,
        'email': email,
        'birthdate': Timestamp.fromDate(birthdate),
        'role': role.value,
        'created_at': Timestamp.fromDate(createdAt),
        'updated_at': Timestamp.fromDate(updatedAt),
      };

  UserModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? nickname,
    String? email,
    DateTime? birthdate,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      birthdate: birthdate ?? this.birthdate,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
