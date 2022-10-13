import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bibleapp/model/bible_game.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bibleapp/model/bible_content.dart';
import 'package:bibleapp/model/bible_bookmark.dart';
import 'package:bibleapp/model/bible_notes.dart';
import 'package:bibleapp/model/bible_crown.dart';

class SQLHelper {
  static String bible_bookmark = 'bible_bookmark';
  static String bible_notes = 'bible_notes';
  static String bible_crown = 'bible_crown';
  static String bible_game = 'bible_game';

  static final bible_content = new BibleContent(0, "", "", "");

  static final _databaseName = "bible.db3";
  static final _databaseVersion = 1;

/*
  static final table = 'my_table';
  
  static final columnId = '_id';
  static final columnName = 'name';
  static final columnAge = 'age';
*/
  // make this a singleton class
  SQLHelper._privateConstructor();
  static final SQLHelper instance = SQLHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    /*var table = bible_content.tableName;
    var id = bible_content.idName;
    var title = bible_content.titleName;
    var titleNum = bible_content.titleNumName;
    var content = bible_content.contentName;*/
    await db.execute(
      "CREATE TABLE bible_bookmark(id INTEGER PRIMARY KEY AUTOINCREMENT, title INTEGER, content INTEGER, text INTEGER);",
    );
    await db.execute(
      "CREATE TABLE bible_notes(id INTEGER PRIMARY KEY AUTOINCREMENT, title INTEGER, content INTEGER, date DATETIME);",
    );
    await db.execute(
      "CREATE TABLE bible_crown(id INTEGER PRIMARY KEY AUTOINCREMENT, type INTEGER, date DATETIME);",
    );
    //20201206
    /*await db.execute(
      "CREATE TABLE bible_game(id INTEGER PRIMARY KEY AUTOINCREMENT, type INTEGER, correctQuestionNum INTEGER, totalAnsweredNum INTEGER, level INTEGER, date DATETIME);"
      ,);*/

/*
      String data = await rootBundle.loadString('assets/json/bible_cuv.json');
    
      List<BibleContent> temp = parseJosn(data);
      print(SQLHelper.bible_content.title);
      temp.forEach((BibleContent bibleContent) {
      //print("${bibleContent.title} is electric? ${bibleContent.content}");
      Map<String, dynamic> row = {SQLHelper.bible_content.titleName : bibleContent.title,SQLHelper.bible_content.contentName  : bibleContent.content};
      insert(row);
      });
*/
  }

  Future<int> insertBibleGame(BibleGame bibleGame) async {
    Database db = await instance.database;
    if (bibleGame.id == null) {
      return await db.insert(
        bible_game,
        bibleGame.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      return await db.update(
        bible_game,
        bibleGame.toMap(),
        where: 'id = ?',
        whereArgs: [bibleGame.id],
      );
    }
  }

  Future<BibleGame> getBibleGameByType(BibleGame bibleGame) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      bible_game,
      where: 'type = ?',
      whereArgs: [bibleGame.type],
      //orderBy:'title,content,text,id',
    );
    if (maps.length != 0)
      return BibleGame(
          id: maps[0]['id'],
          type: maps[0]['type'],
          correctQuestionNum: maps[0]['correctQuestionNum'],
          totalAnsweredNum: maps[0]['totalAnsweredNum'],
          date: maps[0]['date']);
    return null;
  }

  Future<int> insertCrown(BibleCrown bibleCrown) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      bible_crown,
      where: 'type = ? and date = ?',
      whereArgs: [bibleCrown.type, bibleCrown.date],
    );
    if (maps.length == 0) {
      return await db.insert(
        bible_crown,
        bibleCrown.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return 0;
  }

  Future<List<BibleCrown>> getAllBibleCrown() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all.
    final List<Map<String, dynamic>> maps =
        await db.query(bible_crown, orderBy: 'id');

    // Convert the List<Map<String, dynamic> into a List<>.
    return List.generate(maps.length, (i) {
      return BibleCrown(
        id: maps[i]['id'],
        type: maps[i]['type'],
        date: maps[i]['date'],
      );
    });
  }

  Future<int> insertBookmark(BibleBookmark bibleBookmark) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      bible_bookmark,
      where: 'title = ? and content = ? and text = ?',
      whereArgs: [
        bibleBookmark.title,
        bibleBookmark.content,
        bibleBookmark.text
      ],
      orderBy: 'title,content,text,id',
    );
    if (maps.length == 0) {
      return await db.insert(
        bible_bookmark,
        bibleBookmark.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return 0;
  }

  Future<List<BibleBookmark>> getAllBibleBookmark() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all.
    final List<Map<String, dynamic>> maps =
        await db.query(bible_bookmark, orderBy: 'title,content,text,id');

    // Convert the List<Map<String, dynamic> into a List<>.
    return List.generate(maps.length, (i) {
      return BibleBookmark(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        text: maps[i]['text'],
      );
    });
  }

  Future<List<BibleBookmark>> getBibleBookmarkByTitle(
      int titleId, int titleNum) async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table.
    final List<Map<String, dynamic>> maps = await db.query(
      bible_bookmark,
      where: 'title = ? and content = ?',
      whereArgs: [titleId, titleNum],
      orderBy: 'title,content,text,id',
    );

    // Convert the List<Map<String, dynamic> into a List<>.
    return List.generate(maps.length, (i) {
      return BibleBookmark(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        text: maps[i]['text'],
      );
    });
  }

  Future<List<BibleBookmark>> getBibleBookmarkByTitleId(int titleId) async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table.
    final List<Map<String, dynamic>> maps = await db.query(
      bible_bookmark,
      where: 'title = ?',
      whereArgs: [titleId],
      orderBy: 'title,content,text,id',
    );

    // Convert the List<Map<String, dynamic> into a List<>.
    return List.generate(maps.length, (i) {
      return BibleBookmark(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        text: maps[i]['text'],
      );
    });
  }

  Future<void> deleteBookMarkByTitleIdContentIdTextId(
      int titleId, int contentId, int textId) async {
    final Database db = await database;
    await db.delete(
      bible_bookmark,
      where: 'title = ? and content = ? and text = ?',
      whereArgs: [titleId, contentId, textId],
    );
  }

  Future<int> insertNotes(BibleNotes bibleNotes) async {
    Database db = await instance.database;
    if (bibleNotes.id == null) {
      /*final List<Map<String, dynamic>> maps = await db.query(
        bible_notes,
        //where: 'id = ?',
        //whereArgs: [bibleNotes.id],
        orderBy:'title,content,id',
        );*/
      return await db.insert(
        bible_notes,
        bibleNotes.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      /*final List<Map<String, dynamic>> maps = await db.query(
        bible_notes,
        where: 'id = ?',
        whereArgs: [bibleNotes.id],
        orderBy:'title,content,id',
        );*/
      return await db.update(
        bible_notes,
        bibleNotes.toMap(),
        where: 'id = ?',
        whereArgs: [bibleNotes.id],
        //conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<BibleNotes>> getBibleNotesByMonth(
      DateTime first, DateTime last) async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table.
    final List<Map<String, dynamic>> maps = await db.query(
      bible_notes,
      where: 'date >= ? and date <= ?',
      whereArgs: [first.toString(), last.toString()],
      orderBy: 'date',
    );

    // Convert the List<Map<String, dynamic> into a List<>.
    return List.generate(maps.length, (i) {
      return BibleNotes(
        id: maps[i]['id'],
        title: maps[i]['title'].toString(),
        content: maps[i]['content'],
        date: maps[i]['date'],
      );
    });
  }

  Future<List<BibleNotes>> getAllBibleNotes() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table.
    final List<Map<String, dynamic>> maps = await db.query(
      bible_notes,
      orderBy: 'date',
    );

    // Convert the List<Map<String, dynamic> into a List<>.
    return List.generate(maps.length, (i) {
      return BibleNotes(
        id: maps[i]['id'],
        title: maps[i]['title'].toString(),
        content: maps[i]['content'],
        date: maps[i]['date'],
      );
    });
  }

  Future<List<BibleNotes>> getBibleNotesById(int id) async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table.
    final List<Map<String, dynamic>> maps = await db.query(
      bible_bookmark,
      where: 'id = ?',
      whereArgs: [id],
      orderBy: 'title,content,id',
    );

    // Convert the List<Map<String, dynamic> into a List<>.
    return List.generate(maps.length, (i) {
      return BibleNotes(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        date: maps[i]['date'],
      );
    });
  }

  Future<void> deleteNote(int id) async {
    final Database db = await database;
    await db.delete(
      bible_notes,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(bible_content.tableName, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<BibleContent>> queryAllRows() async {
    Database db = await instance.database;
    var res = await db.query(bible_content.tableName);
    //print(res);
    return res.map((f) => BibleContent.fromMap(f)).toList();
  }

  Future<List<String>> queryBibleContentByTitle(
      String title, String titleNum) async {
    Database db = await instance.database;
    var titleName = bible_content.titleName;
    var titleNumName = bible_content.titleNumName;
    var res = await db.query(bible_content.tableName,
        where: '$titleName = ? and $titleNumName = ?',
        whereArgs: [title, titleNum]);
    BibleContent temp = res.map((f) => BibleContent.fromMap(f)).elementAt(0);
    List<String> tmepList = temp.content.split("=.=");
    //print(tmepList);
    return tmepList;
  }

  Future<List<String>> queryBibleContentAllTitle() async {
    Database db = await instance.database;
    var titleName = bible_content.titleName;
    var idName = bible_content.idName;
    var table = bible_content.tableName;
    var res = await db
        .rawQuery('select * from $table group by $titleName order by $idName');
    List<BibleContent> temp = res.map((f) => BibleContent.fromMap(f)).toList();
    List<String> tmepList = new List<String>();
    for (int i = 0; i < temp.length; i++) {
      tmepList.add(temp[i].titleId);
    }
    //print(tmepList);
    return tmepList;
  }

  Future<int> queryTitleTotelCount(String title) async {
    Database db = await instance.database;
    var table = bible_content.tableName;
    var titleName = bible_content.titleName;
    return Sqflite.firstIntValue(await db
        .rawQuery('SELECT COUNT(*) FROM $table where $titleName = \"$title\"'));
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    var table = bible_content.tableName;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<int> queryBibleContentRowByTitleAndCount() async {
    Database db = await instance.database;
    var table = bible_content.tableName;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT * FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[bible_content.idName];
    var idName = bible_content.idName;
    return await db.update(bible_content.tableName, row,
        where: '$idName = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    var id = bible_content.idName;
    return await db
        .delete(bible_content.tableName, where: '$id = ?', whereArgs: [id]);
  }

  void deleteAll() async {
    Database db = await instance.database;
    var id = bible_content.idName;
    await db.delete(bible_content.tableName);
  }
}
