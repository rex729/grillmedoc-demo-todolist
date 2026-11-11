---
name: grill-me-doc
description: >-
  當使用者想要針對計畫、規格或架構進行深度訪談（Relentless Interview），並在訪談過程中持續更新與產出專案規格文件（如 SPEC.md、DESIGN.md、ADR、領域名詞表）時使用此技能。
---

# Grill Me Doc（深度訪談與規格文檔化）

對使用者的計畫、系統架構或需求規格進行全方位、深度且無死角的訪談（Relentless Interview），在釐清決策的同時，主動且持續地將共識寫入專案文件（`SPEC.md`、`DESIGN.md` 等），確保架構嚴謹且進度持久化。

---

## 核心執行原則

1. **先查閱後提問（Explore Before Asking）**：
   * 在提出問題前，主動檢查專案現有程式碼與規格文件（如 `SPEC.md`、`DESIGN.md`、`README.md` 等）。
   * 能夠從專案現況獲取的事實（Facts）直接查閱確認，不重複向使用者提問。

2. **走訪決策樹（Walk the Decision Tree）**：
   * 將龐大模糊的需求拆解為系統化的決策樹，依架構層次、相依性逐步推進，徹底探討邊界條件（Edge Cases）與異常情境。

3. **一次只問一個核心問題（One Question at a Time）**：
   * 每次僅聚焦一個關鍵決策，避免一次拋出大量問題造成認知負擔。
   * 若支援選擇題互動（如 `ask_question` 工具），優先使用結構化選項呈現。

4. **主動提供推薦答案（Provide Recommended Answer）**：
   * 提問時必須附帶具有技術依據的建議選項（標註 `(Recommended)`）與簡短理由，協助使用者快速評估決策。

5. **達成共識前禁止寫實作程式碼（No Code Until Consensus）**：
   * 在關鍵架構分支、資料模型、介面定義與邊界規則達成完全共識前，嚴禁盲目進入程式碼撰寫。

6. **文檔化持續同步（Sync & Persist to Docs）**：
   * 訪談過程中或每當達成階段性共識時，主動建立或更新根目錄的規格文件：
     - **`SPEC.md`**：記錄產品需求、使用者流程、功能清單、邊界條件與驗收標準。
     - **`DESIGN.md`**：記錄系統架構、技術選型、領域模型（Domain Entities / DTOs）、資料庫結構、API 規格與架構決策記錄（ADR）。
     - **領域詞彙（Glossary）**：統一定義專案核心術語，避免認知分歧。
   * 所有文件內容皆以**繁體中文**撰寫，保持排版規範與清晰層次。
