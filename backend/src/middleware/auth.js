/**
 * 建立 Auth 中介軟體工廠函數，方便進行相依性注入與測試 Mock
 */
function createAuthMiddleware(authService) {
  return async function authMiddleware(req, res, next) {
    const authHeader = req.headers.authorization || req.headers.Authorization;

    if (!authHeader || typeof authHeader !== 'string' || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: 'Unauthorized: Missing or malformed Authorization header'
      });
    }

    const token = authHeader.substring(7).trim();
    if (!token) {
      return res.status(401).json({
        error: 'Unauthorized: Missing Bearer token'
      });
    }

    try {
      const decoded = await authService.verifyIdToken(token);
      req.user = decoded;
      next();
    } catch (err) {
      return res.status(401).json({
        error: `Unauthorized: ${err.message || 'Invalid or expired token'}`
      });
    }
  };
}

module.exports = { createAuthMiddleware };
