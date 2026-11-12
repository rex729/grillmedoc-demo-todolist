import 'package:json_annotation/json_annotation.dart';
import '../entities/todo_entity.dart';

part 'todo_dto.g.dart';

@JsonSerializable()
class TodoDto {
  final String? id;
  final String title;
  final String dueDate;
  final String state;
  final String category;
  final String? createdAt;
  final String? updatedAt;

  const TodoDto({
    this.id,
    required this.title,
    required this.dueDate,
    this.state = 'todo',
    this.category = 'personal',
    this.createdAt,
    this.updatedAt,
  });

  factory TodoDto.fromJson(Map<String, dynamic> json) => _$TodoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TodoDtoToJson(this);

  TodoEntity toEntity() {
    return TodoEntity(
      id: id ?? '',
      title: title,
      dueDate: dueDate,
      state: TodoState.fromValue(state),
      category: TodoCategory.fromValue(category),
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }

  factory TodoDto.fromEntity(TodoEntity entity) {
    return TodoDto(
      id: entity.id.isNotEmpty ? entity.id : null,
      title: entity.title,
      dueDate: entity.dueDate,
      state: entity.state.value,
      category: entity.category.value,
      createdAt: entity.createdAt?.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }
}

@JsonSerializable()
class UpsertTodoDto {
  final String title;
  final String dueDate;
  final String? state;
  final String? category;

  const UpsertTodoDto({
    required this.title,
    required this.dueDate,
    this.state,
    this.category,
  });

  factory UpsertTodoDto.fromJson(Map<String, dynamic> json) => _$UpsertTodoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpsertTodoDtoToJson(this);
}
