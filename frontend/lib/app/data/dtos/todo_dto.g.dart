part of 'todo_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodoDto _$TodoDtoFromJson(Map<String, dynamic> json) => TodoDto(
      id: json['id'] as String?,
      title: json['title'] as String,
      dueDate: json['dueDate'] as String,
      state: json['state'] as String? ?? 'todo',
      category: json['category'] as String? ?? 'personal',
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$TodoDtoToJson(TodoDto instance) => <String, dynamic>{
      if (instance.id != null) 'id': instance.id,
      'title': instance.title,
      'dueDate': instance.dueDate,
      'state': instance.state,
      'category': instance.category,
      if (instance.createdAt != null) 'createdAt': instance.createdAt,
      if (instance.updatedAt != null) 'updatedAt': instance.updatedAt,
    };

UpsertTodoDto _$UpsertTodoDtoFromJson(Map<String, dynamic> json) => UpsertTodoDto(
      title: json['title'] as String,
      dueDate: json['dueDate'] as String,
      state: json['state'] as String?,
      category: json['category'] as String?,
    );

Map<String, dynamic> _$UpsertTodoDtoToJson(UpsertTodoDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'dueDate': instance.dueDate,
      if (instance.state != null) 'state': instance.state,
      if (instance.category != null) 'category': instance.category,
    };
