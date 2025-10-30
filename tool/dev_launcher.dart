import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _defaultPort = 8080;
const _backendEntry = 'backend/bin/server.dart';
const _healthPath = '/health';
const _backendDefineKey = 'EXPENSE_BACKEND_URL';

String get _dartExecutable => Platform.isWindows ? 'dart.bat' : 'dart';
String get _flutterExecutable => Platform.isWindows ? 'flutter.bat' : 'flutter';

Future<void> main(List<String> args) async {
  final config = _LaunchConfig.fromArgs(args);
  final backendUrl = 'http://localhost:${config.port}';

  stdout.writeln('🚀 Starting Expense Tracker dev launcher');
  stdout.writeln('• Desired backend port: ${config.port}');

  final alreadyRunning = await _pingBackend(backendUrl);
  Process? backendProcess;

  if (alreadyRunning) {
    stdout.writeln('✔ Backend already running at $backendUrl');
  } else {
    stdout.writeln('⏳ Backend not detected, starting a new instance...');
    backendProcess = await _startBackend(config.port);
    final ready = await _waitForBackend(backendUrl, attempts: 12);
    if (!ready) {
      stderr.writeln('✖ Backend failed to start within the expected time.');
      await _stopProcess(backendProcess);
      exit(1);
    }
    stdout.writeln('✔ Backend is up at $backendUrl');
  }

  if (config.skipFlutter) {
    stdout.writeln('Flutter launch skipped. Press CTRL+C to stop the backend.');
    await backendProcess?.exitCode;
    return;
  }

  final flutterArgs = List<String>.from(config.flutterArgs);
  final backendDefine = '--dart-define=$_backendDefineKey=$backendUrl';
  final hasBackendDefine = flutterArgs.any(
    (arg) => arg.startsWith('--dart-define=$_backendDefineKey='),
  );
  if (!hasBackendDefine) {
    flutterArgs.add(backendDefine);
  }

  if (!config.hasDeviceFlag) {
    flutterArgs.addAll(['-d', 'chrome']);
  }

  stdout.writeln('▶ Running flutter run ${flutterArgs.join(' ')}');
  final flutterProcess = await Process.start(
    _flutterExecutable,
    ['run', ...flutterArgs],
    mode: ProcessStartMode.inheritStdio,
  );

  final subscriptions = <StreamSubscription<dynamic>>[];
  subscriptions.add(ProcessSignal.sigint.watch().listen((signal) async {
    stdout.writeln('\nReceived CTRL+C. Shutting down...');
    flutterProcess.kill(ProcessSignal.sigint);
    await _stopProcess(backendProcess);
  }));

  if (!Platform.isWindows) {
    subscriptions.add(ProcessSignal.sigterm.watch().listen((signal) async {
      stdout.writeln('\nReceived SIGTERM. Shutting down...');
      flutterProcess.kill(ProcessSignal.sigterm);
      await _stopProcess(backendProcess);
    }));
  }

  final flutterExit = await flutterProcess.exitCode;
  stdout.writeln('Flutter run exited with code $flutterExit');

  await _stopProcess(backendProcess);
  await Future.wait(subscriptions.map((sub) => sub.cancel()));

  exit(flutterExit);
}

Future<bool> _pingBackend(String baseUrl) async {
  final uri = Uri.parse(baseUrl + _healthPath);
  final client = HttpClient();
  try {
    final request = await client.getUrl(uri).timeout(const Duration(milliseconds: 400));
    final response = await request.close().timeout(const Duration(milliseconds: 400));
    return response.statusCode == HttpStatus.ok;
  } catch (_) {
    return false;
  } finally {
    client.close(force: true);
  }
}

Future<bool> _waitForBackend(String baseUrl, {int attempts = 10}) async {
  for (var attempt = 0; attempt < attempts; attempt++) {
    if (await _pingBackend(baseUrl)) {
      return true;
    }
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
  return false;
}

Future<Process> _startBackend(int port) async {
  final process = await Process.start(
    _dartExecutable,
    ['run', _backendEntry, '--port', '$port'],
    workingDirectory: Directory.current.path,
  );

  process.stdout
      .transform(utf8.decoder)
      .listen((line) => stdout.write('[backend] $line'));
  process.stderr
      .transform(utf8.decoder)
      .listen((line) => stderr.write('[backend] $line'));

  unawaited(process.exitCode.then((code) {
    if (code != 0) {
      stderr.writeln('Backend process exited unexpectedly with code $code');
    }
  }));

  return process;
}

Future<void> _stopProcess(Process? process) async {
  if (process == null) {
    return;
  }
  process.kill();
  try {
    await process.exitCode.timeout(const Duration(seconds: 2));
  } catch (_) {
    process.kill(ProcessSignal.sigkill);
  }
}

class _LaunchConfig {
  _LaunchConfig({
    required this.port,
    required this.flutterArgs,
    required this.skipFlutter,
    required this.hasDeviceFlag,
  });

  final int port;
  final List<String> flutterArgs;
  final bool skipFlutter;
  final bool hasDeviceFlag;

  factory _LaunchConfig.fromArgs(List<String> args) {
    var port = int.tryParse(Platform.environment['EXPENSE_BACKEND_PORT'] ?? '') ??
        _defaultPort;
    var skipFlutter = false;
    final flutterArgs = <String>[];
    var awaitingPortValue = false;
    var sawDeviceFlag = false;

    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      if (awaitingPortValue) {
        final parsed = int.tryParse(arg);
        if (parsed != null) {
          port = parsed;
        }
        awaitingPortValue = false;
        continue;
      }

      if (arg == '--backend-port') {
        awaitingPortValue = true;
        continue;
      }

      if (arg.startsWith('--backend-port=')) {
        final value = arg.split('=').last;
        final parsed = int.tryParse(value);
        if (parsed != null) {
          port = parsed;
        }
        continue;
      }

      if (arg == '--skip-flutter') {
        skipFlutter = true;
        continue;
      }

      if (arg == '-d' || arg == '--device') {
        sawDeviceFlag = true;
      }

      flutterArgs.add(arg);
    }

    if (!skipFlutter && !sawDeviceFlag) {
      sawDeviceFlag = flutterArgs.contains('-d') || flutterArgs.contains('--device');
    }

    return _LaunchConfig(
      port: port,
      flutterArgs: flutterArgs,
      skipFlutter: skipFlutter,
      hasDeviceFlag: sawDeviceFlag,
    );
  }
}
