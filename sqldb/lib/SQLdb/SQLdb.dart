import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

class SQLdb {
  /*数据库表名*/
  final String table;
  /*是否多列表方式创建数据列表
  *
  * 【more】true 此模式的数据表会自动创建一个自增字段"_id"作为数据插入索引。此模式创建的表，当调用【insert】时，旧数据不会被替换
  * 【more】false 默认模式。被创建的表会按表传入的json原样进入字段以及类型复制，每一次调用【insert】时，新数据会替换旧数据。
  * */
  final bool   more;

  /*初始化函数*/
  SQLdb.init(this.table, {Map<String, dynamic> json, this.more = false}){
    if (json != null) {
      if (!more) {
        _createSingleTable(json);
      } else {
        _createListTable(json);
      }
    }
  }

  /*私有方法 打开数据库*/
  Future<Database> _open() async {
    var PATH = join(await getDatabasesPath(), "test4.db");
    print("打开数据库:${PATH}");
    Database database = await openDatabase(PATH, version: 1);
    return database;
  }

  /*当前插入的原始数据*/
  static Map<String, dynamic> _data;
  /*初处理完毕的原始数据 [keys, values, ?]*/
  static List<String> _kvs;

  /*
  * 私有方法
  * 创建单列表模式数据库
  * */
  SQLdb _createSingleTable(Map<String, dynamic> json) {
    _data = json;
    _kvs = _setupMap(json);
    //'CREATE TABLE IF NOT EXISTS 【表名】 (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)');
    //"ID INTEGER PRIMARY KEY AUTOINCREMENT,";
    var sql = "CREATE TABLE IF NOT EXISTS ${table}(${_kvs[0]})";

    print("createSingleTable_sql:$sql");
    _create(sql);
    return this;
  }

  /*
  * 私有方法
  * 创建多列表模式数据库
  * */
  SQLdb _createListTable(Map<String, dynamic> json) {
    _data = json;
    _kvs = _setupMap(json);
    //'CREATE TABLE IF NOT EXISTS 【表名】 (_id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, value INTEGER, num REAL)');
    var autoid = "_id INTEGER PRIMARY KEY AUTOINCREMENT,";
    var sql = "CREATE TABLE IF NOT EXISTS ${table}(${autoid} ${_kvs[0]})";
    print("createListTable_sql:$sql");
    _create(sql);
    return this;
  }

  /*
  * 私有方法
  * 创建数据库
  * */
  _create(sql) async {
    Database database = await _open();
    await database.execute(sql);
    database.close();
  }

  getTableAll({ValueChanged<List<Map>> onChanged}) async{
    Database db = await _open();

    var sql = "SELECT name FROM sqlite_master WHERE type='table'";

    List<Map> tables = await db.rawQuery(sql);

    if (onChanged != null) {

      onChanged(tables);
    }
  }

  queryTable({ValueChanged<Map> onChanged}) async {

    Database db = await _open();

    var sql = "SELECT name FROM sqlite_master WHERE type='table' AND name='${table}'";
    Map tab = (await db.rawQuery(sql)).last;

    print(tab);

    if (tab['name'] == table) {
      return true;
    }

    if (onChanged != null) {
      onChanged(tab);
    }
  }

  /*
  * 插入数据
  * */
  insert(Map<String, dynamic> json, {ValueChanged<int> onChanged}) async {
    Database db = await _open();

    int count = await db.insert(
      table,
      json,
      conflictAlgorithm: more ? ConflictAlgorithm.rollback : ConflictAlgorithm.replace,
    );
    await db.close();
    if (onChanged != null) {
      onChanged(count);
    }
  }

  /*
  * 更新数据
  * */
  update(Map<String, dynamic> json,
      {String where,
      List<dynamic> whereArgs,
      ConflictAlgorithm conflictAlgorithm,
      ValueChanged<int> onChanged}) async {
    Database db = await _open();
    int count = await db.update(
      table,
      json,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
    await db.close();
    print('updated: $count');
    if (onChanged != null) {
      onChanged(count);
    }
  }

  /*
  * 获取数据列表
  * */
  getList(@required ValueChanged<List> onChanged,
      {bool distinct,
      List<String> columns,
      String where,
      List<dynamic> whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset}) async {

    Database db = await _open();
    onChanged(await db.query(table,
        where: where,
        whereArgs: whereArgs,
        limit: limit,
        offset: offset,
        columns: columns,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy));
  }

  /*
  * 删除数据
  * */
  deleteList({
    String where,
    List<dynamic> whereArgs,
    ValueChanged<int> onChanged,
  }) async {
    Database db = await _open();
    int count = await db.delete(table, where: where, whereArgs: whereArgs);
    await db.close();
    if (onChanged != null) {
      onChanged(count);
    }
  }

  /*
  * 私有方法
  * 处理原型数据函数
  * */
  List<String> _setupMap(Map<String, dynamic> json) {
    var keys = "";
    var values = "";
    var point = "";

    json.forEach((k, v) {
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
        //注意：如果服务器返回的数据值为null时，在创建表的时候是不知道值 类型的，这里只是暂时用一下文本类型表示
      }
      if (k == "id") {
        if (!more) {
          key = "INTEGER PRIMARY KEY";
        }
      }

      keys = keys + " ${k} ${key},";
      values = values + " ${v},";
      point = point + "?,";
    });

    keys = keys.substring(1, keys.length - 1);
    values = values.substring(1, values.length - 1);
    point = point.substring(0, point.length - 1);

    print(keys);
//    print(values);
    return [keys, values, point];
  }

  static const CREATE_TABLE =
      "CREATE TABLE IF NOT EXISTS"; //eg: CREATE TABLE IF NOT EXISTS 【表名】(【key type】);
  static const DROP_TABLE =
      "DROP TABLE IF EXISTS"; //eg: DROP TABLE IF EXISTS 【数据库名】;
  static const INSERT_TABLE =
      "INSERT INTO"; //eg: INSERT INTO 【表名】 (【keys】) values (【与keys对应的值】);
  static const SELECT_TABLE =
      "SELECT"; //eg: SELECT * FROM 【表名】 WHERE 【条件 age >= 18】;
  static const FROM = "FROM"; //eg: FROM 【表名】;
  static const UPDATE_TABLE =
      "UPDATE"; //eg: UPDATE 【表名】 SET money = '168.00' WHERE id = '14';
  static const SET_KYES_VALUES = "SET"; //eg: SET id = '14';
  static const DELETE_TABLE = "DELETE FROM"; //eg: DELETE FROM 【表名】;
  static const WHERE = "WHERE"; //eg: WHERE age > 18;
  static const KEY_ID = "";

  String _create_table(tablename, String keys) {
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

  String _update_table(tablename, String key_value, String where) {
    //SET name = ?, VALUE = ? WHERE name = ?
    return "${UPDATE_TABLE} ${tablename} SET ${key_value}, ${WHERE} ${where}";
  }

  String _delete_table(tablename) {
    return "${DELETE_TABLE} ${tablename}";
  }
}
