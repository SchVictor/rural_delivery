import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; //instância do FirebaseAuth para autenticação
  final GoogleAuthProvider _google = GoogleAuthProvider(); //instância do GoogleAuthProvider para autenticação com Google

  Stream<User?> get userChanges => _auth.authStateChanges(); //stream para monitorar mudanças no estado do usuário
  

  Future<User?> signInWithGoogle() async {
    try { 
      if(kIsWeb){
        final googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        final cred = await _auth.signInWithPopup(googleProvider);
        return cred.user;
      }else{

      }
      
    } catch (e) {
      debugPrint('Erro no login com Google: $e');
      return null;
    }
  }

    

  Future<User?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<User?> registerWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    //try { await _google.signOut(); } catch (_) {}
  }
}