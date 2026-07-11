import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

/// A SQLite-backed key-value cache for API responses.
///
/// Stores serialised JSON keyed by a cache key (derived from the API URL or
/// custom identifier). Each entry carries a TTL so stale data can be evicted
/// automatically on read.
class OfflineCacheService extends GetxService {
  static OfflineCacheService get to => Get.find<OfflineCacheService>();

  Database? _db;
  Completer<Database>? _dbCompleter;

  // ── Database initialisation ──────────────────────────────────────────

  Future<Database> get database async {
    if (_db != null) return _db!;
    if (_dbCompleter != null) return _dbCompleter!.future;

    _dbCompleter = Completer<Database>();
    try {
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'offline_cache.db');
      final database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS cached_responses (
              cache_key TEXT PRIMARY KEY,
              response_json TEXT NOT NULL,
              cached_at TEXT NOT NULL,
              ttl_minutes INTEGER NOT NULL DEFAULT 1440
            )
          ''');
        },
      );
      _db = database;
      _dbCompleter!.complete(database);
      return database;
    } catch (e) {
      _dbCompleter!.completeError(e);
      _dbCompleter = null;
      rethrow;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Warm up the database on service creation.
    database.then((_) {
      debugPrint('[OfflineCacheService] Database initialised.');
    }).catchError((e) {
      debugPrint('[OfflineCacheService] Database init error: $e');
    });
  }

  // ── Save ─────────────────────────────────────────────────────────────

  /// Persist [responseData] under [key] with an optional [ttlMinutes]
  /// (defaults to 24 hours).
  Future<void> saveCache(
    String key,
    dynamic responseData, {
    int ttlMinutes = 1440,
  }) async {
    try {
      final db = await database;
      final jsonStr = jsonEncode(responseData);
      await db.insert(
        'cached_responses',
        {
          'cache_key': key,
          'response_json': jsonStr,
          'cached_at': DateTime.now().toUtc().toIso8601String(),
          'ttl_minutes': ttlMinutes,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('[OfflineCacheService] Saved cache: $key');
    } catch (e) {
      debugPrint('[OfflineCacheService] saveCache error: $e');
    }
  }

  // ── Read ──────────────────────────────────────────────────────────────

  /// Retrieve cached data for [key]. Returns `null` if missing **or** if the
  /// entry's TTL has expired. Expired entries are deleted lazily.
  Future<dynamic> getCache(String key) async {
    try {
      final db = await database;
      final rows = await db.query(
        'cached_responses',
        where: 'cache_key = ?',
        whereArgs: [key],
        limit: 1,
      );

      if (rows.isEmpty) return null;

      final row = rows.first;
      final cachedAt = DateTime.parse(row['cached_at'] as String);
      final ttl = row['ttl_minutes'] as int;
      final expiry = cachedAt.add(Duration(minutes: ttl));

      if (DateTime.now().toUtc().isAfter(expiry)) {
        // Expired → delete and return null.
        await db.delete(
          'cached_responses',
          where: 'cache_key = ?',
          whereArgs: [key],
        );
        debugPrint('[OfflineCacheService] Cache expired: $key');
        return null;
      }

      debugPrint('[OfflineCacheService] Cache hit: $key');
      return jsonDecode(row['response_json'] as String);
    } catch (e) {
      debugPrint('[OfflineCacheService] getCache error: $e');
      return null;
    }
  }

  // ── Delete helpers ────────────────────────────────────────────────────

  /// Remove all entries whose key starts with [prefix].
  Future<void> clearByPrefix(String prefix) async {
    try {
      final db = await database;
      await db.delete(
        'cached_responses',
        where: 'cache_key LIKE ?',
        whereArgs: ['$prefix%'],
      );
      debugPrint('[OfflineCacheService] Cleared cache with prefix: $prefix');
    } catch (e) {
      debugPrint('[OfflineCacheService] clearByPrefix error: $e');
    }
  }

  /// Drop **all** cached responses (e.g. on logout).
  Future<void> clearAll() async {
    try {
      final db = await database;
      await db.delete('cached_responses');
      debugPrint('[OfflineCacheService] All cache cleared.');
    } catch (e) {
      debugPrint('[OfflineCacheService] clearAll error: $e');
    }
  }

  /// Delete cached data for [key].
  Future<void> deleteCache(String key) async {
    try {
      final db = await database;
      await db.delete(
        'cached_responses',
        where: 'cache_key = ?',
        whereArgs: [key],
      );
      debugPrint('[OfflineCacheService] Deleted cache: $key');
    } catch (e) {
      debugPrint('[OfflineCacheService] deleteCache error: $e');
    }
  }

  @override
  void onClose() {
    _db?.close();
    super.onClose();
  }
}
