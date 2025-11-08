
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rural_delivery/database/databaseHelper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:rural_delivery/models/userModel.dart';

class UserRepository {
  final _col = FirebaseFirestore.instance.collection('users');
  Future<Database> get _db async => DatabaseHelper.instance.database;

  // ---------- FIRESTORE ----------
  Future<void> upsertFirestore(UserModel u) async {
    await _col
        .doc(u.firebaseUid)
        .set(
          u.toFirestore(),
          SetOptions(merge: true),
        ); //o merge está setando o usuário logado e o que está no firebase
  }

  Future<UserModel?> getFromFirestore(String uid) async {
    //usermodel pega do firestore, requerendo obrigatóriamente o uid
    final snap = await _col.doc(uid).get();
    if (!snap.exists || snap.data() == null)
      return null; //o documento é o resultado da busca no firebase, se true, retorna as infromações do userModel
    return UserModel.fromFirestore(
      uid,
      snap.data()!,
    ); //acessando o userModel dá pra entender
  }

  // ---------- SQLITE ---------- //
  Future<UserModel?> findByFirebaseUid(String uid) async {
    //future quer dizer que o futuro é o retorno, o caso dessa, o retorno será do tipo UserModel
    if (kIsWeb)
      return null; //sqlite não funciona na web  //porque ela existe: porque o sqlite não funciona na web,e a função é pra buscar no Firebase, sem internet não executa
    final db = await _db;
    final res = await db.query(
      'users',
      where: 'firebaseUid = ?',
      whereArgs: [uid],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return UserModel.fromMap(
      res.first,
    ); // fromMap é um construtor do UserModel que cria uma instância a partir de um mapa (mapa de dados vindo do sqlite)
  }

  Future<void> upsertLocal(UserModel user) async {
    if (kIsWeb) return; //sqlite não funciona na web
    try {
      final db = await _db;
      final existing = await db.query(
        'users',
        where: 'firebaseUid = ?',
        whereArgs: [user.firebaseUid],
        limit: 1,
      );

      if (existing.isEmpty) {
        // insert
        await db.insert('users', user.toMap());
      } else {
        // update
        await db.update(
          'users',
          user.toMap(),
          where: 'id = ?',
          whereArgs: [existing.first['id']],
        );
      }
    } catch (e) {
      debugPrint('Erro ao inserir/atualizar usuário local: $e');
    }
  }

  // ---------- SYNC ----------
  /// Garante o usuário em ambos os lados e retorna o modelo consolidado local.
  Future<UserModel> syncUser(UserModel base) async {
    // Prioridade: Firestore como fonte de verdade para perfil/role/classId
    final remote = await getFromFirestore(base.firebaseUid);
    final merged = (remote == null)
        ? base
        : base.copyWith(
            name: remote.name,
            email: remote.email,
            avatarUrl: remote.avatarUrl,
            isGoogleUser: remote.isGoogleUser,
            role: remote.role,
            classId: remote.classId,
          );

    await upsertFirestore(merged); // garante no remoto (merge)
    await upsertLocal(merged); // garante no local
    return merged;
  }
}