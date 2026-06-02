import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/chamado_model.dart';

class ChamadoProvider with ChangeNotifier {
  List<Chamado> _chamados = [];
  bool _isLoading = true;

  List<Chamado> get chamados => _chamados;
  bool get isLoading => _isLoading;

  bool get hasCriticalAlert {
    // Atualizado para 'Crítica' e 'Concluído'
    return _chamados.where((c) => c.prioridade == 'Crítica' && c.status != 'Concluído').length > 5;
  }

  Future<void> loadChamados() async {
    _isLoading = true;
    notifyListeners();
    
    _chamados = await DatabaseHelper.instance.fetchChamados();
    _sortChamados();
    
    _isLoading = false;
    notifyListeners();
  }

  void _sortChamados() {
    _chamados.sort((a, b) => b.pesoPrioridade.compareTo(a.pesoPrioridade));
  }

  bool isTituloRepetido(String titulo, {int? idIgnorado}) {
    return _chamados.any((c) => c.titulo.toLowerCase() == titulo.toLowerCase() && c.id != idIgnorado);
  }

  Future<void> addChamado(Chamado chamado) async {
    if (isTituloRepetido(chamado.titulo)) {
      throw Exception('Já existe um chamado com este título.');
    }
    await DatabaseHelper.instance.insertChamado(chamado);
    await loadChamados();
  }

  Future<void> updateChamado(Chamado chamado) async {
    final chamadoOriginal = _chamados.firstWhere((c) => c.id == chamado.id);
    // Atualizado para 'Concluído'
    if (chamadoOriginal.status == 'Concluído') {
      throw Exception('Chamados concluídos não podem ser editados.');
    }

    await DatabaseHelper.instance.updateChamado(chamado);
    await loadChamados();
  }
}