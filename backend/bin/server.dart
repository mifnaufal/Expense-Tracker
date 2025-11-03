import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

const _dataFileRelative = 'data/transactions.store';

Future<void> main(List<String> args) async {
  final ip = InternetAddress.anyIPv4;
  final port = int.tryParse(_readArg(args, '--port') ?? '') ??
    int.tryParse(Platform.environment['PORT'] ?? '') ??
    1234;

  final router = Router()
    ..get('/health', _handleHealth)
    ..get('/transactions', _handleGetTransactions)
    ..post('/transactions', _handlePostTransactions);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router.call);

  final server = await shelf_io.serve(handler, ip, port);
  stdout.writeln(
    'Shelf backend running on http://${server.address.host}:${server.port}',
  );
}

String? _readArg(List<String> args, String flag) {
  final index = args.indexOf(flag);
  if (index == -1 || index + 1 >= args.length) return null;
  return args[index + 1];
}

Future<Response> _handleHealth(Request request) async {
  final body = jsonEncode({'status': 'ok'});
  return Response.ok(body, headers: {'content-type': 'application/json'});
}

Future<Response> _handleGetTransactions(Request request) async {
  try {
    final file = await _ensureFile();
    final contents = await file.readAsString();
    return Response.ok(
      contents,
      headers: {'content-type': 'text/plain; charset=utf-8'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
      headers: {'content-type': 'application/json'},
    );
  }
}

Future<Response> _handlePostTransactions(Request request) async {
  try {
    final payload = await request.readAsString();
    final file = await _ensureFile();
    await file.writeAsString(payload, flush: true);
    return Response.ok(
      jsonEncode({'status': 'saved', 'path': file.path}),
      headers: {'content-type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
      headers: {'content-type': 'application/json'},
    );
  }
}

Future<File> _ensureFile() async {
  final file = File(_dataFileRelative);
  await file.parent.create(recursive: true);
  if (!await file.exists()) {
    await file.create(recursive: true);
  }
  return file;
}
