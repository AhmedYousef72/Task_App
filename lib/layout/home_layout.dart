import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_app/components/Constants%20.dart';
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
  var formkey = GlobalKey<FormState>();
  bool isBottomSheetShow = false;
  IconData FabIcon = Icons.edit;
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var datecontroller = TextEditingController();

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
      body: tasks.length == 0
          ? Center(child: CircularProgressIndicator())
          : screens[currentindex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isBottomSheetShow) {
            if (formkey.currentState!.validate()) {
              insertToDatabase(
                date: datecontroller.text,
                time: timeController.text,
                title: titleController.text,
              ).then((value) {
                Navigator.pop(context);
                isBottomSheetShow = false;
                setState(() {
                  FabIcon = Icons.edit;
                });
              });
            }
            ;
          } else {
            scaffoldkey.currentState
                ?.showBottomSheet((context) {
                  elevation:
                  20.0;
                  return Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: formkey,
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
                          SizedBox(height: 12),
                          defaultFormField(
                            controller: timeController,
                            type: TextInputType.datetime,
                            label: "Task time",
                            prefix: Icons.watch_later_outlined,
                            onTap: () {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              ).then((value) {
                                timeController.text = value!
                                    .format(context)
                                    .toString();
                              });
                            },
                            validate: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "time must not be empty";
                              }
                              ;
                            },
                          ),
                          SizedBox(height: 12),
                          defaultFormField(
                            controller: datecontroller,
                            type: TextInputType.datetime,
                            label: "Task Date",
                            prefix: Icons.calendar_today,
                            onTap: () {
                              showDatePicker(
                                context: context,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.parse("2025-10-30"),
                              ).then((value) {
                                // print(DateFormat.yMMMd().format(value!));   //  This how to make formating for date to appear inm the screen
                                datecontroller.text = DateFormat.yMMMd()
                                    .format(value!)
                                    .toString();
                              });
                            },
                            validate: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Date must not be empty";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                })
                .closed // I made this to slide the bottomsheet down without an error because if you don't do that it gives error and dosen't change the floating action button icon.
                .then((value) {
                  isBottomSheetShow = false;
                  setState(() {
                    FabIcon = Icons.edit;
                  });
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
    database = await openDatabase(
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
        getDatabase(database).then((value) {
          tasks = value;
        });
        print("Database opened");
      },
    );
  }

  Future insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    return await database.transaction((txn) {
      txn
          .rawInsert(
            "INSERT INTO tasks (title,date,time,status) VALUES('$title','$date','$time','New')",
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

  Future<List<Map>> getDatabase(database) async {
    return await database.rawQuery("SELECT * From tasks");
  }
}
