import 'package:flutter/material.dart';
import 'package:flutter_application/data/database.dart';
import 'package:flutter_application/data/data_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_application/screens/screen_homeToday.dart';


class ScreenAddTask extends ConsumerStatefulWidget {
  const ScreenAddTask({super.key});

  @override
  ConsumerState<ScreenAddTask> createState() => _ScreenAddTaskState();
}

class _ScreenAddTaskState extends ConsumerState<ScreenAddTask> {
  final titleController = TextEditingController();
  final hoursController = TextEditingController();
  final commentController = TextEditingController();
  RepeteType selectedRepeat = RepeteType.none;
  int selectedColor = 0;
  DateTime? limit;

  void _saveTask() {
  try {
    final title = titleController.text;
    final hours = int.tryParse(hoursController.text) ?? 1;

    if (title.isEmpty) return;

    final newTask = Task(
      title: title,
      requiredHours: hours,
      color: selectedColor,
      repete: selectedRepeat,
      comment: commentController.text.isEmpty ? null : commentController.text,
      limit: limit,
      startTime: null,
    );

    ref.read(taskControllerProvider.notifier).addTask(newTask);

    // ScreenHomeTodayに遷移（todayに現在時刻を渡す）
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ScreenHomeToday(today: DateTime.now()),
      ),
    );
  } catch (e, stack) {
    print('タスク保存エラー: $e\n$stack');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('エラーが発生しました: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final colorList = [
      Colors.red,
      Colors.blue,
      Colors.yellow,
      Colors.green,
      Colors.pink,
      Colors.cyan,
      Colors.orange,
      Colors.purple,
      Colors.lightGreen,
      Colors.black,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('New Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: hoursController,
              decoration: const InputDecoration(labelText: 'Required Hours'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(labelText: 'Comment'),
            ),

            const SizedBox(height: 10),
            const Text('Repete Type'),
            DropdownButton<RepeteType>(
              value: selectedRepeat,
              items:
                  RepeteType.values.map((rep) {
                    return DropdownMenuItem(value: rep, child: Text(rep.name));
                  }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedRepeat = val ?? RepeteType.none;
                });
              },
            ),

            const SizedBox(height: 10),
            const Text('Color'),
            Wrap(
              children: List.generate(colorList.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = index;
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorList[index],
                      border: Border.all(width: selectedColor == index ? 3 : 1),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                DatePicker.showDatePicker(
                  context,                  showTitleActions: true,
                  minTime: DateTime(2020, 1, 1),
                  maxTime: DateTime(2100, 12, 31),
                  currentTime: limit ?? DateTime.now(),
                  locale: LocaleType.jp, // 日本語
                  onConfirm: (DateTime date) {
                    setState(() {
                      limit = date;
                    });
                  },
                );
              },
              child: Text(
                limit != null
                    ? '期限: ${limit!.year}/${limit!.month}/${limit!.day}'
                    : '期限を選択',
              ),
            ),
            const SizedBox(height: 20,),
            ElevatedButton(onPressed: _saveTask, child: const Text('Save'),),
          ],
        ),
      ),
    );
  }
}
