import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/controllers/todo_controller.dart';
import 'package:todo/views/add_task_page.dart';
import 'package:todo/views/done_tasks_page.dart';
import 'package:todo/models/todo.dart'; // Ensure this path is correct

class TodoPage extends StatelessWidget {
  const TodoPage({Key? key}) : super(key: key);

  // تحديد لون المهمة حسب الحالة
  Color _getTaskColor(DateTime? dueDate, bool done) {
    if (done) return Colors.grey.shade400;
    if (dueDate == null) return Colors.green.shade300; // Default if no due date
    final now = DateTime.now();
    // Normalize dates to compare only the date part, ignoring time
    final normalizedDueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final normalizedNow = DateTime(now.year, now.month, now.day);

    if (normalizedDueDate.isBefore(normalizedNow)) return Colors.red.shade300; // متأخرة
    if (normalizedDueDate.difference(normalizedNow).inDays <= 1 && normalizedDueDate.isAfter(normalizedNow.subtract(const Duration(days:1)))) { // قريبة (اليوم أو غداً)
      return Colors.orange.shade300;
    }
    return Colors.green.shade300; // عادية (في المستقبل)
  }

  // Dialog لتعديل المهمة
  void _showEditDialog(Task task) {
    final TaskController c = Get.find();
    final titleCtrl = TextEditingController(text: task.title);
    final descCtrl = TextEditingController(text: task.description ?? ''); // Handle null description

    // Make selectedDate an Rx variable to make the Text widget reactive
    final Rx<DateTime?> selectedDate = (task.dueDate).obs;
    // Make doneState an Rx variable to make the Checkbox reactive AND
    // to hold the temporary state within the dialog before saving.
    final RxBool doneState = (task.done).obs;

    Get.defaultDialog(
      title: "تعديل المهمة",
      contentPadding: const EdgeInsets.all(16),
      titlePadding: const EdgeInsets.all(16).copyWith(bottom: 8),
      content: SingleChildScrollView( // Added SingleChildScrollView for very long descriptions
        child: Column(
          mainAxisSize: MainAxisSize.min, // CRUCIAL for Column in Dialog
          children: [
            TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "العنوان")),
            const SizedBox(height: 8),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: "الوصف"),
              maxLines: null, // Allows multiline for description
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(() => Text(selectedDate.value == null
                      ? "لم يتم اختيار تاريخ"
                      : "📅 ${selectedDate.value!.toLocal().toString().split(' ')[0]}")),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  child: const Text("اختر تاريخ"),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: Get.context!, // Get.context should be valid here
                      initialDate: selectedDate.value ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      selectedDate.value = picked;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("تم الإنجاز؟"),
                const Spacer(), // Pushes the Checkbox to the right
                Obx(() => Checkbox(
                  value: doneState.value,
                  onChanged: (val) {
                    doneState.value = val ?? false;
                  },
                )),
              ],
            ),
          ],
        ),
      ),
      textConfirm: "حفظ",
      confirmTextColor: Colors.white, // Optional: for better visibility
      onConfirm: () {
        c.updateTask(
          task.id,
          title: titleCtrl.text.trim(),
          description: descCtrl.text.trim(),
          dueDate: selectedDate.value,
          done: doneState.value,
        );
        Get.back();
      },
      textCancel: "إلغاء",
      cancelTextColor: Theme.of(Get.context!).textTheme.bodyLarge?.color, // Optional
      onCancel: () {
        // Default behavior is Get.back(), so usually no explicit action needed
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // It's good practice to initialize the controller here if it's specific to this page
    // or ensure it's initialized globally (e.g., in main.dart) if shared.
    // For this example, assuming it's initialized globally as per previous discussion.
    final TaskController c = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة المهام'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_done_outlined), // Slightly different icon
            tooltip: "المهام المنجزة",
            onPressed: () => Get.to(() => const DoneTasksPage()),
          ),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value && c.tasks.isEmpty) { // Added loading check
          return const Center(child: CircularProgressIndicator());
        }
        if (c.tasks.isEmpty) {
          return const Center(
              child: Text(
                "لا توجد مهام بعد ✨\nقم بإضافة مهمة جديدة!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ));
        }
        // Filter out done tasks from the main list if you only want to show pending ones
        // final pendingTasks = c.tasks.where((task) => !task.done).toList();
        // If you want to show all tasks (pending and done) then just use c.tasks

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          // itemCount: pendingTasks.length, // Use this if filtering
          itemCount: c.tasks.length, // Shows all tasks from controller
          itemBuilder: (_, i) {
            // final t = pendingTasks[i]; // Use this if filtering
            final t = c.tasks[i];
            return Card(
              elevation: 2.0,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              color: _getTaskColor(t.dueDate, t.done),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                leading: Checkbox(
                  value: t.done,
                  onChanged: (val) => c.toggleDone(t.id),
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                ),
                title: Text(
                  t.title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    decoration: t.done ? TextDecoration.lineThrough : TextDecoration.none,
                    color: t.done ? Colors.black54 : Colors.black87,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (t.description != null && t.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          t.description!,
                          style: TextStyle(
                            color: t.done ? Colors.black45 : Colors.black54,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (t.dueDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          "📅 ${t.dueDate!.toLocal().toString().split(' ')[0]}",
                          style: TextStyle(
                            color: t.done ? Colors.black45 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: "تعديل",
                      onPressed: () => _showEditDialog(t),
                      color: Colors.blueGrey.shade700,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: "حذف",
                      onPressed: () {
                        Get.defaultDialog(
                            title: "تأكيد الحذف",
                            middleText: "هل أنت متأكد أنك تريد حذف هذه المهمة؟\n\"${t.title}\"",
                            textConfirm: "حذف",
                            textCancel: "إلغاء",
                            confirmTextColor: Colors.white,
                            buttonColor: Colors.red,
                            onConfirm: () {
                              c.deleteTask(t.id);
                              Get.back(); // Close the confirmation dialog
                            }
                        );
                      },
                      color: Colors.red.shade700,
                    ),
                  ],
                ),
                onTap: () => _showEditDialog(t), // Allow tapping the whole ListTile to edit
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("إضافة مهمة"),
        onPressed: () => Get.to(() => const AddTaskPage()),
        tooltip: "إضافة مهمة جديدة",
      ),
    );
  }
}
