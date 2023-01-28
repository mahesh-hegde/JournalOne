import 'package:floor/floor.dart';
import 'package:journalone/data/journal_entry.dart';

@dao
abstract class JournalEntryDao {
  @Query("SELECT * from journal_entry where date = :daysSinceEpoch")
  Future<JournalEntry?> getEntryByDate(int daysSinceEpoch);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertEntry(JournalEntry entry);

  @update
  Future<int> updateEntry(JournalEntry entry);

  @delete
  Future<int> deleteEntry(JournalEntry entry);
}
