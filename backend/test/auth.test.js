const test = require('node:test');
const assert = require('node:assert/strict');
const { createAuthMiddleware } = require('../src/middleware/auth');

test('authMiddleware - reject missing Authorization header', async () => {
  const middleware = createAuthMiddleware({ verifyIdToken: async () => ({ uid: 'user_1' }) });
  let nextCalled = false;
  const req = { headers: {} };
  const res = {
    statusCode: null,
    body: null,
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(data) {
      this.body = data;
      return this;
    }
  };

  await middleware(req, res, () => { nextCalled = true; });

  assert.equal(nextCalled, false);
  assert.equal(res.statusCode, 401);
  assert.equal(res.body.error, 'Unauthorized: Missing or malformed Authorization header');
});

test('authMiddleware - reject non-Bearer schema', async () => {
  const middleware = createAuthMiddleware({ verifyIdToken: async () => ({ uid: 'user_1' }) });
  let nextCalled = false;
  const req = { headers: { authorization: 'Basic 123456' } };
  const res = {
    statusCode: null,
    body: null,
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(data) {
      this.body = data;
      return this;
    }
  };

  await middleware(req, res, () => { nextCalled = true; });

  assert.equal(nextCalled, false);
  assert.equal(res.statusCode, 401);
});

test('authMiddleware - reject invalid/expired token', async () => {
  const mockAuth = {
    verifyIdToken: async () => {
      const err = new Error('Token expired');
      err.code = 'auth/id-token-expired';
      throw err;
    }
  };
  const middleware = createAuthMiddleware(mockAuth);
  let nextCalled = false;
  const req = { headers: { authorization: 'Bearer expired-token' } };
  const res = {
    statusCode: null,
    body: null,
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(data) {
      this.body = data;
      return this;
    }
  };

  await middleware(req, res, () => { nextCalled = true; });

  assert.equal(nextCalled, false);
  assert.equal(res.statusCode, 401);
  assert.ok(res.body.error.includes('Unauthorized'));
});

test('authMiddleware - accept valid token and set req.user', async () => {
  const mockAuth = {
    verifyIdToken: async (token) => {
      if (token === 'valid-token') {
        return { uid: 'user_xyz', email: 'test@example.com' };
      }
      throw new Error('Invalid token');
    }
  };
  const middleware = createAuthMiddleware(mockAuth);
  let nextCalled = false;
  const req = { headers: { authorization: 'Bearer valid-token' } };
  const res = {};

  await middleware(req, res, () => { nextCalled = true; });

  assert.equal(nextCalled, true);
  assert.equal(req.user.uid, 'user_xyz');
  assert.equal(req.user.email, 'test@example.com');
});
