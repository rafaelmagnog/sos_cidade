import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chamado_provider.dart';
import 'views/dashboard_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChamadoProvider()..loadChamados()),
      ],
      child: const SOSCidadeApp(),
    ),
  );
}

class SOSCidadeApp extends StatelessWidget {
  const SOSCidadeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOS Cidade',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DashboardPage(),
    );
  }
}