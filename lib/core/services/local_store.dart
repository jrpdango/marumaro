import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:tamarun/core/models/anime.dart';
import 'package:tamarun/core/models/enums.dart';
import 'package:tamarun/core/models/list_sort.dart';
import 'package:tamarun/core/models/manga.dart';

class LocalStore {
  LocalStore({this._factory, this.path});

  static const int _schemaVersion = 2;
  static const String _animeTable = "anime";
  static const String _mangaTable = "manga";
  static const String _preferencesTable = "preferences";

  final DatabaseFactory? _factory;
  final String? path;
  Future<Database>? _database;

  Future<Database> get _db => _database ??= _open();

  Future<Database> _open() async {
    final String path =
        this.path ?? p.join(await getDatabasesPath(), "tamarun.db");
    return (_factory ?? databaseFactory).openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _schemaVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final Batch batch = db.batch();
    batch.execute('''
      CREATE TABLE $_animeTable (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        picture TEXT NOT NULL,
        total_episodes INTEGER NOT NULL,
        show_status TEXT,
        user_status TEXT NOT NULL,
        user_episodes_watched INTEGER NOT NULL,
        user_score INTEGER NOT NULL,
        list_updated_at INTEGER NOT NULL,
        synced_at INTEGER NOT NULL
      )
    ''');
    batch.execute('''
      CREATE TABLE $_mangaTable (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        picture TEXT NOT NULL,
        total_chapters INTEGER NOT NULL,
        total_volumes INTEGER NOT NULL,
        publishing_status TEXT,
        user_status TEXT NOT NULL,
        user_chapters_read INTEGER NOT NULL,
        user_volumes_read INTEGER NOT NULL,
        user_score INTEGER NOT NULL,
        list_updated_at INTEGER NOT NULL,
        synced_at INTEGER NOT NULL
      )
    ''');
    batch.execute('''
      CREATE TABLE IF NOT EXISTS $_preferencesTable (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    batch.execute(
      'CREATE INDEX idx_anime_status_updated ON $_animeTable(user_status, list_updated_at)',
    );
    batch.execute(
      'CREATE INDEX idx_manga_status_updated ON $_mangaTable(user_status, list_updated_at)',
    );
    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS $_animeTable');
    await db.execute('DROP TABLE IF EXISTS $_mangaTable');
    await _onCreate(db, newVersion);
  }

  Future<void> replaceAnimeStatus(
    AnimeListStatus status,
    List<Anime> items,
  ) async {
    final Database db = await _db;
    final int syncedAt = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((Transaction txn) async {
      await txn.delete(
        _animeTable,
        where: 'user_status = ?',
        whereArgs: <String>[status.apiValue],
      );
      final Batch batch = txn.batch();
      for (final Anime item in items) {
        batch.insert(
          _animeTable,
          _animeRow(item, status, syncedAt),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> replaceMangaStatus(
    MangaListStatus status,
    List<Manga> items,
  ) async {
    final Database db = await _db;
    final int syncedAt = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((Transaction txn) async {
      await txn.delete(
        _mangaTable,
        where: 'user_status = ?',
        whereArgs: <String>[status.apiValue],
      );
      final Batch batch = txn.batch();
      for (final Manga item in items) {
        batch.insert(
          _mangaTable,
          _mangaRow(item, status, syncedAt),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<Anime>> pageAnime(
    AnimeListStatus status, {
    required int offset,
    required int limit,
    ListSort sort = ListSort.defaultSort,
  }) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      _animeTable,
      where: 'user_status = ?',
      whereArgs: <String>[status.apiValue],
      orderBy: _orderBy(sort),
      limit: limit,
      offset: offset,
    );
    return rows.map(_animeFromRow).toList(growable: false);
  }

  Future<int> countAnime(AnimeListStatus status) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM $_animeTable WHERE user_status = ?',
      <String>[status.apiValue],
    );
    return (rows.first['count'] as int?) ?? 0;
  }

  Future<List<Anime>> searchAnime(
    String query, {
    required int offset,
    required int limit,
  }) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      _animeTable,
      where: 'title LIKE ?',
      whereArgs: <String>['%$query%'],
      orderBy: 'title COLLATE NOCASE ASC',
      limit: limit,
      offset: offset,
    );
    return rows.map(_animeFromRow).toList(growable: false);
  }

  /// Every cached anime, keyed by id, across all statuses.
  Future<Map<int, Anime>> allAnime() async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(_animeTable);
    return <int, Anime>{
      for (final Map<String, Object?> row in rows)
        row['id'] as int: _animeFromRow(row),
    };
  }

  Future<void> updateAnime(Anime anime) async {
    final Database db = await _db;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int changed = await db.update(
      _animeTable,
      <String, Object?>{
        'user_status': anime.userStatus.apiValue,
        'user_episodes_watched': anime.userEpisodesWatched,
        'user_score': anime.userScore,
        'list_updated_at': now,
      },
      where: 'id = ?',
      whereArgs: <int>[anime.id],
    );
    if (changed == 0) {
      await db.insert(
        _animeTable,
        _animeRow(
          anime.copyWith(updatedAt: DateTime.fromMillisecondsSinceEpoch(now)),
          anime.userStatus,
          now,
        ),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteAnime(int id) async {
    final Database db = await _db;
    await db.delete(_animeTable, where: 'id = ?', whereArgs: <int>[id]);
  }

  Future<List<Manga>> pageManga(
    MangaListStatus status, {
    required int offset,
    required int limit,
    ListSort sort = ListSort.defaultSort,
  }) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      _mangaTable,
      where: 'user_status = ?',
      whereArgs: <String>[status.apiValue],
      orderBy: _orderBy(sort),
      limit: limit,
      offset: offset,
    );
    return rows.map(_mangaFromRow).toList(growable: false);
  }

  Future<int> countManga(MangaListStatus status) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM $_mangaTable WHERE user_status = ?',
      <String>[status.apiValue],
    );
    return (rows.first['count'] as int?) ?? 0;
  }

  Future<List<Manga>> searchManga(
    String query, {
    required int offset,
    required int limit,
  }) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      _mangaTable,
      where: 'title LIKE ?',
      whereArgs: <String>['%$query%'],
      orderBy: 'title COLLATE NOCASE ASC',
      limit: limit,
      offset: offset,
    );
    return rows.map(_mangaFromRow).toList(growable: false);
  }

  /// Every cached manga, keyed by id, across all statuses.
  Future<Map<int, Manga>> allManga() async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(_mangaTable);
    return <int, Manga>{
      for (final Map<String, Object?> row in rows)
        row['id'] as int: _mangaFromRow(row),
    };
  }

  Future<void> updateManga(Manga manga) async {
    final Database db = await _db;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int changed = await db.update(
      _mangaTable,
      <String, Object?>{
        'user_status': manga.userStatus.apiValue,
        'user_chapters_read': manga.userChaptersRead,
        'user_volumes_read': manga.userVolumesRead,
        'user_score': manga.userScore,
        'list_updated_at': now,
      },
      where: 'id = ?',
      whereArgs: <int>[manga.id],
    );
    if (changed == 0) {
      await db.insert(
        _mangaTable,
        _mangaRow(
          manga.copyWith(updatedAt: DateTime.fromMillisecondsSinceEpoch(now)),
          manga.userStatus,
          now,
        ),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteManga(int id) async {
    final Database db = await _db;
    await db.delete(_mangaTable, where: 'id = ?', whereArgs: <int>[id]);
  }

  String _orderBy(ListSort sort) {
    final String direction = sort.descending ? 'DESC' : 'ASC';
    switch (sort.field) {
      case ListSortField.lastUpdated:
        return 'list_updated_at $direction, id ASC';
      case ListSortField.score:
        return 'user_score $direction, id ASC';
      case ListSortField.title:
        return 'title COLLATE NOCASE $direction, id ASC';
    }
  }

  Future<String?> getPreference(String key) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      _preferencesTable,
      columns: <String>['value'],
      where: 'key = ?',
      whereArgs: <String>[key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  Future<void> setPreference(String key, String value) async {
    final Database db = await _db;
    await db.insert(_preferencesTable, <String, Object?>{
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> clearAll() async {
    final Database db = await _db;
    await db.transaction((Transaction txn) async {
      await txn.delete(_animeTable);
      await txn.delete(_mangaTable);
    });
  }

  Future<void> close() async {
    final Future<Database>? database = _database;
    _database = null;
    if (database != null) {
      await (await database).close();
    }
  }

  Map<String, Object?> _animeRow(
    Anime anime,
    AnimeListStatus status,
    int syncedAt,
  ) {
    return <String, Object?>{
      'id': anime.id,
      'title': anime.title,
      'picture': anime.picture.toString(),
      'total_episodes': anime.totalEpisodes,
      'show_status': anime.showStatus?.apiValue,
      'user_status': status.apiValue,
      'user_episodes_watched': anime.userEpisodesWatched,
      'user_score': anime.userScore,
      'list_updated_at': anime.updatedAt.millisecondsSinceEpoch,
      'synced_at': syncedAt,
    };
  }

  Map<String, Object?> _mangaRow(
    Manga manga,
    MangaListStatus status,
    int syncedAt,
  ) {
    return <String, Object?>{
      'id': manga.id,
      'title': manga.title,
      'picture': manga.picture.toString(),
      'total_chapters': manga.totalChapters,
      'total_volumes': manga.totalVolumes,
      'publishing_status': manga.publishingStatus?.apiValue,
      'user_status': status.apiValue,
      'user_chapters_read': manga.userChaptersRead,
      'user_volumes_read': manga.userVolumesRead,
      'user_score': manga.userScore,
      'list_updated_at': manga.updatedAt.millisecondsSinceEpoch,
      'synced_at': syncedAt,
    };
  }

  Anime _animeFromRow(Map<String, Object?> row) {
    return Anime(
      id: row['id'] as int,
      title: row['title'] as String,
      picture: Uri.parse(row['picture'] as String),
      totalEpisodes: row['total_episodes'] as int,
      showStatus: AnimeAiringStatus.fromApiValue(row['show_status'] as String?),
      userStatus: AnimeListStatus.fromApiValue(row['user_status'] as String?),
      userEpisodesWatched: row['user_episodes_watched'] as int,
      userScore: row['user_score'] as int,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row['list_updated_at'] as int,
      ),
    );
  }

  Manga _mangaFromRow(Map<String, Object?> row) {
    return Manga(
      id: row['id'] as int,
      title: row['title'] as String,
      picture: Uri.parse(row['picture'] as String),
      totalChapters: row['total_chapters'] as int,
      totalVolumes: row['total_volumes'] as int,
      publishingStatus: MangaPublishingStatus.fromApiValue(
        row['publishing_status'] as String?,
      ),
      userStatus: MangaListStatus.fromApiValue(row['user_status'] as String?),
      userChaptersRead: row['user_chapters_read'] as int,
      userVolumesRead: row['user_volumes_read'] as int,
      userScore: row['user_score'] as int,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        row['list_updated_at'] as int,
      ),
    );
  }
}
