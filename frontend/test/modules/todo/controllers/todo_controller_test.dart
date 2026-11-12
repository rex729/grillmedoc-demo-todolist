import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/app/data/dtos/todo_dto.dart';
import 'package:frontend/app/data/entities/todo_entity.dart';
import 'package:frontend/app/data/services/todo_api_service.dart';
import 'package:frontend/app/modules/todo/controllers/todo_controller.dart';

class MockTodoApiService extends Mock implements TodoApiService {}

void main() {
  late MockTodoApiService mockApiService;
  late TodoController controller;

  setUp(() {
    mockApiService = MockTodoApiService();
    controller = TodoController(apiService: mockApiService);
  });

  group('TodoController 業務狀態測試', () {
    test('fetchTodos - 成功自 API 獲取待辦清單並預設依到期日升冪排序', () async {
      final mockDtos = [
        const TodoDto(
          id: '1',
          title: '較晚的任務',
          dueDate: '2026-11-20',
          state: 'todo',
          category: 'company',
        ),
        const TodoDto(
          id: '2',
          title: '較早的任務',
          dueDate: '2026-11-10',
          state: 'in progress',
          category: 'personal',
        ),
      ];

      when(() => mockApiService.getTodos()).thenAnswer((_) async => mockDtos);

      await controller.fetchTodos();

      expect(controller.todos.length, 2);
      expect(controller.isLoading.value, false);
      // 預設升冪：2026-11-10 在前，2026-11-20 在後
      expect(controller.sortedTodos[0].id, '2');
      expect(controller.sortedTodos[1].id, '1');
    });

    test('toggleSortOrder - 本地即時切換排序（ASC / DESC），零延遲', () async {
      final mockDtos = [
        const TodoDto(id: '1', title: 'Task A', dueDate: '2026-11-05', state: 'todo', category: 'other'),
        const TodoDto(id: '2', title: 'Task B', dueDate: '2026-11-25', state: 'todo', category: 'other'),
      ];

      when(() => mockApiService.getTodos()).thenAnswer((_) async => mockDtos);
      await controller.fetchTodos();

      // 預設 ASC (由舊到新)
      expect(controller.sortAscending.value, true);
      expect(controller.sortedTodos.first.dueDate, '2026-11-05');

      // 切換為 DESC (由新到舊)
      controller.toggleSortOrder();
      expect(controller.sortAscending.value, false);
      expect(controller.sortedTodos.first.dueDate, '2026-11-25');
    });

    test('addTodo - 成功新增事項並加入列表', () async {
      const createdDto = TodoDto(
        id: 'new_id',
        title: '新建立任務',
        dueDate: '2026-11-15',
        state: 'todo',
        category: 'company',
      );

      when(() => mockApiService.createTodo(any())).thenAnswer((_) async => createdDto);

      final success = await controller.addTodo(
        title: '新建立任務',
        dueDate: '2026-11-15',
        category: TodoCategory.company,
      );

      expect(success, true);
      expect(controller.todos.any((t) => t.id == 'new_id'), true);
    });

    test('cycleTodoState - 推進狀態並呼叫 API 更新', () async {
      final initialTodo = TodoEntity(
        id: '100',
        title: '推進測試',
        dueDate: '2026-11-12',
        state: TodoState.todo,
        category: TodoCategory.personal,
      );
      controller.todos.add(initialTodo);

      final updatedDto = const TodoDto(
        id: '100',
        title: '推進測試',
        dueDate: '2026-11-12',
        state: 'in progress',
        category: 'personal',
      );

      when(() => mockApiService.updateTodo('100', any())).thenAnswer((_) async => updatedDto);

      await controller.cycleTodoState(initialTodo);

      final target = controller.todos.firstWhere((t) => t.id == '100');
      expect(target.state, TodoState.inProgress);
    });

    test('deleteTodo - 呼叫 API 刪除並自本地狀態移除 (ADR-006)', () async {
      final todoToDelete = TodoEntity(
        id: 'del_1',
        title: '將被刪除的任務',
        dueDate: '2026-11-15',
        state: TodoState.todo,
        category: TodoCategory.personal,
      );
      controller.todos.add(todoToDelete);

      when(() => mockApiService.deleteTodo('del_1')).thenAnswer((_) async => {'success': true});

      await controller.deleteTodo('del_1');

      expect(controller.todos.any((t) => t.id == 'del_1'), false);
    });

    test('fetchTodos - API 拋出例外時設定 errorMessage 且 isLoading 為 false', () async {
      when(() => mockApiService.getTodos()).thenThrow(Exception('連線失敗'));

      await controller.fetchTodos();

      expect(controller.errorMessage.value, contains('連線失敗'));
      expect(controller.isLoading.value, false);
      expect(controller.todos.isEmpty, true);
    });
  });
}
