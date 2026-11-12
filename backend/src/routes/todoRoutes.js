const { Router } = require('express');
const crypto = require('node:crypto');
const { validateTodoPayload } = require('../models/todoValidator');

function createTodoRoutes(firestore) {
  const router = Router();

  // 取得使用者 todos 集合參照: /users/{uid}/todos
  function getUserTodosCollection(uid) {
    return firestore.collection('users').doc(uid).collection('todos');
  }

  // GET /api/v1/todos - 取得使用者所有待辦事項
  router.get('/', async (req, res, next) => {
    try {
      const snapshot = await getUserTodosCollection(req.user.uid).get();
      const todos = snapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          ...data
        };
      });
      res.status(200).json(todos);
    } catch (err) {
      next(err);
    }
  });

  // POST /api/v1/todos - 新增待辦事項
  router.post('/', async (req, res, next) => {
    try {
      const validation = validateTodoPayload(req.body || {}, false);
      if (!validation.isValid) {
        return res.status(400).json({ errors: validation.errors });
      }

      const todoId = `todo_${crypto.randomUUID()}`;
      const nowIso = new Date().toISOString();

      const newTodo = {
        id: todoId,
        title: validation.sanitized.title,
        dueDate: validation.sanitized.dueDate,
        state: validation.sanitized.state,
        category: validation.sanitized.category,
        createdAt: nowIso,
        updatedAt: nowIso
      };

      await getUserTodosCollection(req.user.uid).doc(todoId).set(newTodo);
      res.status(201).json(newTodo);
    } catch (err) {
      next(err);
    }
  });

  // PUT /api/v1/todos/:id - 更新待辦事項
  router.put('/:id', async (req, res, next) => {
    try {
      const { id } = req.params;
      const validation = validateTodoPayload(req.body || {}, true);
      if (!validation.isValid) {
        return res.status(400).json({ errors: validation.errors });
      }

      const docRef = getUserTodosCollection(req.user.uid).doc(id);
      const docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        return res.status(404).json({ error: `Todo with ID ${id} not found` });
      }

      const nowIso = new Date().toISOString();
      const updatedFields = {
        ...validation.sanitized,
        updatedAt: nowIso
      };

      await docRef.update(updatedFields);

      const updatedDoc = await docRef.get();
      res.status(200).json({
        id,
        ...updatedDoc.data()
      });
    } catch (err) {
      if (err.code === 5) { // Firestore NOT_FOUND
        return res.status(404).json({ error: `Todo with ID ${req.params.id} not found` });
      }
      next(err);
    }
  });

  // DELETE /api/v1/todos/:id - 刪除待辦事項 (ADR-006 硬刪除)
  router.delete('/:id', async (req, res, next) => {
    try {
      const { id } = req.params;
      const docRef = getUserTodosCollection(req.user.uid).doc(id);
      await docRef.delete();
      res.status(200).json({ success: true, message: `Todo ${id} deleted successfully` });
    } catch (err) {
      next(err);
    }
  });

  return router;
}

module.exports = { createTodoRoutes };
