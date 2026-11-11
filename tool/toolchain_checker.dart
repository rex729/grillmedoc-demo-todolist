import 'dart:convert';
import 'dart:io';

/// 語意化版本解析與比對工具。
abstract class Semver {
  /// 檢查 [actual] 是否大於等於 [min]。
  static bool satisfiesMin(String actual, String min) {
    final aParts = _parseParts(actual);
    final mParts = _parseParts(min);
    for (var i = 0; i < 3; i++) {
      final a = i < aParts.length ? aParts[i] : 0;
      final m = i < mParts.length ? mParts[i] : 0;
      if (a > m) return true;
      if (a < m) return false;
    }
    return true; // 完全相等
  }

  /// 解析主版本號（例如 "25.0.4" ➔ 25，"1.8.0" ➔ 8）。
  static int parseMajor(String version) {
    final parts = _parseParts(version);
    if (parts.isEmpty) return 0;
    if (parts[0] == 1 && parts.length > 1) {
      return parts[1]; // 處理 Java 1.8 命名
    }
    return parts[0];
  }

  static List<int> _parseParts(String v) {
    final clean = v.replaceAll(RegExp(r'^[^\d]*'), '');
    final match = RegExp(r'^(\d+)(?:\.(\d+))?(?:\.(\d+))?').firstMatch(clean);
    if (match == null) return const [];
    return [
      int.parse(match.group(1)!),
      if (match.group(2) != null) int.parse(match.group(2)!),
      if (match.group(3) != null) int.parse(match.group(3)!),
    ];
  }
}

/// Java 版本資訊。
class JavaVersionInfo {
  const JavaVersionInfo({required this.major, required this.raw});
  final int major;
  final String raw;
}

/// 環境探針介面（便於單元測試 Mock）。
abstract class EnvironmentProbe {
  Future<String?> getFlutterVersion();
  Future<String?> getDartVersion();
  Future<JavaVersionInfo?> getJavaVersion();
  Future<String?> getGradleVersion();
  Future<String?> getNodeVersion();
  Future<String?> getAndroidSdkPath();
  Future<List<String>> getInstalledNdks(String sdkPath);
}

/// 真實系統環境探針（以 Process.run 與檔案系統檢測）。
class SystemEnvironmentProbe implements EnvironmentProbe {
  const SystemEnvironmentProbe();

