import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'data/database.dart';
import 'data/providers.dart';
import 'util/datetime_util.dart';

const databaseName = 'journal_one.db';

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
      Expanded(child: JournalEntryText()),
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

class JournalEntryText extends ConsumerWidget {
  const JournalEntryText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = ref.watch(editingStateProvider);
    final text = ref.watch(textProvider);

    void onTextChanged(String? textNow) {
      ref.read(stagedTextProvider.notifier).state = textNow ?? '';
    }

    if (isEditing) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: TextFormField(
          initialValue: text,
          onChanged: onTextChanged,
          maxLines: null,
          autofocus: true,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          decoration: const InputDecoration(
              border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal),
          )),
        ),
      );
    } else {
      return Markdown(data: text);
    }
  }
}

class EditSaveFAB extends ConsumerWidget {
  const EditSaveFAB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = ref.watch(editingStateProvider);

    void onPressed() {
      if (isEditing) {
        var stagedText = ref.read(stagedTextProvider);
        ref.read(textProvider.notifier).state = stagedText;
        // write staged text to database.
      }
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
