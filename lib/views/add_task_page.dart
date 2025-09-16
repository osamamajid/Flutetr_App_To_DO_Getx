import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/controllers/todo_controller.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  DateTime? _dueDate;

  @override
  Widget build(BuildContext context) {
    final TaskController c = Get.find();

    return Scaffold(
      appBar: AppBar(title: const Text("إضافة مهمة")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: "عنوان المهمة",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _desc,
              decoration: const InputDecoration(
                labelText: "الوصف (اختياري)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dueDate == null
                        ? "لم يتم اختيار تاريخ"
                        : "📅 ${_dueDate!.toLocal().toString().split(' ')[0]}",
                  ),
                ),
                ElevatedButton(
                  child: const Text("اختر تاريخ"),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _dueDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                final title = _title.text.trim();
                final desc = _desc.text.trim();
                if (title.isEmpty) return;
                c.addTask(title, desc.isEmpty ? null : desc, dueDate: _dueDate);
                Get.back();
              },
              icon: const Icon(Icons.save),
              label: const Text("حفظ المهمة"),
            )
          ],
        ),
      ),
    );
  }
}
