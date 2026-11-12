import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/entities/todo_entity.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/todo_controller.dart';
import '../widgets/todo_form_bottom_sheet.dart';
import '../widgets/todo_item_card.dart';

class TodoView extends GetView<TodoController> {
  const TodoView({super.key});

  void _openAddModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TodoFormBottomSheet(
        onSave: ({required title, required dueDate, required category, state}) async {
          return await controller.addTodo(
            title: title,
            dueDate: dueDate,
            category: category,
          );
        },
      ),
    );
  }

  void _openEditModal(BuildContext context, TodoEntity todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TodoFormBottomSheet(
        existingTodo: todo,
        onSave: ({required title, required dueDate, required category, state}) async {
          final updated = todo.copyWith(
            title: title,
            dueDate: dueDate,
            category: category,
            state: state,
          );
          return await controller.updateTodo(updated);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的待辦事項', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // 到期日排序切換按鈕 (Ascending / Descending)
          Obx(() {
            final isAsc = controller.sortAscending.value;
            return IconButton(
              icon: Icon(isAsc ? Icons.arrow_upward : Icons.arrow_downward),
              tooltip: isAsc ? '依到期日：由舊到新 (點擊切換由新到舊)' : '依到期日：由新到舊 (點擊切換由舊到新)',
              onPressed: () => controller.toggleSortOrder(),
            );
          }),
          // 重新整理
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '重新整理',
            onPressed: () => controller.fetchTodos(),
          ),
          // 登出按鈕
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            tooltip: '使用者帳號',
            onSelected: (val) {
              if (val == 'logout') {
                authController.signOut();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  authController.userName.value.isNotEmpty
                      ? authController.userName.value
                      : '使用者',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('登出', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.todos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // 錯誤狀態處理（連線中斷或伺服器未開啟）
        if (controller.errorMessage.value.isNotEmpty && controller.todos.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 80,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '資料載入失敗',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => controller.fetchTodos(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('重新整理 / 重試'),
                  ),
                ],
              ),
            ),
          );
        }

        final sorted = controller.sortedTodos;

        // 空狀態處理 (SPEC.md Section 7)
        if (sorted.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '尚未建立待辦事項',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '點擊右下角 + 開始記錄你的第一個待辦任務！',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchTodos(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final todo = sorted[index];
              return TodoItemCard(
                todo: todo,
                onTap: () => _openEditModal(context, todo),
                onStateCycle: () => controller.cycleTodoState(todo),
                onDelete: () => controller.deleteTodo(todo.id),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddModal(context),
        icon: const Icon(Icons.add),
        label: const Text('新增事項'),
      ),
    );
  }
}
