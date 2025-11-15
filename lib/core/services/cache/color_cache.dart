import 'dart:developer';
import 'dart:ui';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ColorCacheService {
  static const String _databaseName = 'color_cache.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'cached_colors';

  static Database? _database;
  final _memoryCache = <String, List<Color>>{};

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        imageUrl TEXT PRIMARY KEY,
        colorsData TEXT NOT NULL, -- JSON array of color values
        createdAt INTEGER NOT NULL,
        colorCount INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_created_at ON $_tableName (createdAt)
    ''');
  }

  Future<void> cacheColors(String imageUrl, List<Color> colors) async {
    // cache in memory for instant access
    _memoryCache[imageUrl] = colors;

    final db = await database;
    try {
      final colorValues = colors.map((color) => color.value).toList();

      await db.insert(_tableName, {
        'imageUrl': imageUrl,
        'colorsData': _encodeColors(colorValues),
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'colorCount': colors.length,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      log('✅ Colors cached: $imageUrl (${colors.length} colors)');
    } catch (e) {
      log("❌ Error caching colors: $e");
    }
  }

  Future<List<Color>?> getCachedColors(String imageUrl) async {
    //  memory cache
    final memoryCached = _memoryCache[imageUrl];
    if (memoryCached != null) {
      log('🚀 Memory cache HIT: $imageUrl');
      return memoryCached;
    }

    //  db cache
    try {
      final db = await database;
      final maps = await db.query(
        _tableName,
        where: 'imageUrl = ?',
        whereArgs: [imageUrl],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        final colorsData = maps.first['colorsData'] as String;
        final colorValues = _decodeColors(colorsData);

        final colors = colorValues.map((value) => Color(value)).toList();

        _memoryCache[imageUrl] = colors;
        log('db: $imageUrl ');
        return colors;
      }
    } catch (e) {
      log('cache error for $imageUrl: $e');
      await _removeCorruptedEntry(imageUrl);
    }

    log('no cache for: $imageUrl');
    return null;
  }

  String _encodeColors(List<int> colorValues) {
    return colorValues.join(',');
  }

  List<int> _decodeColors(String colorsData) {
    return colorsData.split(',').map((value) => int.parse(value)).toList();
  }

  Future<void> _removeCorruptedEntry(String imageUrl) async {
    try {
      final db = await database;
      await db.delete(_tableName, where: 'imageUrl = ?', whereArgs: [imageUrl]);
    } catch (e) {
      log(' error removing corrupted entry: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllCachedColorsWithTimestamp() async {
    try {
      final db = await database;
      final maps = await db.query(_tableName);

      final result = <Map<String, dynamic>>[];

      for (final map in maps) {
        final imageUrl = map['imageUrl'] as String;
        final colorsData = map['colorsData'] as String;
        final createdAt = map['createdAt'] as int;
        final colorCount = map['colorCount'] as int;

        final colorValues = _decodeColors(colorsData);
        final colors = colorValues.map((value) => Color(value)).toList();

        result.add({
          'imageUrl': imageUrl,
          'colors': colors,
          'createdAt': DateTime.fromMillisecondsSinceEpoch(createdAt),
          'colorCount': colorCount,
        });
      }

      result.sort(
        (a, b) =>
            (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime),
      );

      log('${result.length} cached color sets from database');
      return result;
    } catch (e) {
      log('error retrieving cached colors from database: $e');
      return [];
    }
  }

  void clearMemoryCache() {
    final count = _memoryCache.length;
    _memoryCache.clear();
    log('cleared $count items from memory cache (ram)');
  }

  Future<void> close() async {
    _memoryCache.clear();
    await _database?.close();
    _database = null;
  }
}
