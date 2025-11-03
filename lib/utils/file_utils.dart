import 'dart:typed_data';

import 'file_utils_stub.dart'
    if (dart.library.io) 'file_utils_io.dart' as impl;

Future<Uint8List?> readFileBytes(String path) => impl.readFileBytes(path);

bool fileExists(String path) => impl.fileExists(path);

