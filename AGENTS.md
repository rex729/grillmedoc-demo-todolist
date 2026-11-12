# 專案 AI 代理協作規範 (AGENTS.md)

本檔案為跨模型與跨工具通用的專案導覽與核心規則。所有 AI 代理在進入本專案時皆須遵守以下規範。

---

## 1. 核心上下文檔案（記憶持久化與唯一真理來源）

在進行任何規劃、討論或撰寫程式碼之前，請先檢查並閱讀專案根目錄下的以下檔案：

* **`SPEC.md`（功能與需求規格書）**：記錄產品需求、**領域術語表 (Glossary)**、使用者流程、驗收標準（AC）與邊界條件。
* **`DESIGN.md`（系統架構與技術設計書）**：記錄系統架構、技術選型、資料模型、API 介面定義與**架構決策記錄 (ADRs)**。
* **`toolchain.json`（環境版本唯一真理來源）**：記錄跨平台前端（Flutter、Dart、Java、Gradle、NDK）與後端（Node.js）之相依版本規範。

---

## 2. 環境與 Toolchain 預檢強制規範（check_env 優先執行）

所有 AI 代理人在進入本專案、執行任何建置、執行測試或撰寫程式碼前，**必須優先執行環境預檢腳本**：
* **Windows 環境**：必須執行專案根目錄的 `check_env.bat`
* **macOS / Linux / CI 環境**：必須執行專案根目錄的 `./check_env.sh`
* **前置阻斷原則**：環境預檢腳本將依據 `toolchain.json` 進行嚴格比對。若預檢未通過（Exit Code 1），嚴禁進行任何後續建置或開發，必須先依腳本輸出之修復指引排除環境問題，確認預檢全數通過（Exit Code 0）後方可繼續。

---

## 3. 深度訪談與規格文檔化（`grill-me-doc`）規則

當與使用者進行需求釐清、架構討論或執行 `/grill-me-doc` 時：
1. **先查後問（Explore Before Asking）**：能從專案現有檔案得知的資訊，請自行查閱，切勿重複詢問使用者。
2. **逐題推進**：沿著設計決策樹每次詢問一個核心問題，並提供推薦答案（標註 `(Recommended)`）。
3. **自動文檔化同步**：當訪談達成階段性共識時，主動更新 `SPEC.md`、`DESIGN.md`、領域名詞表與 ADR。
4. **全繁體中文**：所有產出文件均以繁體中文撰寫。

---

## 4. 測試驅動開發（TDD）強制規範

本專案所有前後端功能開發與修改皆**必須嚴格遵循 TDD 流程**：
1. **Red（先寫失敗測試）**：在撰寫任何功能實作程式碼前，必須根據 `SPEC.md` 與 `DESIGN.md` 先撰寫測試，並實際執行確認其失敗（Red）。
2. **Green（撰寫最小可行實作）**：撰寫剛好能通過測試的程式碼，並實際執行確認全數通過（Green）。
3. **Refactor（重構）**：在確保測試持續通過的前提下進行程式碼重構與清理。
4. **禁止未測先寫**：嚴禁跳過測試直接產生業務邏輯程式碼。

---

## 5. Flutter 前端分層架構強制規範 (MVC + Entity / DTO / Retrofit)

前端 Flutter (`frontend/`) 必須嚴格遵守 **MVC 分層架構**：
1. **Entity (`lib/app/data/entities/`)**：純領域模型（Domain Entity），僅包含業務屬性與領域邏輯，不耦合網路傳輸格式。
2. **DTO (`lib/app/data/dtos/`)**：資料傳輸物件（Data Transfer Object），負責 JSON 序列化/反序列化，並提供 `toEntity()` 與 `fromEntity()` 轉換方法。
3. **API Service (`lib/app/data/services/`)**：使用 `dio` + `retrofit` 宣告式定義 RESTful API 端點，並透過 Dio Interceptor 自動注入 Firebase Bearer Token。
4. **Controller (`lib/app/modules/<module>/controllers/`)**：繼承 `GetxController`，協調 `ApiService` 並管理響應式 UI 狀態。
5. **View / Widget (`lib/app/modules/<module>/views/` & `widgets/`)**：純 UI 視圖與元件層，透過 `GetView<T>` 與 `Obx` 綁定 Controller。

---

## 6. 原生應用識別碼與雲端憑證對齊強制規範 (Platform App Identifiers & Cloud Config Parity)

所有 AI 代理在處理跨平台前端建置、原生配置或初始化時，必須遵循以下真理來源：
1. **唯一真理來源 (SSOT)**：
   * **Android**：以 `google-services.json` 中的 `package_name` 為真理來源。
   * **iOS**：以 `GoogleService-Info.plist` 中的 `BUNDLE_ID` 為真理來源。
2. **對齊原則**：原生層（`build.gradle.kts`、`MainActivity.kt`、`project.pbxproj`）必須完全無條件對齊此真理來源，嚴禁自行宣告相異之 ID。

---

## 7. 業務程式碼零 Mock 強制規範 (No Mocks in Production Code)

所有 AI 代理在撰寫業務邏輯時，必須嚴格遵守「真實實作」原則：
1. **禁止非測試代碼包含假資料**：`lib/`（前端）與 `src/`（後端）內嚴禁硬編碼任何偽造憑證（如 `demo_token`）、假身分或 Mock 資料。所有 Mock 邏輯僅允許出現在 `test/` 目錄中。
2. **外部相依阻斷報告原則**：若開發過程中因缺乏第三方雲端憑證（如 Firebase、OAuth Client ID）或原生環境受限而無法驗證真實流程時，**嚴禁自行撰寫 Mock 假裝串通**；代理人必須立即停止並向使用者回報具體阻斷原因，請求提供金鑰或引導真實設定。
