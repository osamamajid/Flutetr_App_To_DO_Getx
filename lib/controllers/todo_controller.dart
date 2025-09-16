import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:todo/models/todo.dart'; // Ensure your Task model has fromMap and toMap

class TaskController extends GetxController {
  static const _storageKey = 'tasks';
  final GetStorage _box = GetStorage();
  final tasks = <Task>[].obs;

  // Add the isLoading RxBool variable
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTasks(); // Load tasks when the controller is initialized
  }

  Future<void> _loadTasks() async {
    isLoading.value = true;
    try {
      // It's good practice to make storage operations potentially async
      // even if GetStorage is mostly synchronous, for future-proofing
      // or if you switch to an async storage.
      await Future.delayed(Duration.zero); // Ensures the method is treated as async

      final raw = _box.read<String>(_storageKey); // Specify type for read
      if (raw != null && raw.isNotEmpty) {
        final List list = jsonDecode(raw);
        tasks.assignAll(
          list.map((e) => Task.fromMap(Map<String, dynamic>.from(e))),
        );
      } else {
        tasks.assignAll([]); // Ensure tasks is empty if nothing is loaded
      }
    } catch (e) {
      Get.snackbar("Error Loading Tasks", e.toString(), snackPosition: SnackPosition.BOTTOM);
      tasks.assignAll([]); // Clear tasks on error to avoid inconsistent state
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveTasks() async {
    // Making save potentially async as well
    isLoading.value = true; // Optionally show loading during save
    try {
      await Future.delayed(Duration.zero);
      final data = jsonEncode(tasks.map((t) => t.toMap()).toList());
      await _box.write(_storageKey, data); // Make write awaitable
    } catch (e) {
      Get.snackbar("Error Saving Tasks", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      // Decide if you want isLoading to be true for the whole save duration
      // or just for the UI update part. For simplicity, setting it false here.
      // If saving is very quick, users might not even see the loader.
      isLoading.value = false;
    }
  }

  /// إضافة مهمة جديدة
  Future<void> addTask(String title, String? s, {String? description, DateTime? dueDate}) async {
    // The 's' parameter seems unused, consider removing if not needed.
    isLoading.value = true; // Show loading
    try {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Consider UUID for more robust IDs
        title: title,
        description: description,
        dueDate: dueDate,
        // done is false by default in your Task model constructor, ensure this
      );
      tasks.insert(0, task);
      await _saveTasks(); // Now awaits the save operation
    } catch (e) {
      Get.snackbar("Error Adding Task", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false; // Hide loading
    }
  }

  /// تعديل المهمة
  Future<void> updateTask(
      String id, {
        String? title,
        String? description,
        DateTime? dueDate,
        bool? done,
      }) async {
    isLoading.value = true;
    try {
      final index = tasks.indexWhere((t) => t.id == id);
      if (index == -1) {
        Get.snackbar("Error", "Task not found for update.", snackPosition: SnackPosition.BOTTOM);
        isLoading.value = false;
        return;
      }
      final old = tasks[index];
      tasks[index] = Task(
        id: old.id,
        title: title ?? old.title,
        description: description ?? old.description,
        dueDate: dueDate ?? old.dueDate,
        done: done ?? old.done,
      );
      // tasks.refresh(); // Not strictly needed here as we are replacing the item.
      await _saveTasks();
    } catch (e) {
      Get.snackbar("Error Updating Task", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// تغيير حالة الإنجاز
  Future<void> toggleDone(String id) async {
    isLoading.value = true;
    try {
      final index = tasks.indexWhere((t) => t.id == id);
      if (index == -1) {
        Get.snackbar("Error", "Task not found for toggle.", snackPosition: SnackPosition.BOTTOM);
        isLoading.value = false;
        return;
      }
      final task = tasks[index];
      // Create a new instance for the list to react properly
      tasks[index] = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        done: !task.done,
      );
      // tasks.refresh(); // Not strictly needed here as we are replacing the item.
      await _saveTasks();
    } catch (e) {
      Get.snackbar("Error Toggling Task", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// حذف مهمة
  Future<void> deleteTask(String id) async {
    isLoading.value = true;
    try {
      final initialLength = tasks.length;
      tasks.removeWhere((t) => t.id == id);
      if (tasks.length < initialLength) { // Check if deletion actually happened
        await _saveTasks();
      } else {
        Get.snackbar("Info", "Task not found for deletion.", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error Deleting Task", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// جلب المهام المنجزة
  List<Task> get completedTasks => tasks.where((t) => t.done).toList();

  /// جلب المهام غير المنجزة
  List<Task> get pendingTasks => tasks.where((t) => !t.done).toList();
}

