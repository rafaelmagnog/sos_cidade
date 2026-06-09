import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chamado_provider.dart';
import 'providers/theme_provider.dart'; 
import 'services/notification_service.dart'; 
import 'views/splash_page.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 

void main() async {
  // Garante a inicialização correta dos bindings antes de ligar os serviços nativos
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o Firebase com as configurações geradas pelo CLI
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa o serviço de notificações locais
  await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        // Carrega do SQLite e liga o Radar da Nuvem simultaneamente!
        ChangeNotifierProvider(
          create: (_) => ChamadoProvider()
            ..loadChamados()
            ..escutarChamadosEmTempoReal(),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), 
      ],
      child: const SOSCidadeApp(),
    ),
  );
}

class SOSCidadeApp extends StatelessWidget {
  const SOSCidadeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'SOS Cidade',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode, 
          
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.grey.shade100,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.grey.shade900,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey.shade900,
              foregroundColor: Colors.white,
              elevation: 1,
            ),
          ),
          
          home: const SplashPage(), 
        );
      },
    );
  }
}