class Chamado {
  int? id;
  String titulo;
  String descricao;
  String categoria;
  String prioridade;
  String bairro;
  String responsavel;
  DateTime data;
  String status;

  Chamado({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.prioridade,
    required this.bairro,
    required this.responsavel,
    required this.data,
    required this.status,
  });

  String get tempoDecorrido {
    final diferenca = DateTime.now().difference(data);
    if (diferenca.inDays > 0) return '${diferenca.inDays} dias atrás';
    if (diferenca.inHours > 0) return '${diferenca.inHours} horas atrás';
    return '${diferenca.inMinutes} minutos atrás';
  }

  int get pesoPrioridade {
    // Usamos toLowerCase para garantir que a ordenação não quebre
    switch (prioridade.toLowerCase()) {
      case 'crítica': return 4;
      case 'alta': return 3;
      case 'média': return 2;
      case 'baixa': return 1;
      default: return 0;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria,
      'prioridade': prioridade,
      'bairro': bairro,
      'responsavel': responsavel,
      'data': data.toIso8601String(),
      'status': status,
    };
  }

  factory Chamado.fromMap(Map<String, dynamic> map) {
    return Chamado(
      id: map['id'],
      titulo: map['titulo'],
      descricao: map['descricao'],
      categoria: map['categoria'],
      prioridade: map['prioridade'],
      bairro: map['bairro'],
      responsavel: map['responsavel'],
      data: DateTime.parse(map['data']),
      status: map['status'],
    );
  }
}