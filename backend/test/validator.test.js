const test = require('node:test');
const assert = require('node:assert/strict');
const { validateTodoPayload } = require('../src/models/todoValidator');

test('validateTodoPayload - valid payload', () => {
  const payload = {
    title: '完成架構設計規格',
    dueDate: '2026-11-20',
    state: 'in progress',
    category: 'company'
  };

  const result = validateTodoPayload(payload);
  assert.equal(result.isValid, true);
  assert.equal(result.errors.length, 0);
  assert.equal(result.sanitized.title, '完成架構設計規格');
  assert.equal(result.sanitized.dueDate, '2026-11-20');
  assert.equal(result.sanitized.state, 'in progress');
  assert.equal(result.sanitized.category, 'company');
});

test('validateTodoPayload - applies default values', () => {
  const payload = {
    title: '填寫日報',
    dueDate: '2026-11-15'
  };

  const result = validateTodoPayload(payload);
  assert.equal(result.isValid, true);
  assert.equal(result.sanitized.state, 'todo');
  assert.equal(result.sanitized.category, 'personal');
});

test('validateTodoPayload - invalid empty title', () => {
  const result = validateTodoPayload({
    title: '   ',
    dueDate: '2026-11-15'
  });

  assert.equal(result.isValid, false);
  assert.ok(result.errors.some(e => e.includes('title')));
});

test('validateTodoPayload - title length > 100', () => {
  const result = validateTodoPayload({
    title: 'a'.repeat(101),
    dueDate: '2026-11-15'
  });

  assert.equal(result.isValid, false);
  assert.ok(result.errors.some(e => e.includes('title')));
});

test('validateTodoPayload - invalid dueDate format', () => {
  const result = validateTodoPayload({
    title: '測試任務',
    dueDate: '2026/11/15'
  });

  assert.equal(result.isValid, false);
  assert.ok(result.errors.some(e => e.includes('dueDate')));
});

test('validateTodoPayload - invalid calendar date (2026-02-29 is non-leap year)', () => {
  const result = validateTodoPayload({
    title: '閏年測試',
    dueDate: '2026-02-29'
  });

  assert.equal(result.isValid, false);
  assert.ok(result.errors.some(e => e.includes('dueDate')));
});

test('validateTodoPayload - invalid state', () => {
  const result = validateTodoPayload({
    title: '狀態測試',
    dueDate: '2026-11-15',
    state: 'blocked'
  });

  assert.equal(result.isValid, false);
  assert.ok(result.errors.some(e => e.includes('state')));
});

test('validateTodoPayload - invalid category', () => {
  const result = validateTodoPayload({
    title: '分類測試',
    dueDate: '2026-11-15',
    category: 'urgent'
  });

  assert.equal(result.isValid, false);
  assert.ok(result.errors.some(e => e.includes('category')));
});
