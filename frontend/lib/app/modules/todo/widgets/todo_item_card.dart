import 'package:flutter/material.dart';
import '../../../data/entities/todo_entity.dart';

class TodoItemCard extends StatelessWidget {
  final TodoEntity todo;
  final VoidCallback onStateCycle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TodoItemCard({
    super.key,
    required this.todo,
    required this.onStateCycle,
    required this.onTap,
    required this.onDelete,
  });

  Color _getStateColor(TodoState state) {
    return switch (state) {
      TodoState.todo => Colors.blueGrey,
      TodoState.inProgress => Colors.orange,
      TodoState.done => Colors.green,
    };
  }

  Color _getCategoryColor(TodoCategory category) {
    return switch (category) {
      TodoCategory.company => Colors.indigo,
      TodoCategory.personal => Colors.purple,
      TodoCategory.other => Colors.teal,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDone = todo.state == TodoState.done;

    return Dismissible(
      key: Key('dismiss_${todo.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isDone
              ? BorderSide(color: Colors.green.withValues(alpha: 0.3), width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 狀態循環切換按鈕
                InkWell(
                  onTap: onStateCycle,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      switch (todo.state) {
                        TodoState.todo => Icons.radio_button_unchecked,
                        TodoState.inProgress => Icons.timelapse,
                        TodoState.done => Icons.check_circle,
                      },
                      color: _getStateColor(todo.state),
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 任務主體
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: isDone ? Colors.grey : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // 到期日
                          Icon(
                            Icons.calendar_today,
                            size: 13,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            todo.dueDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // 分類標籤
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(todo.category)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              todo.category.label,
                              style: TextStyle(
                                fontSize: 11,
                                color: _getCategoryColor(todo.category),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // 狀態標籤
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStateColor(todo.state)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              todo.state.label,
                              style: TextStyle(
                                fontSize: 11,
                                color: _getStateColor(todo.state),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 刪除按鈕
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: onDelete,
                  tooltip: '刪除事項 (硬刪除)',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
