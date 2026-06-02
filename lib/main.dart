import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chamado_provider.dart';
import 'providers/theme_provider.dart'; // Importação do novo provider
import 'views/dashboard_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChamadoProvider()..loadChamados()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Injeção do Tema
      ],
      child: const SOSCidadeApp(),
    ),
  );
}

class SOSCidadeApp extends StatelessWidget {
  const SOSCidadeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usamos o Consumer para ouvir as mudanças de tema em tempo real
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'SOS Cidade',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode, // Controla se é Dark ou Light
          
          // Configuração do Tema Claro
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.grey.shade100,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          
          // Configuração do Tema Escuro
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
          
          home: const DashboardPage(),
        );
      },
    );
  }
}