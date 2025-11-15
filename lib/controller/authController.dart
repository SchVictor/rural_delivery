import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:rural_delivery/models/userModel.dart';
import 'package:rural_delivery/screens/homeScreen.dart';
import 'package:rural_delivery/screens/loginScreen.dart';
import 'package:rural_delivery/services/authService.dart';
import 'package:rural_delivery/repositores/userRepository.dart';
import 'package:rural_delivery/services/sessionService.dart';

class AuthController extends GetxController {
  final AuthService _auth = AuthService();
  final UserRepository _repo = UserRepository(); //instancias dos serviços e repositórios
  final SessionService _session = SessionService();

  //Estado UI
  final isLoading = false.obs;
  final errorMessage = RxnString();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

final Rxn<UserModel> current = Rxn<UserModel>();


  @override
  void onInit() {
    super.onInit(); // chama o método onInit da superclasse GetxController

    _auth.userChanges.listen(
      (u) async {},
    ); //ouve mudanças no estado de autenticação do usuário
  }

  //-------------------Métodos de autenticação, Login e Cadastro--------------------//

  Future<void> loginEmail(String email, String password) async {
    await _run(() async {
      final u = await _auth.signInWithEmail(email, password);
      await _afterFirebaseLogin(u, loginProviderIsGoogle: false);
    });
  }

  Future<void> registerEmail(String email, String password, String name) async {
    await _run(() async {
      final u = await _auth.registerWithEmail(email, password);
      await _afterFirebaseLogin(u, loginProviderIsGoogle: false, newUserDefaultRole: UserRole.user, name: name);
    });
  }
  Future<void> loginGoogle() async {
    await _run(() async {
      final u = await _auth.signInWithGoogle();
      await _afterFirebaseLogin(u, loginProviderIsGoogle: true);
    });
  }

  Future<void> logout() async {
    await _run(() async {
      await _auth.signOut();
      await _session.clear();
      current.value = null;
      Get.offAll(() => const LoginScreen());
    }, showErrors: false);
  }

  // ---------- SESSÃO ----------
  Future<bool> tryRestoreSession() async {
    final s = await _session.load();
    if (s == null) return false;
    current.value = s;
    return true;
  }

  // ---------- PERMISSÕES ----------
  bool get canAccessAdminArea =>
      current.value?.role == UserRole.admin || current.value?.role == UserRole.admin;
  bool get isStudent => current.value?.role == UserRole.user;

  //get loginGoogle => null;

  // ---------- PRIVATE ----------
  Future<void> _afterFirebaseLogin(
    User? fbUser, {
    required bool loginProviderIsGoogle,
    UserRole newUserDefaultRole = UserRole.user,
    String? name,
  }) async {
    if (fbUser == null) {
      throw Exception('Falha ao autenticar. Tente novamente.');
    }

    // 1) Tentamos obter do Firestore
    var remote = await _repo.getFromFirestore(fbUser.uid);

    // 2) Se não existir no Firestore, criamos um registro com defaults
    if (remote == null) {
      remote = UserModel(
        firebaseUid: fbUser.uid,
        name: fbUser.displayName ?? (fbUser.email ?? 'Usuário'),
        email: fbUser.email ?? 'sem-email@local',
        avatarUrl: fbUser.photoURL,
        isGoogleUser: loginProviderIsGoogle,
        role: newUserDefaultRole,   // por padrão aluno; professor/admin você pode ajustar manualmente no Firestore
        classId: null,
      );
      await _repo.upsertFirestore(remote);
    }

    // 3) Consolida (Firestore → Local) e garante persistência bidirecional
    final local = await _repo.syncUser(remote);

    // 4) Salva na sessão
    await _session.save(local);
    current.value = local;

    // 5) Redireciona pela permissão (se quiser telas distintas por perfil, ajuste aqui)
    Get.offAll(() => const HomeScreen());
  }

  Future<void> _run(Future<void> Function() body, {bool showErrors = true}) async {
    try {
      errorMessage.value = null;
      isLoading.value = true;
      await body();
    } on FirebaseAuthException catch (e) {
      if (showErrors) errorMessage.value = _mapFirebaseError(e);
    } on Exception catch (e) {
      if (showErrors) errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'Usuário não encontrado.';
      case 'wrong-password': return 'Senha incorreta.';
      case 'invalid-credential': return 'Credenciais inválidas.';
      case 'email-already-in-use': return 'E-mail já em uso.';
      case 'weak-password': return 'Senha muito fraca.';
      case 'invalid-email': return 'E-mail inválido.';
      default: return 'Erro de autenticação: ${e.message ?? e.code}';
    }
  }
}
