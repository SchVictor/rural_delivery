import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:rural_delivery/controller/authController.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  }); // o que a linha"" faz? quero adicionar de comentário

  @override
  State<LoginScreen> createState() => _LoginScreenState(); // cria o estado do widget LoginScreen é o que permite que o widget tenha um estado mutável
}

class _LoginScreenState extends State<LoginScreen> {
  bool isSignUp = false; //variável que controla se o usuário...
  bool _obscure = true; //variável que controla se a senha está visível ou não

  final _formKey = GlobalKey<FormState>(); //chave global para o formulário de login
  final _nameCtrl = TextEditingController(); //controlador do campo de nome
  final _emailCtrl = TextEditingController(); //controlador do campo de email
  final _passwordCtrl = TextEditingController(); //controlador do campo de senha
  final AuthController _auth = Get.find<AuthController>(); //instancia a classe AuthController para usar os métodos de autenticação

  @override
  void dispose() {
    //método que limpa os controladores quando a tela é destruída, pois não é mais necessário, assim, liberando memória
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }
  //--------------------------------VALIDAÇÕES DOS CAMPOS--------------------------------//
  
  String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Informe o e-mail';
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value);
    if (!ok) return 'E-mail inválido';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = v ?? '';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  String? _validateName(String? v) {
    if (!isSignUp) return null;
    final value = v?.trim() ?? '';
    if (value.length < 2) return 'Informe seu nome';
    return null;
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    FocusScope.of(context).unfocus();


   
    if (isSignUp) {
      await _auth.registerEmail(_emailCtrl.text.trim(), _passwordCtrl.text.trim(), _nameCtrl.text.trim());
    } else {
      await _auth.loginEmail(_emailCtrl.text.trim(), _passwordCtrl.text.trim());
    }
  }


  @override //parte visual da tela de login
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width; //largura da tela, usada para responsividade

    const primaryGreen = Color(0xFF6B8E23); //cor verde primária do app
    const sunnyYellow = Color(0xFFFFD700); // Amarelo Dourado / Ensolarado
    const earthyBrown = Color(0xFF8B4513); // Marrom Terra
    const lightBackgroundGreen = Color(0xFFE0E6C8); // Verde claro, quase creme
    const offWhite = Color(0xFFFDFDFD); // Branco suave para o Card
    const textDark = Color(0xFF36454F); // Cinza carvão para texto principal
    const backgroundColor1 = Color(0xFFE0E6C8); // Fundo verde claro campestre


    return Scaffold(  
      backgroundColor: backgroundColor1, //cor de fundo da tela de login
      body: SafeArea ( //garante que o conteúdo não fique em áreas perigosas da tela, como entalhes ou barras de status
        child: Center(  //centraliza o conteúdo na tela
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20), //adiciona um padding de 20px em toda a tela 
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450, //limita a largura máxima da tela para 450px, para ficar melhor em telas grandes
              ),
              child: Card(//cria um card para o formulário de Login
                elevation: 8,//sombra do card
                margin: EdgeInsets.symmetric(horizontal: w < 450 ? 8 : 0),//se a largura da tela for menor que 450px, o margin horizontal será 8px, caso contrário, será 0px
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), //bordas arredondadas do card
                  side: BorderSide(
                    color:  Colors.grey.shade300, //cor da borda do card
                    width: 0.8, //largura da borda do card
                  ),
                ),

                color: offWhite, //cor de fundo do card
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 40
                  ),
                  child: Obx(
                    () => Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/countrylane.jpg', // <<< SUBSTITUA AQUI
                            height: 120, // Ajuste a altura como preferir
                          ),
                          const SizedBox(
                            height: 20,
                          ), // Espaço entre a imagem e o título
                          Text(
                            isSignUp
                                ? 'Crie sua conta'
                                : 'Entrar', // Novo texto temático
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900, // Ainda mais bold
                              color: primaryGreen, // Título em verde musgo
                              fontFamily:
                                  'Montserrat', // Exemplo de fonte mais robusta (precisa ser importada)
                            ),
                          ),

                          const SizedBox(height: 12),
                          Text(
                            isSignUp
                                ? 'Preencha seus dados'
                                : 'Acesse sua conta', // Subtítulo temático
                            style: TextStyle(
                              fontSize: 17,
                              color: textDark.withOpacity(0.8),
                              fontFamily:
                                  'Roboto', // Exemplo de fonte (precisa ser importada)
                            ),
                          ),
                          const SizedBox(height: 35),

                          // Bloco de exibição de erro 
                          if (_auth.errorMessage.value != null) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.red.shade700,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red.shade700,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      _auth.errorMessage.value!,
                                      style: TextStyle(
                                        color: Colors.red.shade800,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                          ],

                          // Campo de Nome (se for cadastro)
                          if (isSignUp) ...[
                            TextFormField(
                              controller: _nameCtrl,
                              decoration: InputDecoration(
                                labelText: 'Nome Completo',
                                hintText: 'Seu nome no campo',
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: earthyBrown.withOpacity(0.8),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: primaryGreen,
                                    width: 2,
                                  ),
                                ),
                                labelStyle: TextStyle(
                                  color: textDark.withOpacity(0.7),
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: _validateName,
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Campo de E-mail
                          TextFormField(
                            controller: _emailCtrl,
                            decoration: InputDecoration(
                              labelText: 'E-mail ', // Temático
                              hintText: 'seuemail@email.com', // Temático
                              prefixIcon: Icon(
                                Icons.mail_outline,
                                color: earthyBrown.withOpacity(0.8),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: primaryGreen,
                                  width: 2,
                                ),
                              ),
                              labelStyle: TextStyle(
                                color: textDark.withOpacity(0.7),
                              ),
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 20),

                          // Campo de Senha
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Senha Secreta', // Temático
                              hintText: 'Mínimo 6 caracteres de segurança',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: earthyBrown.withOpacity(0.8),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: textDark.withOpacity(0.6),
                                ),
                                tooltip: _obscure
                                    ? 'Revelar senha'
                                    : 'Ocultar senha',
                              ),
                               border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: primaryGreen,
                                  width: 2,
                                ),
                              ),
                              labelStyle: TextStyle(
                                color: textDark.withOpacity(0.7),
                              ),
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                            ),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 35),

                          // Botão principal de Ação (Login/Cadastro)
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _auth.isLoading.value ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    sunnyYellow, // Botão amarelo ensolarado
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 5,
                                foregroundColor:
                                    earthyBrown, // Texto em marrom terra
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                                shadowColor: sunnyYellow.withOpacity(
                                  0.4,
                                ), // Sombra amarela
                              ),
                              child: _auth.isLoading.value
                                  ? SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: earthyBrown,
                                      ), // Indicador marrom
                                    )
                                  : Text(
                                      isSignUp
                                          ? 'CRIAR CONTA'
                                          : 'ACESSAR CONTA',
                                    ), // Texto temático
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Botão de alternar entre Login/Cadastro
                          TextButton(
                            onPressed: _auth.isLoading.value
                                ? null
                                : () => setState(() => isSignUp = !isSignUp),
                            child: Text(
                              isSignUp
                                  ? 'Já tem uma conta? Entre agora'
                                  : 'Cadastre-se',
                              style: TextStyle(
                                color: primaryGreen.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 35),
                          // Divisória "OU"
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 1.2,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  "OU VIA",
                                  style: TextStyle(
                                    color: textDark.withOpacity(0.7),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 1.2,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 35),

                          // Botão de Login com Google
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: OutlinedButton.icon(
                              onPressed: _auth.isLoading.value
                                  ? null
                                  : _auth.loginGoogle,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: textDark,
                                side: BorderSide(
                                  color: primaryGreen.withOpacity(0.7),
                                  width: 1.8,
                                ), // Borda verde suave
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Roboto',
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                              icon: Image.asset(
                                'assets/pngoogle.png', // Certifique-se que o asset está configurado no pubspec.yaml
                                height: 24,
                              ),
                              label: const Text(
                                'Entrar com a Comunidade Google',
                              ), // Novo texto temático
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ) //padding interno do card
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}