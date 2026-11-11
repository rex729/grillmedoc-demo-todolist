import 'dart:convert';
import 'dart:io';

import 'toolchain_checker.dart';

Future<void> main(List<String> args) async {
  // 尋找根目錄的 toolchain.json
  File? configFile;
  for (final path in ['toolchain.json', '../toolchain.json']) {
    final f = File(path);
    if (await f.exists()) {
      configFile = f;
      break;
    }
  }

  if (configFile == null) {
    stderr.writeln('\x1B[31m[ERROR] 找不到專案根目錄之 toolchain.json 規格設定檔！\x1B[0m');
    exit(1);
  }

  final specJson = jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
  final spec = ToolchainSpec.fromJson(specJson);

  stdout.writeln('====================================================');
  stdout.writeln('   GrillMeDoc Toolchain 跨平台環境預檢報告');
  stdout.writeln('====================================================');

  final checker = ToolchainChecker(spec: spec, probe: const SystemEnvironmentProbe());
  final report = await checker.checkAll();

  for (final item in report.results) {
    if (item.isSuccess) {
      stdout.writeln('\x1B[32m[✓]\x1B[0m ${item.label.padRight(14)}: ${item.detected} (符合 ${item.expected})');
    } else {
      stdout.writeln('\x1B[31m[✗]\x1B[0m ${item.label.padRight(14)}: ${item.detected} (規格要求: ${item.expected})');
      if (item.remediation != null) {
        stdout.writeln('    \x1B[33m➜ 修復指引：${item.remediation}\x1B[0m');
      }
    }
  }

  stdout.writeln('----------------------------------------------------');
  if (report.passed) {
    stdout.writeln('\x1B[32m🎉 環境全數符合規格，可正常執行 Flutter 與後端服務！\x1B[0m');
    stdout.writeln('====================================================');
    exit(0);
  } else {
    stdout.writeln('\x1B[31m❌ 檢查未通過：共 ${report.failures.length} 項環境設定需要調整，請依上方修復指引處理。\x1B[0m');
    stdout.writeln('====================================================');
    exit(1);
  }
}
