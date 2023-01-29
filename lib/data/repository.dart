import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journalone/data/database.dart';
import 'package:journalone/data/journal_entry.dart';
import 'package:journalone/util/datetime_util.dart';

const loading = "Loading...";

abstract class AppRepository {
  void save(DateTime date, String text);
  Future<String> getEntryText(DateTime date);
}

class SqliteRepository extends AppRepository {
  static const databaseName = "JournalOne.db";

  SqliteRepository._();

  AppDatabase? _database;
  // We need this because we need to store a Database, not a future
  Future<AppDatabase> get database async {
    return _database ??=
        await $FloorAppDatabase.databaseBuilder(databaseName).build();
  }

  static final _instance = SqliteRepository._();
  static SqliteRepository getInstance() => _instance;

  @override
  Future<String> getEntryText(DateTime date) async {
    var dao = (await database).journalEntryDao;
    var entry = await dao.getEntryByDate(DateTimeUtil.getDaysSinceEpoch(date));
    return entry?.text ?? "";
  }

  @override
  void save(DateTime date, String text) async {
    var dao = (await database).journalEntryDao;
    dao.save(JournalEntry.from(date: date, text: text));
  }
}

// TODO: This should be provider, so that it will be easy to mock
AppRepository repo = SqliteRepository.getInstance();

final dateProvider = StateProvider((ref) => DateTime.now());
final textProvider = StateProvider<String?>((ref) {
  return null;
});

final stagedTextProvider = StateProvider<String?>((ref) => null);
final editingStateProvider = StateProvider((ref) => false);
