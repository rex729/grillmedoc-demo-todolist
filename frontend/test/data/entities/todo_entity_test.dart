import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/data/entities/todo_entity.dart';

void main() {
  group('TodoEntity 領域實體測試', () {
    test('建立 TodoEntity 實體並驗證欄位屬性', () {
      final now = DateTime.now();
      final todo = TodoEntity(
        id: 'todo_123',
        title: '整理系統架構規格',
        dueDate: '2026-11-20',
        state: TodoState.inProgress,
        category: TodoCategory.company,
        createdAt: now,
        updatedAt: now,
      );

      expect(todo.id, 'todo_123');
      expect(todo.title, '整理系統架構規格');
      expect(todo.dueDate, '2026-11-20');
      expect(todo.state, TodoState.inProgress);
      expect(todo.category, TodoCategory.company);
    });

    test('cycleNextState - 狀態依序循環切換 (todo -> inProgress -> done -> todo)', () {
      final todoTodo = TodoEntity(
        id: '1',
        title: '任務 1',
        dueDate: '2026-11-20',
        state: TodoState.todo,
        category: TodoCategory.personal,
      );

      final next1 = todoTodo.cycleNextState();
      expect(next1.state, TodoState.inProgress);

      final next2 = next1.cycleNextState();
      expect(next2.state, TodoState.done);

      final next3 = next2.cycleNextState();
      expect(next3.state, TodoState.todo);
    });

    test('copyWith - 正確替換指定欄位並保留未指定欄位', () {
      final original = TodoEntity(
        id: '1',
        title: '任務 1',
        dueDate: '2026-11-15',
        state: TodoState.todo,
        category: TodoCategory.other,
      );

      final updated = original.copyWith(
        title: '已更新的任務名稱',
        state: TodoState.done,
      );

      expect(updated.id, '1');
      expect(updated.title, '已更新的任務名稱');
      expect(updated.dueDate, '2026-11-15');
      expect(updated.state, TodoState.done);
      expect(updated.category, TodoCategory.other);
    });
  });
}
