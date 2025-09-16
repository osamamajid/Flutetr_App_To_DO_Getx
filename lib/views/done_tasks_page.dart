import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/controllers/todo_controller.dart';

class DoneTasksPage extends StatelessWidget {
  const DoneTasksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TaskController c = Get.find();

    final doneTasks = c.tasks.where((t) => t.done).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("المهام المنجزة")),
      body: doneTasks.isEmpty
          ? const Center(child: Text("لا توجد مهام منجزة ✅"))
          : ListView.builder(
        itemCount: doneTasks.length,
        itemBuilder: (_, i) {
          final t = doneTasks[i];
          return Card(
            color: Colors.grey.shade300,
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(
                t.title,
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              subtitle: t.description != null ? Text(t.description!) : null,
            ),
          );
        },
      ),
    );
  }
}
