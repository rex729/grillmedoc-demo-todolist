import 'package:get/get.dart';
import '../../../data/entities/todo_entity.dart';
import '../../../data/services/todo_api_service.dart';

class TodoController extends GetxController {
  final TodoApiService apiService;

  TodoController({required this.apiService});

  final todos = <TodoEntity>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  /// true: 由舊到新 (Ascending), false: 由新到舊 (Descending)
  final sortAscending = true.obs;

  List<TodoEntity> get sortedTodos {
    final list = List<TodoEntity>.from(todos);
    list.sort((a, b) {
      final cmp = a.dueDate.compareTo(b.dueDate);
      return sortAscending.value ? cmp : -cmp;
    });
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    fetchTodos();
  }

  void toggleSortOrder() {
    sortAscending.value = !sortAscending.value;
  }

  Future<void> fetchTodos() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final dtos = await apiService.getTodos();
      todos.assignAll(dtos.map((d) => d.toEntity()));
    } catch (e) {
      errorMessage.value = '載入待辦事項失敗: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addTodo({
    required String title,
    required String dueDate,
    TodoCategory category = TodoCategory.personal,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      errorMessage.value = '標題不可為空';
      return false;
    }

    try {
      isLoading.value = true;
      final payload = {
        'title': trimmedTitle,
        'dueDate': dueDate,
        'state': TodoState.todo.value,
        'category': category.value,
      };

      final createdDto = await apiService.createTodo(payload);
      todos.insert(0, createdDto.toEntity());
      return true;
    } catch (e) {
      errorMessage.value = '新增待辦事項失敗: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTodo(TodoEntity todo) async {
    try {
      final payload = {
        'title': todo.title.trim(),
        'dueDate': todo.dueDate,
        'state': todo.state.value,
        'category': todo.category.value,
      };

      final updatedDto = await apiService.updateTodo(todo.id, payload);
      final index = todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        todos[index] = updatedDto.toEntity();
      }
      return true;
    } catch (e) {
      errorMessage.value = '更新待辦事項失敗: $e';
      return false;
    }
  }

  Future<void> cycleTodoState(TodoEntity todo) async {
    final nextTodo = todo.cycleNextState();
    await updateTodo(nextTodo);
  }

  Future<bool> deleteTodo(String id) async {
    try {
      await apiService.deleteTodo(id);
      todos.removeWhere((t) => t.id == id);
      return true;
    } catch (e) {
      errorMessage.value = '刪除待辦事項失敗: $e';
      return false;
    }
  }
}
