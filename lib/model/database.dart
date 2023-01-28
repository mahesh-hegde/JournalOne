// database.dart

// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'journal_entry_dao.dart';
import 'journal_entry.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [JournalEntry])
abstract class AppDatabase extends FloorDatabase {
  JournalEntryDao get journalEntryDao;
}
