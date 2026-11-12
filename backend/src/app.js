const express = require('express');
const cors = require('cors');
const { createAuthMiddleware } = require('./middleware/auth');
const { createTodoRoutes } = require('./routes/todoRoutes');
const { initFirebase } = require('./config/firebase');

function createApp(services = {}) {
  let authService = services.auth;
  let firestoreService = services.firestore;

  if (!authService || !firestoreService) {
    const fb = initFirebase();
    authService = authService || fb.auth;
    firestoreService = firestoreService || fb.firestore;
  }

  const app = express();

  app.use(cors());
  app.use(express.json());

  // 免驗證健康檢查
  app.get('/health', (req, res) => {
    res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
  });

  // 受保護的待辦事項 API
  const authMiddleware = createAuthMiddleware(authService);
  const todoRoutes = createTodoRoutes(firestoreService);
  app.use('/api/v1/todos', authMiddleware, todoRoutes);

  // 全域錯誤處理
  app.use((err, req, res, next) => {
    console.error('[API Error]:', err);
    res.status(500).json({
      error: 'Internal Server Error',
      message: err.message
    });
  });

  return app;
}

module.exports = { createApp };
