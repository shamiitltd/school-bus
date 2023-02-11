import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'location.dart';

class LocationDatabase {
  static final LocationDatabase instance = LocationDatabase._init();
  static Database? _database;
  LocationDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(dbLocation);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: dbVersion, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const boolType = 'BOOLEAN NOT NULL';
    const doubleType = 'DOUBLE NOT NULL';
    const defaultDateTimeType = 'DATETIME default CURRENT_TIMESTAMP';//DATETIME DEFAULT GETUTCDATE() or DEFAULT GETDATE()
    const dateTimeType = 'DATETIME NULL';

    await db.execute('''
CREATE TABLE $tableLocation ( 
  ${LocationFields.id} $idType, 
  ${LocationFields.latitude} $doubleType,
  ${LocationFields.longitude} $doubleType,
  ${LocationFields.distanceSoFar} $doubleType,
  ${LocationFields.isProcessed} $boolType,
  ${LocationFields.addedDate} $defaultDateTimeType,
  ${LocationFields.processedDate} $dateTimeType
  )
''');
  }

  Future<Locations> create(Locations locations) async {
    final db = await instance.database;

    // final json = locations.toJson();
    // final columns =
    //     '${NoteFields.title}, ${NoteFields.description}, ${NoteFields.time}';
    // final values =
    //     '${json[NoteFields.title]}, ${json[NoteFields.description]}, ${json[NoteFields.time]}';
    // final id = await db
    //     .rawInsert('INSERT INTO table_name ($columns) VALUES ($values)');

    final id = await db.insert(tableLocation, locations.toJson());
    return locations.copy(id: id);
  }

  Future<Locations> readIsProcessedLocation(int isProcessed) async {//pass 1 for processed and 0 for not processed.
    final db = await instance.database;
    const orderBy = '${LocationFields.addedDate} ASC';

    final maps = await db.query(
      tableLocation,
      columns: LocationFields.values,
      where: '${LocationFields.isProcessed} = ?',
      whereArgs: [isProcessed],
      orderBy: orderBy
    );

    if (maps.isNotEmpty) {
      return Locations.fromJson(maps.first);
    } else {
      throw Exception('${isProcessed == 0 ? 'Not Processed':'Processed'} not found');
    }
  }

  Future<List<Locations>> readAllNotes() async {
    final db = await instance.database;
    const orderBy = '${LocationFields.addedDate} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');
    final result = await db.query(tableLocation, orderBy: orderBy);
    return result.map((json) => Locations.fromJson(json)).toList();
  }

  Future<int> update(Locations locations) async {
    final db = await instance.database;
    return db.update(
      tableLocation,
      locations.toJson(),
      where: '${LocationFields.id} = ?',
      whereArgs: [locations.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableLocation,
      where: '${LocationFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}