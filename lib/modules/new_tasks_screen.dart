import 'package:flutter/material.dart';
import 'package:task_app/components/Constants%20.dart';
import 'package:task_app/components/task_card.dart';

class NewTasksScreen extends StatelessWidget {
  const NewTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) => buildTaskItem(tasks[index]),
      separatorBuilder: (context, index) =>
          Container(width: double.infinity, height: 1, color: Colors.grey[300]),
      itemCount: tasks.length,
    );
  }
}
