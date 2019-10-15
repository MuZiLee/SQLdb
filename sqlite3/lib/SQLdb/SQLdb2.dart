import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';




class SQLdb {
  Future<Database> _open() async {
    PATH = join(await getDatabasesPath(), DATABASE_NAME);
    print("打开数据库:${PATH}");
    return await openDatabase(PATH, version: 1);
  }

  execute(sql) async {
    Database db = await _open();
    await db.execute(sql);
    await db.close();
  }

  List<String> _setupMap(Map<String, dynamic> map) {
    var keys   = "";
    var values = "";
    var point  = "";

    map.forEach((k, v) {
      var key = "";

      if (v.runtimeType == String) {
        key = "TEXT";
      } else if (v.runtimeType == int) {
        key = "INTEGER";
      } else if (v.runtimeType == bool) {
        key = "BLOB";
      } else if (v.runtimeType == double) {
        key = "REAL";
      } else if (v.runtimeType == List) {
        key = "NONE";
      } else if (v.runtimeType == Set) {
        key = "NONE";
      } else if (v.runtimeType == Null) {
        key = "TEXT";
        v = "";
      }
      if (k == "id") {
//        k = "_id";
        key = "INTEGER PRIMARY KEY";
      }
//      print(v.runtimeType);

      keys   = keys + " ${k} ${key},";
      values = values + " ${v},";
      point  = point + "?,";
    });

    keys   = keys.substring(1, keys.length - 1);
    values = values.substring(1, values.length - 1);
    point  = point.substring(0, point.length - 1);


//    print(keys);
//    print(values);
    return [keys, values, point];
  }

  SQLdb.createTable(tablename, Map<String, dynamic> map) {
    List listHandle = _setupMap(map);

    //'CREATE TABLE IF NOT EXISTS 【表名】 (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)');
    //var autoincrment = "ID INTEGER PRIMARY KEY AUTOINCREMENT,";
    var autoincrment = "";
    var sql = _create_table(tablename, autoincrment + listHandle[0]);
    print("sql:$sql");

    execute(sql);
  }

  insertTable(tablename, Map<String, dynamic> json) async {
    List kvs = _setupMap(json);

    var sql = _insert_table(tablename, kvs[0], kvs[1]);
    print("---");
    print("insertTable:${sql}");
    print("---");

    Database db = await _open();
//    await db.rawInsert(sql);
    await db.insert(tablename, json, conflictAlgorithm: ConflictAlgorithm.replace);
//    await db.close();
  }


  String PATH = "";
  String DATABASE_NAME = "dandankj.db";

  static const CREATE_TABLE     = "CREATE TABLE IF NOT EXISTS";//eg: CREATE TABLE IF NOT EXISTS 【表名】(【key type】);
  static const DROP_TABLE       = "DROP TABLE IF EXISTS";//eg: DROP TABLE IF EXISTS 【数据库名】;
  static const INSERT_TABLE     = "INSERT INTO";//eg: INSERT INTO 【表名】 (【keys】) values (【与keys对应的值】);
  static const SELECT_TABLE     = "SELECT";//eg: SELECT * FROM 【表名】 WHERE 【条件 age >= 18】;
  static const FROM             = "FROM";//eg: FROM 【表名】;
  static const UPDATE_TABLE     = "UPDATE";//eg: UPDATE 【表名】 SET money = '168.00' WHERE id = '14';
  static const SET_KYES_VALUES  = "SET";//eg: SET id = '14';
  static const DELETE_TABLE     = "DELETE FROM"; //eg: DELETE FROM 【表名】;
  static const WHERE            = "WHERE"; //eg: WHERE age > 18;
  static const KEY_ID           = "";

  String _create_table(tablename,String keys) {
    return "${CREATE_TABLE} ${tablename}(${keys})";
  }
  String _drop_table(databasename) {
    return "${DROP_TABLE} ${databasename}";
  }
  String _insert_table(tablename, String keys, String values) {
    return "${INSERT_TABLE} ${tablename}(${keys}) VALUES(${values})";
  }
  String _select_table(tablename, String where) {
    return "${SELECT_TABLE} * ${FROM} ${tablename} ${WHERE} ${where}";
  }
  String _update_table(tablename, String set, String where){
    return "${UPDATE_TABLE} ${tablename} ${SET_KYES_VALUES} ${WHERE} ${where}";
  }
  String _delete_table(tablename) {
    return "${DELETE_TABLE} ${tablename}";
  }
}
