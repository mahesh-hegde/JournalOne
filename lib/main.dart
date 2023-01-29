import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'data/repository.dart';
import 'util/datetime_util.dart';

const databaseName = 'journal_one.db';

void main() async {
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

    void setDate(DateTime date) {
      ref.read(dateProvider.notifier).state = date;
      repo.getEntryText(date).then((text) {
        ref.read(textProvider.notifier).state = text;
      });
    }

    void previous() => setDate(date.subtract(oneDay));

    void next() => setDate(date.add(oneDay));

    void pickDate() async {
      var pickedDate = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime.fromMillisecondsSinceEpoch(0),
        lastDate: DateTime.now(),
      );
      if (pickedDate != null) {
        setDate(pickedDate);
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

    // crude stuff ahead
    if (text == null) {
      var date = ref.read(dateProvider);
      repo
          .getEntryText(date)
          .then((text) => ref.read(textProvider.notifier).state = text);
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isEditing
          ? TextFormField(
              initialValue: text,
              onChanged: onTextChanged,
              maxLines: null,
              autofocus: true,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                  hintText: "Write your journal here...",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  )),
            )
          : Markdown(data: text),
    );
  }
}

class EditSaveFAB extends ConsumerWidget {
  const EditSaveFAB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = ref.watch(editingStateProvider);
    void onPressed() {
      if (isEditing) {
        var date = ref.read(dateProvider);
        var stagedText = ref.read(stagedTextProvider);
        if (stagedText != null) {
          ref.read(textProvider.notifier).state = stagedText;
          repo.save(date, stagedText);
          ref.read(stagedTextProvider.notifier).state = null;
        }
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
