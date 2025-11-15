import 'package:flutter/material.dart';
import 'package:rural_delivery/controller/enderecoController.dart';
import 'package:rural_delivery/firebase_options.dart'; //importa as configurações do firebase, da classe firebase_options.dart que foi gerada automaticamente pelo FlutterFire CLI, anteriormente as chaves do firebase ficavam aqui no main.
import 'package:firebase_core/firebase_core.dart'; //importa o firebase core para inicializar o firebase
import 'package:rural_delivery/repositores/enderecoRepository.dart';
import 'package:rural_delivery/screens/loginScreen.dart';
import 'package:get/get.dart';
import 'package:rural_delivery/controller/authController.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();//inicializa o flutter antes de rodar o app
  
  await Firebase.initializeApp( //inicializa o firebase com as configurações da classe DefaultFirebaseOptions
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // 2. INJETE SEU AUTHCONTROLLER AQUI (permanent: true)
  // Isso o coloca na memória global ANTES do app rodar.
  Get.put(AuthController(), permanent: true);
  Get.put(EnderecoRepository(), permanent: true);
  Get.put(EnderecoController(), permanent: true);
  
  
  runApp(const MyApp()); //chama a classe MyApp que inicia o app
}



class MyApp extends StatelessWidget { //
  const MyApp({super.key});
    @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'flutter demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: LoginScreen(), //redireciona para a tela de login
    );
  }
}






