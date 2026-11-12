const test = require('node:test');
const assert = require('node:assert/strict');
const request = require('supertest');
const { createApp } = require('../src/app');

// 建立可注入的 Mock Firestore
function createMockFirestore() {
  const store = new Map(); // key: "users/${uid}/todos/${id}"

  return {
    collection(colName) {
      assert.equal(colName, 'users');
      return {
        doc(uid) {
          return {
            collection(subColName) {
              assert.equal(subColName, 'todos');
              return {
                doc(todoId) {
                  const docKey = `users/${uid}/todos/${todoId}`;
                  return {
                    async get() {
                      const data = store.get(docKey);
                      return {
                        exists: Boolean(data),
                        id: todoId,
                        data: () => data
                      };
                    },
                    async set(data) {
                      store.set(docKey, { ...data, id: todoId });
                    },
                    async update(fields) {
                      const existing = store.get(docKey);
                      if (!existing) {
                        const err = new Error('NOT_FOUND');
                        err.code = 5; // NOT_FOUND
                        throw err;
                      }
                      store.set(docKey, { ...existing, ...fields });
                    },
                    async delete() {
                      store.delete(docKey);
                    }
                  };
                },
                async get() {
                  const prefix = `users/${uid}/todos/`;
                  const docs = [];
                  for (const [key, value] of store.entries()) {
                    if (key.startsWith(prefix)) {
                      docs.push({
                        id: value.id,
                        data: () => value
                      });
                    }
                  }
                  return { docs };
                }
              };
            }
          };
        }
      };
    }
  };
}

const mockAuth = {
  verifyIdToken: async (token) => {
    if (token === 'valid-user-token') {
      return { uid: 'test-user-123', email: 'test@cullio.com' };
    }
    const err = new Error('Invalid token');
    err.code = 'auth/invalid-id-token';
    throw err;
  }
};

test('GET /health - 200 OK without authentication', async () => {
  const app = createApp({ firestore: createMockFirestore(), auth: mockAuth });
  const res = await request(app).get('/health');
  assert.equal(res.status, 200);
  assert.equal(res.body.status, 'ok');
});

test('GET /api/v1/todos - 401 when no token', async () => {
  const app = createApp({ firestore: createMockFirestore(), auth: mockAuth });
  const res = await request(app).get('/api/v1/todos');
  assert.equal(res.status, 401);
});

test('POST /api/v1/todos - 201 Created and persists to Firestore subcollection', async () => {
  const firestore = createMockFirestore();
  const app = createApp({ firestore, auth: mockAuth });

  const payload = {
    title: '撰寫整合測試',
    dueDate: '2026-11-20',
    state: 'in progress',
    category: 'company'
  };

  const res = await request(app)
    .post('/api/v1/todos')
    .set('Authorization', 'Bearer valid-user-token')
    .send(payload);

  assert.equal(res.status, 201);
  assert.ok(res.body.id);
  assert.equal(res.body.title, '撰寫整合測試');
  assert.equal(res.body.dueDate, '2026-11-20');
  assert.equal(res.body.state, 'in progress');
  assert.equal(res.body.category, 'company');
  assert.ok(res.body.createdAt);
  assert.ok(res.body.updatedAt);

  // 驗證 GET 取得剛新增的項目
  const listRes = await request(app)
    .get('/api/v1/todos')
    .set('Authorization', 'Bearer valid-user-token');

  assert.equal(listRes.status, 200);
  assert.equal(listRes.body.length, 1);
  assert.equal(listRes.body[0].id, res.body.id);
});

test('POST /api/v1/todos - 400 Bad Request on empty title', async () => {
  const app = createApp({ firestore: createMockFirestore(), auth: mockAuth });

  const res = await request(app)
    .post('/api/v1/todos')
    .set('Authorization', 'Bearer valid-user-token')
    .send({ title: '', dueDate: '2026-11-20' });

  assert.equal(res.status, 400);
  assert.ok(res.body.errors);
});

test('PUT /api/v1/todos/:id - 200 OK update todo', async () => {
  const app = createApp({ firestore: createMockFirestore(), auth: mockAuth });

  // 先建立一個
  const createRes = await request(app)
    .post('/api/v1/todos')
    .set('Authorization', 'Bearer valid-user-token')
    .send({ title: '原始任務', dueDate: '2026-11-15' });

  const todoId = createRes.body.id;

  // 更新任務
  const updateRes = await request(app)
    .put(`/api/v1/todos/${todoId}`)
    .set('Authorization', 'Bearer valid-user-token')
    .send({
      title: '更新後的任務',
      state: 'done',
      dueDate: '2026-11-18',
      category: 'other'
    });

  assert.equal(updateRes.status, 200);
  assert.equal(updateRes.body.id, todoId);
  assert.equal(updateRes.body.title, '更新後的任務');
  assert.equal(updateRes.body.state, 'done');
  assert.equal(updateRes.body.category, 'other');
});

test('PUT /api/v1/todos/:id - 404 when todo does not exist', async () => {
  const app = createApp({ firestore: createMockFirestore(), auth: mockAuth });

  const res = await request(app)
    .put('/api/v1/todos/non-existent-id')
    .set('Authorization', 'Bearer valid-user-token')
    .send({ title: '任務', dueDate: '2026-11-20' });

  assert.equal(res.status, 404);
});

test('DELETE /api/v1/todos/:id - 200 OK hard delete (ADR-006)', async () => {
  const app = createApp({ firestore: createMockFirestore(), auth: mockAuth });

  const createRes = await request(app)
    .post('/api/v1/todos')
    .set('Authorization', 'Bearer valid-user-token')
    .send({ title: '待刪除任務', dueDate: '2026-11-15' });

  const todoId = createRes.body.id;

  const deleteRes = await request(app)
    .delete(`/api/v1/todos/${todoId}`)
    .set('Authorization', 'Bearer valid-user-token');

  assert.equal(deleteRes.status, 200);
  assert.equal(deleteRes.body.success, true);

  // 驗證已被抹除
  const listRes = await request(app)
    .get('/api/v1/todos')
    .set('Authorization', 'Bearer valid-user-token');

  assert.equal(listRes.body.length, 0);
});
