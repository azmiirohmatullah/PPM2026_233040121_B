import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Catatan {
  final int? id;
  final String judul;
  final String isi;
  final String kategori;
  final DateTime dibuatPada;

  Catatan({
    this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.dibuatPada,
  });

  // Dart object → row Map
  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'judul': judul,
    'isi': isi,
    'kategori': kategori,
    'dibuat_pada': dibuatPada.millisecondsSinceEpoch,
  };

  // Row Map → Dart object
  static Catatan fromMap(Map<String, Object?> m) => Catatan(
    id: m['id'] as int?,
    judul: m['judul'] as String,
    isi: m['isi'] as String,
    kategori: m['kategori'] as String,
    dibuatPada: DateTime.fromMillisecondsSinceEpoch(
      m['dibuat_pada'] as int,
    ),
  );

  // Helper untuk Edit
  Catatan copyWith({
    String? judul,
    String? isi,
    String? kategori,
  }) =>
      Catatan(
        id: id,
        judul: judul ?? this.judul,
        isi: isi ?? this.isi,
        kategori: kategori ?? this.kategori,
        dibuatPada: dibuatPada,
      );

  // Helper untuk format tanggal agar bisa dipakai di mana saja
  String get formatTanggal {
    final hari = dibuatPada.day.toString().padLeft(2, '0');
    final bulan = dibuatPada.month.toString().padLeft(2, '0');
    final jam = dibuatPada.hour.toString().padLeft(2, '0');
    final menit = dibuatPada.minute.toString().padLeft(2, '0');
    return '$hari/$bulan/${dibuatPada.year} $jam:$menit';
  }
}

class DbHelper {
  DbHelper._();

  static final DbHelper instance = DbHelper._();

  static const _dbName = 'catatan.db';
  static const _dbVersion = 1;
  static const tabel = 'catatan';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final dir = await getDatabasesPath();
    final path = join(dir, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tabel (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            judul       TEXT    NOT NULL,
            isi         TEXT    NOT NULL,
            kategori    TEXT    NOT NULL,
            dibuat_pada INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // ===== CREATE =====
  Future<int> insert(Catatan c) async {
    final db = await database;
    return db.insert(tabel, c.toMap());
  }

  // ===== READ =====
  Future<List<Catatan>> getAll() async {
    final db = await database;

    final rows = await db.query(
      tabel,
      orderBy: 'dibuat_pada DESC',
    );

    return rows.map(Catatan.fromMap).toList();
  }

  // ===== UPDATE =====
  Future<int> update(Catatan c) async {
    assert(c.id != null);

    final db = await database;

    return db.update(
      tabel,
      c.toMap(),
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  // ===== DELETE =====
  Future<int> delete(int id) async {
    final db = await database;

    return db.delete(
      tabel,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
