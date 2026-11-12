const admin = require('firebase-admin');
const fs = require('node:fs');
const path = require('node:path');

let initialized = false;

function initFirebase() {
  if (initialized) {
    return {
      auth: admin.auth(),
      firestore: admin.firestore()
    };
  }

  const candidateKeyPaths = [
    process.env.GOOGLE_APPLICATION_CREDENTIALS,
    path.resolve(__dirname, '../../../config/serviceAccountKey.json'),
    path.resolve(process.cwd(), 'config/serviceAccountKey.json'),
    path.resolve(process.cwd(), '../config/serviceAccountKey.json'),
    path.resolve(__dirname, '../../config/serviceAccountKey.json'),
    path.resolve(__dirname, '../serviceAccountKey.json'),
    path.resolve(__dirname, '../../backend/serviceAccountKey.json')
  ].filter(Boolean);

  let credential;
  for (const keyPath of candidateKeyPaths) {
    if (fs.existsSync(keyPath)) {
      try {
        const serviceAccount = JSON.parse(fs.readFileSync(keyPath, 'utf8'));
        credential = admin.credential.cert(serviceAccount);
        console.log(`[Firebase] 成功載入服務帳戶金鑰: ${keyPath}`);
        break;
      } catch (err) {
        console.warn(`[Firebase] 無法讀取金鑰 ${keyPath}:`, err.message);
      }
    }
  }

  if (!credential) {
    console.warn('[Firebase] 未找到 serviceAccountKey.json，改用 Application Default Credentials');
    credential = admin.credential.applicationDefault();
  }

  admin.initializeApp({
    credential,
    projectId: 'cullio'
  });

  initialized = true;
  return {
    auth: admin.auth(),
    firestore: admin.firestore()
  };
}

module.exports = { initFirebase };
