import 'package:floor/floor.dart';
import 'package:journalone/data/journal_entry.dart';

@dao
abstract class JournalEntryDao {
  @Query("SELECT * from journal_entry where key = :daysSinceEpoch")
  Future<JournalEntry?> getEntryByDate(int daysSinceEpoch);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertEntry(JournalEntry entry);

  @update
  Future<int> updateEntry(JournalEntry entry);

  @delete
  Future<int> deleteEntry(JournalEntry entry);

  @transaction
  Future<void> save(JournalEntry entry) async {
    if (await getEntryByDate(entry.key) == null) {
      if (entry.text.isNotEmpty) {
        await insertEntry(entry);
      }
    } else {
      if (entry.text.isNotEmpty) {
        await updateEntry(entry);
      } else {
        // Is this needed though?
        await deleteEntry(entry);
      }
    }
  }
}
