enum UserRole { admin, user }

UserRole roleFromString(String? r) {
  switch (r) {
    case 'admin':
      return UserRole.admin;
    case 'user':
      return UserRole.user;
    default:
      return UserRole.user;
  }
}

String roleToString(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'admin';
    case UserRole.user:
      return 'user';
  }
}

class UserModel {
  final int? id;
  final String firebaseUid;
  final String email;
  final String name;
  final String? avatarUrl;
  final bool isGoogleUser;
  final UserRole role;
  final String? classId;

  UserModel({
    this.id,
    required this.firebaseUid,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isGoogleUser = false,
    this.role = UserRole.user,
    this.classId,
  });

  //--------------------sqflite-----------------------//

  factory UserModel.fromMap(Map<String, dynamic> map) {//construtor de fábrica para criar uma instância de UserModel a partir de um mapa, como um documento do Firestore, mapa de dados.
    return UserModel(
      id: map['id'] as int?,
      firebaseUid: map['firebaseUid'],
      name: map['name'],
      email: map['email'],
      avatarUrl: map['avatarUrl'],
      isGoogleUser: (map['isGoogleUser'] ?? 0) == 1,
      role: roleFromString(map['role']),
      classId: map['classId'],
    );
  }
 //fromMap significa que está criando um objeto a partir de um mapa (map) em sqflite, toMap significa que está convertendo o objeto em um mapa para armazenar no banco de dados.
  Map<String, dynamic> toMap() { 
    return {
      'id': id,
      'firebaseUid': firebaseUid,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'isGoogleUser': isGoogleUser ? 1 : 0,
      'role': roleToString(role),
      'classId': classId,};
  }
//---------------------------------------------//

//------------------Firestore--------------------//
  factory UserModel.fromFirestore(String uid, Map<String, dynamic> map) {//construtor de fábrica para criar uma instância de UserModel a partir de um mapa, como um documento do Firestore, mapa de dados.
    return UserModel(
      firebaseUid: uid, //change that made the redirection work
      name: map['name'],
      email: map['email'],
      avatarUrl: map['avatarUrl'],
      isGoogleUser: map['isGoogleUser'] ?? false,
      role: roleFromString(map['role']),
      classId: map['classId'],
    );
  }

  Map<String, dynamic> toFirestore() { 
    return {
      'firebaseUid': firebaseUid,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'isGoogleUser': isGoogleUser,
      'role': roleToString(role),
      'classId': classId,};
  }
//---------------------------------------------//

//------------------CopyWith--------------------//
  UserModel copyWith({ //copyWith é um método que cria uma cópia do objeto atual 
    int? id,
    String? firebaseUid,
    String? email,
    String? name,
    String? avatarUrl,
    bool? isGoogleUser,
    UserRole? role,
    String? classId,
  }) {
    return UserModel(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGoogleUser: isGoogleUser ?? this.isGoogleUser,
      role: role ?? this.role,
      classId: classId ?? this.classId,
    );
  }
}
