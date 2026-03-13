// Platform selector for DatabaseHelper.
// On platforms with dart:io (Android, iOS, desktop) the real SQLite
// implementation is used.  On web the no-op stub is used instead.
export 'database_helper_stub.dart'
    if (dart.library.io) 'database_helper_clean.dart';
