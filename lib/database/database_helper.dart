import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/chamado_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chamados.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chamados (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descricao TEXT NOT NULL,
        categoria TEXT NOT NULL,
        prioridade TEXT NOT NULL,
        bairro TEXT NOT NULL,
        responsavel TEXT NOT NULL,
        data TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertChamado(Chamado chamado) async {
    final db = await instance.database;
    return await db.insert('chamados', chamado.toMap());
  }

  Future<List<Chamado>> fetchChamados() async {
    final db = await instance.database;
    final result = await db.query('chamados');
    return result.map((json) => Chamado.fromMap(json)).toList();
  }

  Future<int> updateChamado(Chamado chamado) async {
    final db = await instance.database;
    return db.update('chamados', chamado.toMap(), where: 'id = ?', whereArgs: [chamado.id]);
  }
}