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
  // --- DEPENDÊNCIAS ---
  final AuthService _auth = AuthService(); // Serviço para o Firebase Auth (login, etc.)
  final UserRepository _repo = UserRepository(); // Repositório para o banco de dados (Firestore, SQLite)
  final SessionService _session = SessionService(); // Serviço para a sessão local (SharedPreferences)

  // --- ESTADO DA UI (Interface do Usuário) ---
  final isLoading = false.obs; // Estado de carregamento reativo para a UI (ex: spinners)
  final errorMessage = RxnString(); // Mensagem de erro reativa para a UI
  final emailController = TextEditingController(); // Controlador do campo de e-mail
  final passwordController = TextEditingController(); // Controlador do campo de senha

  // --- ESTADO CENTRAL DO USUÁRIO ---
  // O usuário logado no momento. 'Rxn<UserModel>' significa "Reativo e Nulo".
  // A UI (como a HomeScreen) "ouve" esta variável para mostrar o nome.
  final Rxn<UserModel> current = Rxn<UserModel>();

  /// Chamado automaticamente pelo GetX quando o controlador é criado (no main.dart).
  @override
  void onInit() {
    super.onInit(); // chama o método onInit da superclasse GetxController

    // Ouve mudanças GLOBAIS no estado de auth (ex: token expirar)
    _auth.userChanges.listen(
      (u) async {
        // TODO: Lógica de logout forçado se u == null
      },
    ); //ouve mudanças no estado de autenticação do usuário
  }

  //-------------------Métodos de autenticação, Login e Cadastro--------------------//

  /// Tenta fazer login com E-mail e Senha.
  Future<void> loginEmail(String email, String password) async {
    await _run(() async {
      // 1. Autentica no Firebase
      final u = await _auth.signInWithEmail(email, password);
      // 2. Sincroniza dados, salva sessão e navega
      await _afterFirebaseLogin(u, loginProviderIsGoogle: false);
    });
  }

  /// Tenta registrar um novo usuário com E-mail, Senha e Nome.
  Future<void> registerEmail(String email, String password, String name) async {
    await _run(() async {
      // 1. Cria o usuário no Firebase Auth
      final u = await _auth.registerWithEmail(email, password);
      // 2. Cria o registro no banco, sincroniza e navega
      await _afterFirebaseLogin(u,
          loginProviderIsGoogle: false,
          newUserDefaultRole: UserRole.user,
          name: name); // Passa o nome do formulário
    });
  }

  /// Tenta fazer login com a conta do Google.
  Future<void> loginGoogle() async {
    await _run(() async {
      // 1. Autentica no Google/Firebase
      final u = await _auth.signInWithGoogle();
      // 2. Sincroniza dados, salva sessão e navega
      await _afterFirebaseLogin(u, loginProviderIsGoogle: true);
    });
  }

  /// Desloga o usuário do app.
  Future<void> logout() async {
    await _run(() async {
      await _auth.signOut(); // 1. Desloga do Firebase
      await _session.clear(); // 2. Limpa a sessão local (SharedPreferences)
      current.value = null; // 3. Zera o usuário na memória
      Get.offAll(() => const LoginScreen()); // 4. Navega para o Login
    }, showErrors: false); // Não mostra erros ao deslogar
  }

  // ---------- SESSÃO (Offline-First) ----------
  /// Tenta carregar o usuário da sessão local (SharedPreferences) na inicialização do app.
  Future<bool> tryRestoreSession() async {
    final s = await _session.load(); // Tenta carregar o UserModel salvo
    if (s == null) return false; // Se não houver sessão, falha.
    current.value = s; // Se houver, define como usuário atual.
    return true;
  }

  // ---------- PERMISSÕES (Getters) ----------
  // Getters são "variáveis calculadas" que a UI pode usar.

  /// Verifica se o usuário logado é Admin.
  bool get canAccessAdminArea =>
      current.value?.role == UserRole.admin; // FIXME: Verificação duplicada

  /// Verifica se o usuário logado é um "user" (cliente).
  bool get isStudent => current.value?.role == UserRole.user;

  //get loginGoogle => null; // Artefato de código, pode ser removido.

  // ---------- PRIVATE (Lógica Interna) ----------

  /// Função "Mestra" chamada após qualquer login bem-sucedido (Email, Google, etc.).
  /// Responsável por sincronizar o usuário com o Firestore e o banco local (SQLite).
  Future<void> _afterFirebaseLogin(
    User? fbUser, { // O objeto User do Firebase Auth
    required bool loginProviderIsGoogle,
    UserRole newUserDefaultRole = UserRole.user,
    String? name, // O nome vindo do formulário de registro
  }) async {
    if (fbUser == null) {
      // Guarda de segurança
      throw Exception('Falha ao autenticar. Tente novamente.');
    }

    // 1) Tentamos obter do Firestore
    var remote = await _repo.getFromFirestore(fbUser.uid);

    // 2) Se não existir no Firestore, criamos um registro com defaults
    if (remote == null) {
      // Define o nome final (prioriza o nome do formulário, depois Google, depois email)
      final String finalName =
          name ?? fbUser.displayName ?? (fbUser.email ?? 'Usuário');

      remote = UserModel(
        firebaseUid: fbUser.uid,
        name: finalName, // Usa o nome final
        email: fbUser.email ?? 'sem-email@local',
        avatarUrl: fbUser.photoURL,
        isGoogleUser: loginProviderIsGoogle,
        role: newUserDefaultRole,
        classId: null,
      );
      // Salva este novo usuário no banco de dados da nuvem (Firestore)
      await _repo.upsertFirestore(remote);
    }

    // 3) Consolida (Firestore → Local) e garante persistência bidirecional
    // Sincroniza os dados do Firestore (remote) com o banco de dados local (SQLite).
    final local = await _repo.syncUser(remote);

    // 4) Salva na sessão
    await _session.save(local); // Salva no SharedPreferences
    current.value = local; // Define o usuário logado na memória

    // 5) Redireciona
    // Navega para Home e apaga a tela de Login do histórico
    Get.offAll(() => const HomeScreen());
  }

  /// "Wrapper" de função para automatizar o 'isLoading' e o 'try/catch' de erros.
  Future<void> _run(Future<void> Function() body,
      {bool showErrors = true}) async {
    try {
      errorMessage.value = null; // Limpa erros antigos
      isLoading.value = true; // Ativa o spinner
      await body(); // Executa a função principal (ex: loginEmail)
    } on FirebaseAuthException catch (e) {
      // Pega erros específicos do Firebase
      if (showErrors) errorMessage.value = _mapFirebaseError(e);
    } on Exception catch (e) {
      // Pega erros genéricos (ex: "Falha ao autenticar")
      if (showErrors) errorMessage.value = e.toString();
    } finally {
      // Executa sempre (dando certo ou errado)
      isLoading.value = false; // Desativa o spinner
    }
  }

  /// Traduz os códigos de erro do Firebase para mensagens amigáveis em Português.
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-credential':
        return 'Credenciais inválidas.';
      case 'email-already-in-use':
        return 'E-mail já em uso.';
      case 'weak-password':
        return 'Senha muito fraca.';
      case 'invalid-email':
        return 'E-mail inválido.';
      default:
        return 'Erro de autenticação: ${e.message ?? e.code}';
    }
  }
}