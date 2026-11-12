enum TodoState {
  todo('todo', '待處理'),
  inProgress('in progress', '進行中'),
  done('done', '已完成');

  final String value;
  final String label;
  const TodoState(this.value, this.label);

  static TodoState fromValue(String value) {
    return TodoState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TodoState.todo,
    );
  }
}

enum TodoCategory {
  company('company', '公事'),
  personal('personal', '私事'),
  other('other', '其他');

  final String value;
  final String label;
  const TodoCategory(this.value, this.label);

  static TodoCategory fromValue(String value) {
    return TodoCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TodoCategory.personal,
    );
  }
}

class TodoEntity {
  final String id;
  final String title;
  final String dueDate;
  final TodoState state;
  final TodoCategory category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TodoEntity({
    required this.id,
    required this.title,
    required this.dueDate,
    this.state = TodoState.todo,
    this.category = TodoCategory.personal,
    this.createdAt,
    this.updatedAt,
  });

  TodoEntity cycleNextState() {
    final nextState = switch (state) {
      TodoState.todo => TodoState.inProgress,
      TodoState.inProgress => TodoState.done,
      TodoState.done => TodoState.todo,
    };
    return copyWith(state: nextState);
  }

  TodoEntity copyWith({
    String? id,
    String? title,
    String? dueDate,
    TodoState? state,
    TodoCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      state: state ?? this.state,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
