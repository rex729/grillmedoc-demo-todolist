#!/usr/bin/env bash
set -e

# 切換至專案根目錄
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

# 防呆：檢查是否具備 dart 或 flutter 指令
if command -v dart >/dev/null 2>&1; then
  DART_CMD="dart"
elif command -v flutter >/dev/null 2>&1; then
  DART_CMD="flutter dart"
else
  echo -e "\033[31m[ERROR] 系統未安裝或未將 Flutter / Dart SDK 加入 PATH！\033[0m"
  echo -e "\033[33m請先依據 toolchain.json 安裝 Flutter >= 3.47.0 (推薦 3.47.9)\033[0m"
  exit 1
fi

exec $DART_CMD tool/check_env.dart "$@"
