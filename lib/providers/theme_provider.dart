import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  
  // Chave usada para salvar a informação no celular
  final String _prefKey = "is_dark_mode";

  bool get isDarkMode => _isDarkMode;

  // Retorna o tema correspondente
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // O construtor é chamado assim que o app abre. Ele já manda carregar o tema salvo.
  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // Função que inverte o tema e manda salvar
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemeToPrefs();
    notifyListeners();
  }

  // Busca na memória do celular se o dark mode estava ativo (se não achar nada, retorna false)
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_prefKey) ?? false;
    notifyListeners();
  }

  // Salva na memória do celular a escolha atual
  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_prefKey, _isDarkMode);
  }
}