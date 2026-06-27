import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/catch.dart';
import '../models/counter.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._();

  DatabaseService._();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'bestcatchbuddy.db');

    return await openDatabase(
      path,
      version: 9,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE catches (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            angler TEXT NOT NULL,
            species TEXT NOT NULL,
            location TEXT DEFAULT '',
            lure TEXT DEFAULT '',
            photo_path TEXT,
            photo_paths TEXT,
            weight REAL,
            weight_unit TEXT DEFAULT 'kg',
            length REAL,
            length_unit TEXT DEFAULT 'cm',
            latitude REAL,
            longitude REAL,
            weather_temp REAL,
            weather_condition TEXT,
            weather_icon TEXT,
            notes TEXT,
            trip_name TEXT,
            caught_at TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE counters (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            angler TEXT NOT NULL UNIQUE,
            count INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE voice_species (
            angler TEXT NOT NULL,
            species TEXT NOT NULL,
            count INTEGER DEFAULT 0,
            PRIMARY KEY (angler, species)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE catches ADD COLUMN weight REAL');
          await db.execute("ALTER TABLE catches ADD COLUMN weight_unit TEXT DEFAULT 'kg'");
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE catches ADD COLUMN length REAL');
          await db.execute("ALTER TABLE catches ADD COLUMN length_unit TEXT DEFAULT 'cm'");
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE catches ADD COLUMN photo_paths TEXT');
        }
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS voice_species (
              angler TEXT NOT NULL,
              species TEXT NOT NULL,
              count INTEGER DEFAULT 0,
              PRIMARY KEY (angler, species)
            )
          ''');
        }
        if (oldVersion < 6) {
          await db.execute('ALTER TABLE catches ADD COLUMN latitude REAL');
          await db.execute('ALTER TABLE catches ADD COLUMN longitude REAL');
        }
        if (oldVersion < 7) {
          await db.execute('ALTER TABLE catches ADD COLUMN weather_temp REAL');
          await db.execute('ALTER TABLE catches ADD COLUMN weather_condition TEXT');
          await db.execute('ALTER TABLE catches ADD COLUMN weather_icon TEXT');
        }
        if (oldVersion < 8) {
          await db.execute('ALTER TABLE catches ADD COLUMN notes TEXT');
        }
        if (oldVersion < 9) {
          await db.execute('ALTER TABLE catches ADD COLUMN trip_name TEXT');
        }
      },
    );
  }

  // ---- Catches ----

  Future<List<Catch>> getCatches() async {
    final db = await database;
    final maps = await db.query('catches', orderBy: 'created_at DESC');
    return maps.map((m) => Catch.fromMap(m)).toList();
  }

  Future<int> addCatch(Catch c) async {
    final db = await database;
    return await db.insert('catches', c.toMap());
  }

  Future<int> updateCatch(Catch c) async {
    final db = await database;
    return await db.update(
      'catches',
      c.toMap(),
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  Future<int> deleteCatch(int id) async {
    final db = await database;
    return await db.delete('catches', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Voice Species Counts ----

  Future<void> incrementVoiceSpecies(String angler, String species) async {
    final db = await database;
    await db.rawInsert('''
      INSERT INTO voice_species (angler, species, count)
      VALUES (?, ?, 1)
      ON CONFLICT(angler, species) DO UPDATE SET count = count + 1
    ''', [angler, species]);
  }

  Future<Map<String, int>> getVoiceSpeciesCounts(String angler) async {
    final db = await database;
    final maps = await db.query(
      'voice_species',
      where: 'angler = ?',
      whereArgs: [angler],
    );
    final counts = <String, int>{};
    for (final m in maps) {
      counts[m['species'] as String] = m['count'] as int;
    }
    return counts;
  }

  Future<void> clearVoiceSpecies() async {
    final db = await database;
    await db.delete('voice_species');
  }

  // ---- Counters ----

  Future<List<FishCounter>> getCounters() async {
    final db = await database;
    final maps = await db.query('counters', orderBy: 'angler ASC');
    return maps.map((m) => FishCounter.fromMap(m)).toList();
  }

  Future<int> addCounter(String angler) async {
    final db = await database;
    return await db.insert(
      'counters',
      FishCounter(angler: angler).toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> incrementCounter(int id) async {
    final db = await database;
    return await db.rawUpdate(
      'UPDATE counters SET count = count + 1 WHERE id = ?',
      [id],
    );
  }

  Future<int> decrementCounter(int id) async {
    final db = await database;
    final current = await db.query('counters', where: 'id = ?', whereArgs: [id]);
    if (current.isNotEmpty && (current.first['count'] as int) > 0) {
      return await db.rawUpdate(
        'UPDATE counters SET count = count - 1 WHERE id = ?',
        [id],
      );
    }
    return 0;
  }

  Future<int> resetCounter(int id) async {
    final db = await database;
    return await db.update(
      'counters',
      {'count': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCounter(int id) async {
    final db = await database;
    return await db.delete('counters', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> newTrip() async {
    final db = await database;
    await db.delete('counters');
  }
}
