import 'dart:ffi';
import 'dart:io';

import 'package:bill_tracker/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:sqlite3/open.dart';

/// Factory for creating [AppDatabase] instances.
class DatabaseConnection {
  DatabaseConnection._();

  static bool _linuxSqliteOverridden = false;

  /// Create real database for app runtime.
  static AppDatabase create({String dbName = 'bill_tracker'}) {
    return AppDatabase(
      driftDatabase(
        name: dbName,
        native: const DriftNativeOptions(
          shareAcrossIsolates: true,
        ),
      ),
    );
  }

  /// Create an in-memory database for testing.
  static AppDatabase inMemory() {
    if (Platform.isLinux && !_linuxSqliteOverridden) {
      _linuxSqliteOverridden = true;
      open.overrideFor(OperatingSystem.linux, () {
        try {
          return DynamicLibrary.open('libsqlite3.so');
        } on Object {
          return DynamicLibrary.open(
            '/usr/lib/x86_64-linux-gnu/libsqlite3.so.0',
          );
        }
      });
    }
    return AppDatabase(NativeDatabase.memory());
  }
}
