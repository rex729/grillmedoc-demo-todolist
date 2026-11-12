import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/data/dtos/todo_dto.dart';
import 'package:frontend/app/data/entities/todo_entity.dart';

void main() {
  group('TodoDto 資料傳輸物件測試', () {
    test('fromJson - 正確由 JSON 反序列化為 TodoDto', () {
      final json = {
        'id': 'todo_abc',
        'title': '準備週會投影片',
        'dueDate': '2026-11-20',
        'state': 'in progress',
        'category': 'company',
        'createdAt': '2026-11-11T16:00:00.000Z',
        'updatedAt': '2026-11-11T16:30:00.000Z',
      };

      final dto = TodoDto.fromJson(json);

      expect(dto.id, 'todo_abc');
      expect(dto.title, '準備週會投影片');
      expect(dto.dueDate, '2026-11-20');
      expect(dto.state, 'in progress');
      expect(dto.category, 'company');
      expect(dto.createdAt, '2026-11-11T16:00:00.000Z');
      expect(dto.updatedAt, '2026-11-11T16:30:00.000Z');
    });

    test('toEntity - 將 TodoDto 轉換為純業務實體 TodoEntity', () {
      final dto = const TodoDto(
        id: 'todo_xyz',
        title: '買牛奶',
        dueDate: '2026-11-15',
        state: 'todo',
        category: 'personal',
        createdAt: '2026-11-11T10:00:00.000Z',
        updatedAt: '2026-11-11T10:00:00.000Z',
      );

      final entity = dto.toEntity();

      expect(entity.id, 'todo_xyz');
      expect(entity.title, '買牛奶');
      expect(entity.dueDate, '2026-11-15');
      expect(entity.state, TodoState.todo);
      expect(entity.category, TodoCategory.personal);
    });

    test('fromEntity - 將 TodoEntity 轉換為 TodoDto', () {
      final entity = TodoEntity(
        id: 'todo_999',
        title: '繳電費',
        dueDate: '2026-11-25',
        state: TodoState.done,
        category: TodoCategory.other,
      );

      final dto = TodoDto.fromEntity(entity);

      expect(dto.id, 'todo_999');
      expect(dto.title, '繳電費');
      expect(dto.dueDate, '2026-11-25');
      expect(dto.state, 'done');
      expect(dto.category, 'other');
    });

    test('toJson - 序列化為後端規格之 JSON Map', () {
      final dto = const TodoDto(
        id: '123',
        title: '測試',
        dueDate: '2026-11-11',
        state: 'todo',
        category: 'company',
      );

      final map = dto.toJson();
      expect(map['title'], '測試');
      expect(map['dueDate'], '2026-11-11');
      expect(map['state'], 'todo');
      expect(map['category'], 'company');
    });
  });
}
