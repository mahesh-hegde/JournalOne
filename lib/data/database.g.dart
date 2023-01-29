// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  JournalEntryDao? _journalEntryDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `journal_entry` (`key` INTEGER NOT NULL, `text` TEXT NOT NULL, PRIMARY KEY (`key`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  JournalEntryDao get journalEntryDao {
    return _journalEntryDaoInstance ??=
        _$JournalEntryDao(database, changeListener);
  }
}

class _$JournalEntryDao extends JournalEntryDao {
  _$JournalEntryDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _journalEntryInsertionAdapter = InsertionAdapter(
            database,
            'journal_entry',
            (JournalEntry item) =>
                <String, Object?>{'key': item.key, 'text': item.text}),
        _journalEntryUpdateAdapter = UpdateAdapter(
            database,
            'journal_entry',
            ['key'],
            (JournalEntry item) =>
                <String, Object?>{'key': item.key, 'text': item.text}),
        _journalEntryDeletionAdapter = DeletionAdapter(
            database,
            'journal_entry',
            ['key'],
            (JournalEntry item) =>
                <String, Object?>{'key': item.key, 'text': item.text});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<JournalEntry> _journalEntryInsertionAdapter;

  final UpdateAdapter<JournalEntry> _journalEntryUpdateAdapter;

  final DeletionAdapter<JournalEntry> _journalEntryDeletionAdapter;

  @override
  Future<JournalEntry?> getEntryByDate(int daysSinceEpoch) async {
    return _queryAdapter.query('SELECT * from journal_entry where key = ?1',
        mapper: (Map<String, Object?> row) =>
            JournalEntry(row['key'] as int, row['text'] as String),
        arguments: [daysSinceEpoch]);
  }

  @override
  Future<int> insertEntry(JournalEntry entry) {
    return _journalEntryInsertionAdapter.insertAndReturnId(
        entry, OnConflictStrategy.replace);
  }

  @override
  Future<int> updateEntry(JournalEntry entry) {
    return _journalEntryUpdateAdapter.updateAndReturnChangedRows(
        entry, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteEntry(JournalEntry entry) {
    return _journalEntryDeletionAdapter.deleteAndReturnChangedRows(entry);
  }

  @override
  Future<void> save(JournalEntry entry) async {
    if (database is sqflite.Transaction) {
      await super.save(entry);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.journalEntryDao.save(entry);
      });
    }
  }
}
