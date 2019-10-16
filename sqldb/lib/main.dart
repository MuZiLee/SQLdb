import 'package:flutter/material.dart';
import 'SQLdb/SQLdb.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text("SQLdb"),
          ),
          body: Center(
            child: Column(
              children: <Widget>[

                RaisedButton(
                  child: Text("增加数据"),
                  onPressed: () {
                    var data = {
                      "id": 14,
                      "level": "A,B,C,E",
                      "mobile": "13800138000",
                      "uid": "admin",
                      "name": "kkk",
                      "step": 2
                    };
                    //TODO: 增加数据
                    SQLdb.init("member_check_login2", json: data).insert(data);
                    print("增加数据");
                  },
                ),
                RaisedButton(
                  child: Text("更新数据"),
                  onPressed: () {

                    var json = {
                      "id": 14,
                      "level": "",
                      "mobile": "13566668888",
                      "uid": "更新数据",
                      "name": "kkk",
                      "step": 2
                    };
                    //TODO: 更新数据
                    SQLdb.init("member_check_login").update(json, where: "_id = 3",onChanged: (count){
                      print("更新数据库:${count}");
                    });
                  },
                ),
                RaisedButton(
                  child: Text("查询数据"),
                  onPressed: () {

                    //TODO: 查询数据
                    SQLdb.init("member_check_login").getList((list){
                      print("查询数据:${list}");
                    });
                  },
                ),
                RaisedButton(
                  child: Text("删除数据"),
                  onPressed: () {
                    SQLdb.init("member_check_login").deleteList(onChanged: (count){

                      print("删除数据:${count}");
                    });
                  },
                ),

                RaisedButton(
                  child: Text("查询所有表"),
                  onPressed: () {
                    SQLdb.init("member_check_login").getTableAll(onChanged: (map){

                      print(map);

                    });
                  },
                ),

                RaisedButton(
                  child: Text("查询某表是否存在"),
                  onPressed: () {
                    SQLdb.init("member_check_login").queryTable(onChanged: (map){

                      print(map);

                    });
                  },
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
