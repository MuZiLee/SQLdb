# SQLdb
A package of Flutter sqlite


/*数据库表名*/
final String table;

/*
* 是否创建多列表方式创建数据列表
* 【more】true 此模式的数据表会自动创建一个自增字段"_id"作为数据插入索引。此模式创建的表，当调用【insert】时，旧数据不会被替换
* 【more】false 默认模式。被创建的表会按表传入的json原样进入字段以及类型复制，每一次调用【insert】时，新数据会替换旧数据。
* */
final bool   more;
  

var data = {
  "id": 14,
  "level": "A,B,C,E",
  "mobile": "13800138000",
  "uid": "admin",
  "name": "kkk",
  "step": 2
};
//TODO:初始化自动创建db文件。
SQLdb.init("member_check_login", json: data);


插入数据库
var data = {
  "id": 14,
  "level": "A,B,C,E",
  "mobile": "13800138000",
  "uid": "admin",
  "name": "kkk",
  "step": 2
};
//TODO: 增加数据
SQLdb.init("member_check_login", json: data).insert(data);


var json = {
  "id": 14,
  "level": "",
  "mobile": "13566668888",
  "uid": "更新数据",
  "name": "kkk",
  "step": 2
};
//TODO: 更新数据
SQLdb.init("member_check_login").update(json, where: "id = 3",onChanged: (count){
  print("更新数据库:${count}");
});



//TODO: 查询数据
SQLdb.init("member_check_login").getList((list){
  print("查询数据:${list}");
});
                    
                    
//TODO:删除数据
SQLdb.init("member_check_login").deleteList(onChanged: (count){
  print("删除数据:${count}");
});
