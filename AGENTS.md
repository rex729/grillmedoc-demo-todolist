# 專案 AI 代理協作規範 (AGENTS.md)

本檔案為跨模型與跨工具通用的專案導覽與核心規則。所有 AI 代理在進入本專案時皆須遵守以下規範。

---

## 1. 核心上下文檔案（記憶持久化與唯一真理來源）

在進行任何規劃、討論或撰寫程式碼之前，請先檢查並閱讀專案根目錄下的以下檔案：

* **`SPEC.md`（功能與需求規格書）**：記錄產品需求、**領域術語表 (Glossary)**、使用者流程、驗收標準（AC）與邊界條件。
* **`DESIGN.md`（系統架構與技術設計書）**：記錄系統架構、技術選型、資料模型、API 介面定義與**架構決策記錄 (ADRs)**。

---

## 2. 深度訪談與規格文檔化（`grill-me-doc`）規則

當與使用者進行需求釐清、架構討論或執行 `/grill-me-doc` 時：
1. **先查後問（Explore Before Asking）**：能從專案現有檔案得知的資訊，請自行查閱，切勿重複詢問使用者。
2. **逐題推進**：沿著設計決策樹每次詢問一個核心問題，並提供推薦答案（標註 `(Recommended)`）。
3. **自動文檔化同步**：當訪談達成階段性共識時，主動更新 `SPEC.md`、`DESIGN.md`、領域名詞表與 ADR。
4. **全繁體中文**：所有產出文件均以繁體中文撰寫。

---

## 3. 測試驅動開發（TDD）強制規範

本專案所有前後端功能開發與修改皆**必須嚴格遵循 TDD 流程**：
1. **Red（先寫失敗測試）**：在撰寫任何功能實作程式碼前，必須根據 `SPEC.md` 與 `DESIGN.md` 先撰寫測試，並實際執行確認其失敗（Red）。
2. **Green（撰寫最小可行實作）**：撰寫剛好能通過測試的程式碼，並實際執行確認全數通過（Green）。
3. **Refactor（重構）**：在確保測試持續通過的前提下進行程式碼重構與清理。
4. **禁止未測先寫**：嚴禁跳過測試直接產生業務邏輯程式碼。

---

## 4. Flutter 前端分層架構強制規範 (MVC + Entity / DTO / Retrofit)

前端 Flutter (`frontend/`) 必須嚴格遵守 **MVC 分層架構**：
1. **Entity (`lib/app/data/entities/`)**：純領域模型（Domain Entity），僅包含業務屬性與領域邏輯，不耦合網路傳輸格式。
2. **DTO (`lib/app/data/dtos/`)**：資料傳輸物件（Data Transfer Object），負責 JSON 序列化/反序列化，並提供 `toEntity()` 與 `fromEntity()` 轉換方法。
3. **API Service (`lib/app/data/services/`)**：使用 `dio` + `retrofit` 宣告式定義 RESTful API 端點，並透過 Dio Interceptor 自動注入 Firebase Bearer Token。
4. **Controller (`lib/app/modules/<module>/controllers/`)**：繼承 `GetxController`，協調 `ApiService` 並管理響應式 UI 狀態。
5. **View / Widget (`lib/app/modules/<module>/views/` & `widgets/`)**：純 UI 視圖與元件層，透過 `GetView<T>` 與 `Obx` 綁定 Controller。
