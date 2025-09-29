import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_app/components/default_form_field.dart';
import 'package:task_app/modules/archived_tasks_screen.dart';
import 'package:task_app/modules/done_tasks_screen.dart';
import 'package:task_app/modules/new_tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentindex = 0;
  late Database database;
  var scaffoldkey = GlobalKey<ScaffoldState>();
  bool isBottomSheetShow = false;
  IconData FabIcon = Icons.edit;
  var titleController = TextEditingController();

  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List<String> titles = ["New Task", "Done Task", "Archive Task"];
  @override
  @override
  void initState() {
    super.initState();
    createDatabase();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(titles[currentindex]),
      ),
      body: Center(child: screens[currentindex]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isBottomSheetShow) {
            Navigator.pop(context);
            isBottomSheetShow = false;
            setState(() {
              FabIcon = Icons.edit;
            });
          } else {
            scaffoldkey.currentState?.showBottomSheet((context) {
              return Container(
                color: Colors.grey[100],
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    defaultFormField(
                      controller: titleController,
                      type: TextInputType.text,
                      label: "Task Title",
                      prefix: Icons.title,
                      validate: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "title must not be empty";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              );
            });
            isBottomSheetShow = true;
            setState(() {
              FabIcon = Icons.add;
            });
          }
        },
        child: Icon(FabIcon),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentindex,
        onTap: (index) {
          setState(() {
            currentindex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_sharp),
            label: "Tasks",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done_outline_rounded),
            label: "Done",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive_outlined),
            label: "Archived",
          ),
        ],
      ),
    );
  }

  void createDatabase() async {
    await openDatabase(
      "todo.db",
      version: 1,
      onCreate: (database, version) {
        print("Database created");
        database
            .execute(
              "Create Table tasks (id  INTEGER PRIMARY KEY,title Text,date Text ,time Text ,status Text)",
            )
            .then((value) {
              print("table created");
            })
            .catchError((error) {
              print('Error when Creating Table ${error.toString()}');
            });
      },
      onOpen: (database) {
        print("Database opened");
      },
    );
  }

  void insertToDatabase() {
    database.transaction((txn) {
      txn
          .rawInsert(
            "INSERT INTO tasks (title,date,time,status) VALUES('First task','02222','8:30','New')",
          )
          .then((value) {
            print("$value inserted Successfuly ");
          })
          .catchError((error) {
            print("Error when Inserting New Record ${error.toString()}");
          });
      return Future.value();
    });
  }
}
