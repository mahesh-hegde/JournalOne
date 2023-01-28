import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:journalone/model/database.dart';
import 'package:journalone/util/datetime_util.dart';

const databaseName = 'journal_one.db';
const loading = "Loading...";

// Providers
final dateProvider = StateProvider((ref) => DateTime.now());
final textProvider = StateProvider((ref) => loading);
final editingStateProvider = StateProvider((ref) => false);

late AppDatabase database;

void main() async {
  database = await $FloorAppDatabase.databaseBuilder(databaseName).build();
  runApp(const ProviderScope(child: JournalOneApp()));
}

class JournalOneApp extends StatelessWidget {
  const JournalOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JournalOne',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const HomePage(title: 'JournalOne'),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const Center(
        child: JournalEntryWidget(),
      ),
      floatingActionButton: const EditSaveFAB(),
    );
  }
}

class JournalEntryWidget extends ConsumerWidget {
  const JournalEntryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: const [
      DatePickerRow(),
    ]);
  }
}

class DatePickerRow extends ConsumerWidget {
  static final _today = DateTimeUtil.getDaysSinceEpoch(DateTime.now());
  static const oneDay = Duration(days: 1);

  const DatePickerRow({super.key});

  bool _isInFuture(DateTime date) {
    return DateTimeUtil.getDaysSinceEpoch(date) > _today;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(dateProvider);

    void previous() {
      ref.read(dateProvider.notifier).state = date.subtract(oneDay);
    }

    void next() {
      ref.read(dateProvider.notifier).state = date.add(oneDay);
    }

    void pickDate() async {
      var pickedDate = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime.fromMillisecondsSinceEpoch(0),
        lastDate: DateTime.now(),
      );
      if (pickedDate != null) {
        ref.read(dateProvider.notifier).state = pickedDate;
      }
    }

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: previous,
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: pickDate,
            child: Text(DateTimeUtil.formatDate(date)),
          ),
        ),
        IconButton(
          onPressed: _isInFuture(date.add(oneDay)) ? null : next,
          icon: const Icon(Icons.keyboard_arrow_right),
        ),
      ],
    );
  }
}

class EditSaveFAB extends ConsumerWidget {
  const EditSaveFAB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = ref.watch(editingStateProvider);

    void onPressed() {
      ref.read(editingStateProvider.notifier).state = !isEditing;
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: isEditing ? Colors.black : Colors.green.shade900,
      foregroundColor: Colors.white,
      child: Icon(isEditing ? Icons.done_outlined : Icons.edit_outlined),
    );
  }
}
