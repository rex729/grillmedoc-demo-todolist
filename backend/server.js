const { createApp } = require('./src/app');

// 遵循 ADR-007: 預設監聽 Port 1734 避開 Jenkins 8080
const PORT = process.env.PORT || 1734;

const app = createApp();

app.listen(PORT, () => {
  console.log(`[GrillMeDoc Backend] 伺服器正在 Port ${PORT} 上運行... (http://localhost:${PORT})`);
  console.log(`[GrillMeDoc Backend] 健康檢查: http://localhost:${PORT}/health`);
});
