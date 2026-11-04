// Saves/shares a generated file. Mobile writes a temp file and opens the
// native share sheet; web triggers a browser download (no dart:io there).
export 'file_export_io.dart' if (dart.library.js_interop) 'file_export_web.dart';
