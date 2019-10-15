# sqlite3

A new Flutter application.

![如图]()


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

    数据库表名
    final String table;


【more】true 此模式的数据表会自动创建一个自增字段"_id"作为数据插入索引。此模式创建的表，当调用【insert】时，旧数据不会被替换

【more】false 默认模式。被创建的表会按表传入的json原样进入字段以及类型复制，每一次调用【insert】时，新数据会替换旧数据。

final bool   more;

-------

    var data = {
      "id": 14,
      "level": "A,B,C,E",
      "mobile": "13800138000",
      "uid": "admin",
      "name": "kkk",
      "step": 2
    };
    
-------
初始化

    //TODO:初始化自动创建db文件。
    SQLdb.init("member_check_login", json: data);


-------
增

    //TODO: 增加数据
    SQLdb.init("member_check_login", json: data).insert(data);


-------
改

    //TODO: 更新数据
    SQLdb.init("member_check_login").update(json, where: "id = 3",onChanged: (count){
      print("更新数据库:${count}");
    });


-------
查

    //TODO: 查询数据
    SQLdb.init("member_check_login").getList((list){
      print("查询数据:${list}");
    });
                    
       
       
-------
删
                    
    //TODO:删除数据
    SQLdb.init("member_check_login").deleteList(onChanged: (count){
      print("删除数据:${count}");
    });
