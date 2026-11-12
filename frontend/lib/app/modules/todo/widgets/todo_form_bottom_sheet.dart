import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/entities/todo_entity.dart';

class TodoFormBottomSheet extends StatefulWidget {
  final TodoEntity? existingTodo;
  final Future<bool> Function({
    required String title,
    required String dueDate,
    required TodoCategory category,
    TodoState? state,
  }) onSave;

  const TodoFormBottomSheet({
    super.key,
    this.existingTodo,
    required this.onSave,
  });

  @override
  State<TodoFormBottomSheet> createState() => _TodoFormBottomSheetState();
}

class _TodoFormBottomSheetState extends State<TodoFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late String _selectedDate;
  late TodoCategory _selectedCategory;
  late TodoState _selectedState;
  bool _isSubmitting = false;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    final todo = widget.existingTodo;
    _titleController = TextEditingController(text: todo?.title ?? '');
    _selectedDate = todo?.dueDate ?? _dateFormat.format(DateTime.now());
    _selectedCategory = todo?.category ?? TodoCategory.personal;
    _selectedState = todo?.state ?? TodoState.todo;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initialDate = DateTime.tryParse(_selectedDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = _dateFormat.format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final success = await widget.onSave(
      title: _titleController.text.trim(),
      dueDate: _selectedDate,
      category: _selectedCategory,
      state: _selectedState,
    );
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTodo != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? '編輯待辦事項' : '新增待辦事項',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 任務標題
            TextFormField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '任務標題 (必填)',
                hintText: '例如：完成專案規格審查',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return '標題不可為空';
                }
                if (val.trim().length > 100) {
                  return '標題長度不可超過 100 字元';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // 到期日選擇
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '到期日 (yyyy-mm-dd)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_month),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  _selectedDate,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 分類與狀態選單
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TodoCategory>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: '任務分類',
                      border: OutlineInputBorder(),
                    ),
                    items: TodoCategory.values.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat.label),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCategory = val);
                      }
                    },
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<TodoState>(
                      initialValue: _selectedState,
                      decoration: const InputDecoration(
                        labelText: '進度狀態',
                        border: OutlineInputBorder(),
                      ),
                      items: TodoState.values.map((st) {
                        return DropdownMenuItem(
                          value: st,
                          child: Text(st.label),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedState = val);
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            // 送出按鈕
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _isSubmitting ? '儲存中...' : (isEditing ? '更新事項' : '建立事項'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
