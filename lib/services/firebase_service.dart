import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/chamado_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Envia o chamado do celular para a nuvem
  Future<void> sincronizarChamado(Chamado chamado) async {
    String? urlImagemNuvem;

    // 1. UPLOAD DA IMAGEM (Se existir e for um arquivo local do telemóvel)
    if (chamado.imagemPath != null && !chamado.imagemPath!.startsWith('http')) {
      try {
        File arquivoImagem = File(chamado.imagemPath!);
        if (await arquivoImagem.exists()) {
          // Cria um nome único baseado no ID e no tempo para não sobrepor fotos
          String nomeArquivo = 'evidencias/chamado_${chamado.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          
          // Faz o upload para o Firebase Storage
          TaskSnapshot snapshot = await _storage.ref(nomeArquivo).putFile(arquivoImagem);
          
          // Pega o link público (URL) gerado pela Google
          urlImagemNuvem = await snapshot.ref.getDownloadURL();
        }
      } catch (e) {
        print("Erro ao subir a imagem para o Storage: $e");
        // Se a imagem falhar (ex: ficheiro corrompido), o código continua para não perder a denúncia escrita
      }
    } else if (chamado.imagemPath != null && chamado.imagemPath!.startsWith('http')) {
       // Se já for um link de internet (já foi sincronizada antes), apenas mantém
       urlImagemNuvem = chamado.imagemPath; 
    }

    // 2. SALVAR DADOS NO FIRESTORE
    try {
      // Usamos o próprio ID do SQLite como nome do documento na nuvem para garantir o espelhamento exato
      await _firestore.collection('chamados').doc(chamado.id.toString()).set({
        'titulo': chamado.titulo,
        'descricao': chamado.descricao,
        'categoria': chamado.categoria,
        'prioridade': chamado.prioridade,
        'bairro': chamado.bairro,
        'responsavel': chamado.responsavel,
        'data': chamado.data.toIso8601String(),
        'status': chamado.status,
        'isFavorito': chamado.isFavorito,
        // Guarda a URL da internet em vez do caminho C:/...
        'imagemPath': urlImagemNuvem, 
        'latitude': chamado.latitude,
        'longitude': chamado.longitude,
        // Carimbo de tempo do servidor para sabermos exatamente quando bateu na nuvem
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // O merge atualiza os dados se o documento já existir
      
    } catch (e) {
      throw Exception("Falha ao salvar os dados no Firestore: $e");
    }
  }
}