// import 'dart:html';

import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // home: const HomePage(title: 'ToDo'),
      initialRoute: '/',
      routes: {
        //
        '/': (context) => const HomePage(title: 'ToDo'),
        //
        '/edit': (context) => EditPage(),
      }
      );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => ToDo();
}


class ToDo extends State<HomePage> {
  //бд
  void initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  String? _userToDo;
  String? _userToDo_description1;

  // //создание

  @override
  Widget build(BuildContext context) {
  initFirebase();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('todo').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if(!snapshot.hasData) return Text('Нет записей');
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                //удаление свайпаньем влево
                //в key указывается какой именно список будет удален
                return Dismissible(
                  // key: Key(todos[index].toString()),
                  key: Key(snapshot.data!.docs[index].id),
                  //вывод в виде карточки
                  child: Card(
                    //вывод названия
                    child: ListTile(
                      leading: Text(snapshot.data!.docs[index].data()["status"]),
                      title: Text(snapshot.data!.docs[index].data()["todo"]),
                      subtitle: Text(snapshot.data!.docs[index].data()["description"]),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPage(id: snapshot.data!.docs[index].id, todo: snapshot.data!.docs[index].data()["todo"], description:  snapshot.data!.docs[index].data()["description"], status:  snapshot.data!.docs[index].data()["status"]),
                          ),
                        );
                      },

                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_sweep,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          setState(() {
                            FirebaseFirestore.instance.collection('todo').doc(snapshot.data!.docs[index].id)
                                .delete();
                          });
                        },
                      ),
                    ),
                  ),
                  onDismissed: (direction){
                    setState(() {
                      FirebaseFirestore.instance.collection('todo').doc(snapshot.data!.docs[index].id)
                          .delete();
                    });
                  },
                );
              }
          );
        },
      ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () {
            // всплывающее окно
            showDialog(context: context, builder: (BuildContext context) {
              return AlertDialog(
              // return AlertDialog(
                title: Text('Добавить элемент'),
                content: Column(
                  children: <Widget>[
                    TextField(
                    decoration: InputDecoration(
                      labelText: 'name',
                      // }
                    ),
                      onChanged: (String value) {
                        //получение  информации=сохранение информации
                        _userToDo = value;
                      }
                    ),
                    TextField(
                      decoration: InputDecoration(
                      labelText: 'description',
                    ),
                      onChanged: (String value2) {
                        //получение  информации=сохранение информации
                        _userToDo_description1 = value2;
                      }
                    ),
                      ],
                      ),
                //массив кнопок
                actions: [
                  ElevatedButton(onPressed: () {
                    if(_userToDo != null)
                      if(_userToDo_description1 != null && _userToDo != null)
                        if(_userToDo_description1 != "" && _userToDo != "")
                          FirebaseFirestore.instance.collection('todo').add({'todo': _userToDo, 'description': _userToDo_description1, 'status': 'ожидание'});
                          //закрытие окна
                        else
                          AlertDialog(
                            // return AlertDialog(
                            title: Text(''),
                          );
                      else
                        AlertDialog(
                        // return AlertDialog(
                        title: Text(''),
                        );
                    else
                      AlertDialog(
                        // return AlertDialog(
                        title: Text(''),
                      );
                    Navigator.of(context).pop();
                    _userToDo = '';
                    _userToDo_description1 = '';
                  }, child: Text('Добавить'))
                ],
              );
            });
          },
          //вывод иконки
          child: Icon(
            Icons.add_box,
            color: Colors.white,
          ),
      ),
      ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}

class EditPage extends StatefulWidget {
  void initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  EditPage({this.id, this.todo, this.description, this.status});

