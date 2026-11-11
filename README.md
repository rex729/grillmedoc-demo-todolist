# GrillMeDoc Demo TodoList — `/grill-me-doc` 規格文檔化深度訪談實戰專案

本專案為展示與實踐 **`/grill-me-doc`（深度設計訪談與規格文件同步持久化技能）**、**唯一真理來源（Single Source of Truth, SSOT）** 與 **TDD（測試驅動開發）** 的跨平台待辦事項（TodoList）系統。

---

## 💡 為什麼需要 `grill-me-doc`？

在傳統開發與 AI 協作中，常見以下痛點：
1. **口頭討論即忘（Ephemeral Sessions）**：在對話視窗中推導了許多架構邊界，但只要開啟新 Session 或切換模型，所有上下文全部遺失。
2. **名詞定義混亂（Glossary Drift）**：前後端對同一欄位或業務實體稱呼不同，導致介面與模型難以對齊。
3. **決策無軌跡（Missing ADRs）**：缺乏架構決策背後的權衡脈絡（Trade-offs），未來的開發者難以理解當初為什麼這樣做。

`grill-me-doc` 透過 `.agents/skills/grill-me-doc/SKILL.md` 建立標準化規範：
* **走訪決策樹（Walk the Design Tree）**：逐層釐清架構相依性與異常邊界，每次聚焦一個關鍵問題並附帶推薦選項 `(Recommended)`。
* **文件即時同步（Docs as Memory）**：
  * **[SPEC.md](./SPEC.md)**：產品規格、使用者流程、**領域術語表 (Glossary)** 與 Gherkin 驗收標準。
  * **[DESIGN.md](./DESIGN.md)**：系統架構、資料模型、RESTful API 與 **架構決策記錄 (ADRs)**。
* **唯一真理來源**：透過 **[AGENTS.md](./AGENTS.md)** 讓所有 AI 代理進入專案時，優先載入規格與架構記憶，達成無縫跨模型交接。

---

## 🛠️ 技術選型與架構核心

* **領域實體 (Entity)**：嚴格維持 4 個核心欄位（`title`、`dueDate: yyyy-mm-dd`、`state: todo/in progress/done`、`category: company/personal/other`）。
* **身分鑑權 (Auth)**：Google Sign-In + Firebase Auth，以 Firebase ID Token 作為無狀態 Bearer Token。
* **資料庫 (Database)**：Cloud Firestore 使用者子集合 `/users/{uid}/todos/{todoId}` 天然隔離，刪除操作採硬刪除（Hard Delete, ADR-006）。
* **前端架構 (Frontend)**：Flutter (Android / iOS) 嚴格遵守 MVC 分層架構（Entity / DTO / Retrofit ApiService / GetX Controller / View）。
* **後端架構 (Backend)**：Node.js + Express RESTful API，搭配 Firebase Admin SDK 進行驗證。

---

## 📂 專案檔案清單

```text
.
├── .agents/
│   └── skills/
│       └── grill-me-doc/
│           ├── SKILL.md             # grill-me-doc 深度訪談與文件化技能定義
│           └── agents/openai.yaml   # Skill 配置元資料
├── AGENTS.md                        # AI 代理協作規範 (TDD 與 Flutter MVC 約束)
├── SPEC.md                          # 功能需求規格書 (含領域術語表 Glossary)
├── DESIGN.md                        # 系統設計書 (含 ADR-001 ~ ADR-006)
├── README.md                        # 專案說明文件
├── google-services.json             # Firebase Android 設定檔 (cullio 專案)
├── GoogleService-Info.plist         # Firebase iOS 設定檔 (cullio 專案)
└── get_sha1.sh                      # 本機 Android Keystore 憑證指紋查詢腳本
```

---

## 📜 架構決策記錄 (ADR 清單)

* **ADR-001**：採用 Google Sign-In 與 Firebase Auth ID Token 無狀態鑑權
* **ADR-002**：前端採用 Flutter MVC + Retrofit + GetX 分層架構
* **ADR-003**：資料庫路徑採用使用者子集合 (`users/{uid}/todos/{todoId}`) 天然隔離
* **ADR-004**：全端實施嚴格 TDD（測試驅動開發）紅綠循環
* **ADR-005**：資料載入維持全量載入前端即時排序，暫不導入分頁
* **ADR-006**：待辦事項刪除機制採用硬刪除（Hard Delete）