  @override
  Future<String?> getFlutterVersion() async {
    try {
      final res = await Process.run('flutter', ['--version', '--machine'], runInShell: true);
      if (res.exitCode == 0) {
        final data = jsonDecode(res.stdout as String);
        return data['frameworkVersion'] as String?;
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<String?> getDartVersion() async {
    try {
      final res = await Process.run('dart', ['--version'], runInShell: true);
      final output = '${res.stdout} ${res.stderr}';
      final match = RegExp(r'version:\s*(\d+\.\d+\.\d+)').firstMatch(output);
      return match?.group(1);
    } catch (_) {}
    return null;
  }

  @override
  Future<JavaVersionInfo?> getJavaVersion() async {
    final candidateExecutables = <String>[
      'java',
      if (Platform.environment['JAVA_HOME'] != null)
        '${Platform.environment['JAVA_HOME']}${Platform.pathSeparator}bin${Platform.pathSeparator}java',
      if (Platform.isWindows)
        r'C:\Program Files\Android\Android Studio\jbr\bin\java.exe',
      if (Platform.isMacOS)
        '/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/java',
      if (Platform.isLinux)
        '/opt/android-studio/jbr/bin/java',
    ];

    for (final exe in candidateExecutables) {
      try {
        final res = await Process.run(exe, ['-version'], runInShell: true);
        final output = '${res.stdout} ${res.stderr}';
        final match = RegExp(r'version\s+"([^"]+)"').firstMatch(output);
        if (match != null) {
          final raw = match.group(1)!;
          return JavaVersionInfo(major: Semver.parseMajor(raw), raw: raw);
        }
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<String?> getGradleVersion() async {
    final candidatePaths = [
      'frontend/android/gradle/wrapper/gradle-wrapper.properties',
      'android/gradle/wrapper/gradle-wrapper.properties',
      '../frontend/android/gradle/wrapper/gradle-wrapper.properties',
    ];
    for (final path in candidatePaths) {
      final wrapper = File(path);
      if (await wrapper.exists()) {
        final text = await wrapper.readAsString();
        final match = RegExp(r'gradle-([\d.]+)-').firstMatch(text);
        if (match != null) return match.group(1);
      }
    }
    return null;
  }

  @override
  Future<String?> getNodeVersion() async {
    try {
      final res = await Process.run('node', ['-v'], runInShell: true);
      if (res.exitCode == 0) {
        return (res.stdout as String).trim().replaceAll(RegExp(r'^v'), '');
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<String?> getAndroidSdkPath() async {
    final envPath = Platform.environment['ANDROID_HOME'] ?? Platform.environment['ANDROID_SDK_ROOT'];
    if (envPath != null && await Directory(envPath).exists()) return envPath;

    if (Platform.isWindows) {
      final localApp = Platform.environment['LOCALAPPDATA'];
      if (localApp != null) {
        final defaultPath = '$localApp\\Android\\Sdk';
        if (await Directory(defaultPath).exists()) return defaultPath;
      }
    } else if (Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        final defaultPath = '$home/Library/Android/sdk';
        if (await Directory(defaultPath).exists()) return defaultPath;
      }
    } else if (Platform.isLinux) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        final defaultPath = '$home/Android/Sdk';
        if (await Directory(defaultPath).exists()) return defaultPath;
      }
    }
    return null;
  }

  @override
  Future<List<String>> getInstalledNdks(String sdkPath) async {
    final ndkDir = Directory('$sdkPath${Platform.pathSeparator}ndk');
    if (!await ndkDir.exists()) return const [];
    try {
      final list = <String>[];
      await for (final entity in ndkDir.list()) {
        if (entity is Directory) {
          list.add(entity.uri.pathSegments.reversed.skip(1).first);
        }
      }
      return list;
    } catch (_) {
      return const [];
    }
  }
}

/// toolchain.json 規格模型。
class ToolchainSpec {
  const ToolchainSpec({
    required this.flutterMin,
    required this.dartMin,
    required this.javaMin,
    required this.gradleExact,
    required this.ndkRequired,
    required this.ndkInstallCommand,
    required this.nodeMin,
  });

  factory ToolchainSpec.fromJson(Map<String, dynamic> json) {
    final tc = (json['toolchain'] as Map<String, dynamic>?) ?? json;
    final flutter = (tc['flutter'] as Map<String, dynamic>?) ?? {};
    final dart = (tc['dart'] as Map<String, dynamic>?) ?? {};
    final java = (tc['java'] as Map<String, dynamic>?) ?? {};
    final gradle = (tc['gradle'] as Map<String, dynamic>?) ?? {};
    final ndk = (tc['androidNdk'] as Map<String, dynamic>?) ?? {};
    final node = (tc['node'] as Map<String, dynamic>?) ?? {};

    return ToolchainSpec(
      flutterMin: (flutter['minVersion'] as String?) ?? '3.47.0',
      dartMin: (dart['minVersion'] as String?) ?? '3.13.0',
      javaMin: (java['minVersion'] as num?)?.toInt() ?? 17,
      gradleExact: (gradle['exactVersion'] as String?) ?? '9.3.1',
      ndkRequired: (ndk['requiredVersion'] as String?) ?? '28.2.13676358',
      ndkInstallCommand: (ndk['installCommand'] as String?) ?? 'android sdk install "ndk/28.2.13676358"',
      nodeMin: (node['minVersion'] as String?) ?? '20.0.0',
    );
  }

  final String flutterMin;
  final String dartMin;
  final int javaMin;
  final String gradleExact;
  final String ndkRequired;
  final String ndkInstallCommand;
  final String nodeMin;
}

/// 單項環境檢查結果。
class CheckItemResult {
  const CheckItemResult({
    required this.label,
    required this.isSuccess,
    required this.detected,
    required this.expected,
    this.remediation,
  });

  final String label;
  final bool isSuccess;
  final String detected;
  final String expected;
  final String? remediation;
}

/// 綜合預檢報告。
class ToolchainReport {
  const ToolchainReport(this.results);
  final List<CheckItemResult> results;

  bool get passed => results.every((r) => r.isSuccess);
  List<CheckItemResult> get failures => results.where((r) => !r.isSuccess).toList();
}

/// Toolchain 預檢執行器。
class ToolchainChecker {
  const ToolchainChecker({required this.spec, required this.probe});

  final ToolchainSpec spec;
  final EnvironmentProbe probe;

  Future<ToolchainReport> checkAll() async {
    final results = <CheckItemResult>[];

    // 1. Flutter
    final flutter = await probe.getFlutterVersion();
    final flutterOk = flutter != null && Semver.satisfiesMin(flutter, spec.flutterMin);
    results.add(CheckItemResult(
      label: 'Flutter SDK',
      isSuccess: flutterOk,
      detected: flutter ?? '未偵測到',
      expected: '>= ${spec.flutterMin}',
      remediation: flutterOk ? null : '請安裝 Flutter >= ${spec.flutterMin} (推薦 3.47.9 stable)',
    ));

    // 2. Dart
    final dart = await probe.getDartVersion();
    final dartOk = dart != null && Semver.satisfiesMin(dart, spec.dartMin);
    results.add(CheckItemResult(
      label: 'Dart SDK',
      isSuccess: dartOk,
      detected: dart ?? '未偵測到',
      expected: '>= ${spec.dartMin}',
      remediation: dartOk ? null : '請確認 Dart SDK 已加入系統 PATH',
    ));

    // 3. Java
    final java = await probe.getJavaVersion();
    final javaOk = java != null && java.major >= spec.javaMin;
    results.add(CheckItemResult(
      label: 'Java / JDK',
      isSuccess: javaOk,
      detected: java?.raw ?? '未偵測到',
      expected: '>= ${spec.javaMin}',
      remediation: javaOk ? null : '請安裝 JDK >= ${spec.javaMin} (如 OpenJDK 17/21/25) 並設定 JAVA_HOME',
    ));

    // 4. Gradle Wrapper
    final gradle = await probe.getGradleVersion();
    final gradleOk = gradle == spec.gradleExact;
    results.add(CheckItemResult(
      label: 'Gradle',
      isSuccess: gradleOk,
      detected: gradle ?? '未偵測到',
      expected: spec.gradleExact,
      remediation: gradleOk ? null : '請確認 frontend/android/gradle/wrapper 內之 Gradle 版本為 ${spec.gradleExact}',
    ));

    // 5. Android NDK
    final sdkPath = await probe.getAndroidSdkPath();
    final ndks = sdkPath != null ? await probe.getInstalledNdks(sdkPath) : <String>[];
    final ndkOk = ndks.contains(spec.ndkRequired);
    results.add(CheckItemResult(
      label: 'Android NDK',
      isSuccess: ndkOk,
      detected: ndkOk ? spec.ndkRequired : (ndks.isEmpty ? '未安裝' : ndks.join(', ')),
      expected: spec.ndkRequired,
      remediation: ndkOk
          ? null
          : 'AGP 9.1 強制需要 NDK ${spec.ndkRequired}。請執行以下指令安裝：\n      ${spec.ndkInstallCommand}',
    ));

    // 6. Node.js
    final node = await probe.getNodeVersion();
    final nodeOk = node != null && Semver.satisfiesMin(node, spec.nodeMin);
    results.add(CheckItemResult(
      label: 'Node.js',
      isSuccess: nodeOk,
      detected: node != null ? 'v$node' : '未偵測到',
      expected: '>= ${spec.nodeMin}',
      remediation: nodeOk ? null : '請安裝 Node.js >= ${spec.nodeMin} (推薦 v24.12.0) 供後端 RESTful API 運行',
    ));

    return ToolchainReport(results);
  }
}