  final String? id;
  final String? todo;
  final String? description;
  final String? status;
  
  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {

  String? name1;
  String? description1;
  String? name0;
  String? description0;
  String? status0;
  List<String> _locations = ['выполнено', 'ожидание'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Center(
              child: Container(
                color: Colors.black26,
                height: 60.0,
                child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 15.0),
                    child: Text('Редактирование',
                      style: TextStyle(color: Colors.white,fontSize: 18.0),)
                  )
                ],
              ),
              ),
            ),
            Center(
                child: Container(
                  height: 350.0,
                  margin: const EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38),
                  ),
                  child: ListView(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                        border: OutlineInputBorder(),
                          labelText: widget.todo
                        ),
                        onChanged: (String value) {
                        //получение  информации=сохранение информации
                          name0 = value;
                        }

                      ),
                      TextField(
                          decoration: InputDecoration(
                            // labelText: widget.name0,
                              border: OutlineInputBorder(),
                              // key: Key(snapshot.data!.docs[index].id),
                              labelText: widget.description
                          ),
                          onChanged: (String value) {
                            //получение  информации=сохранение информации
                            description0 = value;
                          }
                      ),
                      DropdownButton(
                      hint: Text('Пожалйста выберите статус'), // Not necessary for Option 1
                      value: status0,
                      onChanged: (String? newValue) {
                        setState(() {
                          status0 = newValue;
                        });
                      },
                      items: _locations.map((location) {
                        return DropdownMenuItem(
                          child: new Text(location),
                          value: location,
                        );
                      }).toList(),
                      ),
                    ],
                  )
                )
            ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15.0),
                    child: MaterialButton(
                      color: Colors.blue,
                      onPressed: () {
                        setState(() {
                          print('имя');
                          print(name0);
                          print('описание');
                          print(description0);
                          print('статус');
                          print(status0);
                          print('прошлое');
                          print(widget.todo);
                          print(widget.description);
                          print(widget.status);
                          if (description0 != null && name0 != null &&
                              status0 != null) {
                            print('01');
                            FirebaseFirestore.instance.collection('todo')
                                .doc(widget.id)
                                .update({
                              'todo': name0,
                              'description': description0,
                              'status': status0,
                            });
                          } else {
                            print('02');
                            if (status0 == null) {
                              print('03');
                              if (description0 == null) {
                                print('04');
                                if (name0 == null) {
                                  print('05');
                                  print('Нет изменений');
                                } else {
                                  print('06');
                                  print('Изменнение только название');
                                  FirebaseFirestore.instance.collection('todo')
                                      .doc(widget.id)
                                      .update({
                                    'todo': name0,
                                    'description': widget.description,
                                    'status': widget.status,
                                  });
                                }
                              } else {
                                if (name0 == null) {
                                  print('07');
                                  print('Изменнение только описания');
                                  FirebaseFirestore.instance.collection('todo')
                                      .doc(widget.id)
                                      .update({
                                    'todo': widget.todo,
                                    'description': description0,
                                    'status': widget.status,
                                  });
                                } else {
                                  print('07(1)');
                                  print('Изменнение описания и названия');
                                  FirebaseFirestore.instance.collection('todo')
                                      .doc(widget.id)
                                      .update({
                                    'todo': name0,
                                    'description': description0,
                                    'status': widget.status,
                                  });
                                }
                              }
                            } else {
                              print('08');
                              if (description0 == null) {
                                print('09');
                                if (name0 == null) {
                                  print('10');
                                  print('Изменнение только статуса');
                                  FirebaseFirestore.instance.collection('todo')
                                      .doc(widget.id)
                                      .update({
                                    'todo': widget.todo,
                                    'description': widget.description,
                                    'status': status0,
                                  });
                                } else {
                                  print('11');
                                  print('Изменнение названия и статуса');
                                  FirebaseFirestore.instance.collection('todo')
                                      .doc(widget.id)
                                      .update({
                                    'todo': name0,
                                    'description': widget.description,
                                    'status': status0,
                                  });
                                }
                              } else {
                                //измененный статус, описание
                                print('12');
                                if (name0 == null) {
                                  print('13');
                                  print('Изменнение статуса и описания');
                                  FirebaseFirestore.instance.collection('todo')
                                      .doc(widget.id)
                                      .update({
                                    'todo': widget.todo,
                                    'description': description0,
                                    'status': status0,
                                  });
                                  //   }else{
                                  //     print('14');
                                  //     print('Изменнение статуса и описания и названия');
                                  // }
                                }
                              }
                            }
                          }
                        }
                        );
                      },
                      height: 50.0,
                      minWidth: 150.0,
                      child: Text(
                        "Редактировать",
                        style: TextStyle(color: Colors.white),
                    ),
                    ),
                  ),
                ),
        ]
      )
    );

  }
}

