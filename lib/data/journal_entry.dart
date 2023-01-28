// Defines the journal entry
import 'package:floor/floor.dart';
import 'package:journalone/util/datetime_util.dart';

@Entity(tableName: 'journal_entry')
class JournalEntry {
  // We use number of days since epoch as primary key.
  @PrimaryKey()
  int key;
  String text;

  JournalEntry(this.key, this.text);
  JournalEntry.fromDateAndText({required DateTime date, required String text})
      : this(DateTimeUtil.getDaysSinceEpoch(date), text);
  DateTime get dateTime => DateTimeUtil.getDateTime(key);
}
