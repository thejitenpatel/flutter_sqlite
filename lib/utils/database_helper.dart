import 'dart:io';

import 'package:fluttersqlite/models/note.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; //Singleton DatabaseHelper
  static Database _database;

  String noteTable = "note_table";
  String colId = "id";
  String colTitle = "title";
  String colPriority = "priority";
  String colDate = "date";
  String colDesc = "desc";

  DatabaseHelper._createInstance(); // Named Constructor

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); //Exucted only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the driectory path for both Android & iOS to store data.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    //Open/create db at a given path
    var noteDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return noteDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDesc TEXT, $colPriority INTEGER, $colDate TEXT)");
  }

  //Fetch Operation: Get all object from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

    //var result = await db.rawQuery("SELECT * FROM $noteTable ORDER BY $colPriority");
    var result = await db.query(noteTable, orderBy: colPriority);
    return result;
  }

  //Insert Operation
  Future<int> insertNote(Note note) async {
    Database db = await this.database;

    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  //Update Operation
  Future<int> updateNote(Note note) async {
    var db = await this.database;

    var result = await db.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  //Update Operation
  Future<int> deleteNote(int id) async {
    var db = await this.database;

    int result = await db.rawDelete("DELETE FROM $noteTable WHERE $colId=$id");
    return result;
  }

  //Update Operation
  Future<int> getCount(Note note) async {
    Database db = await this.database;

    List<Map<String, dynamic>> x =
        await db.rawQuery("SELECT COUNT(*) FROM $noteTable");

    int result = Sqflite.firstIntValue(x);
    return result;
  }

  //Get the 'Map List' [List<Map>] and convert it into 'NoteList' [List<Note>]
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList(); // Get "MaP list" from database.
    int count = noteMapList.length;
    List<Note> noteList = List<Note>();

    for(int i=0; i<count; i++){
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }
}
