import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chamado_provider.dart';
import 'providers/theme_provider.dart'; 
import 'views/splash_page.dart'; // AQUI: Importação da nova Splash Screen

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChamadoProvider()..loadChamados()),
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
          
          // AQUI: A SplashPage agora é a primeira tela que carrega
          home: const SplashPage(), 
        );
      },
    );
  }
}