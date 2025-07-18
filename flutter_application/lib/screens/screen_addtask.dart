import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/data/database.dart';
import 'package:flutter_application/data/data_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_application/screens/screen_home_today.dart';

class ScreenAddTask extends ConsumerStatefulWidget {
  const ScreenAddTask({super.key, required this.edittask});
  final Task? edittask;

  @override
  ConsumerState<ScreenAddTask> createState() => _ScreenAddTaskState();
}

class _ScreenAddTaskState extends ConsumerState<ScreenAddTask> {
  final titleController = TextEditingController();
  final hoursController = TextEditingController();
  final commentController = TextEditingController();
  RepeteType selectedRepeat = RepeteType.none;
  int selectedColor = -1;
  DateTime? deadline;
  List<DateTime> startTimes = [];
  int taskID = 0;

  @override
  void initState() {
    super.initState();
    if (widget.edittask != null) {
      taskID = widget.edittask!.id;
      titleController.text = widget.edittask!.title;
      hoursController.text = '${widget.edittask!.requiredHours}';
      selectedColor = widget.edittask!.color;
      selectedRepeat = widget.edittask!.repete;
      commentController.text = widget.edittask!.comment ?? '';
      deadline = widget.edittask!.deadline;
      startTimes = widget.edittask!.startTime ?? [];
    }
  }

  Future<void> _saveTask() async {
    try {
      final title = titleController.text.trim();
      final hours = int.tryParse(hoursController.text.trim()) ?? 0;

      // 入力チェック
      if (title.isEmpty) {
        _showMessage('タイトルを入力してください');
        return;
      }

      if (hours <= 0) {
        _showMessage('必要時間を正しく入力してください');
        return;
      }

      if (selectedColor < 0 || selectedColor >= 10) {
        _showMessage('色を選択してください');
        return;
      }
      final newTask = Task(
        title: title,
        requiredHours: hours,
        color: selectedColor,
        repete: selectedRepeat,
        comment: commentController.text.isEmpty ? null : commentController.text,
        deadline: deadline,
        startTime: startTimes.isNotEmpty ? startTimes : null,
      );

      await ref.read(taskControllerProvider.notifier).addTask(newTask);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  ScreenHomeToday(today: DateTime.now(), editmode: true),
        ),
      );
    } catch (e) {
      _showMessage('エラーが発生しました: $e');
      // print(e);
    }
  }

  Future<void> _updateTask() async {
    try {
      final title = titleController.text.trim();
      final hours = int.tryParse(hoursController.text.trim()) ?? 0;

      // 入力チェック
      if (title.isEmpty) {
        _showMessage('タイトルを入力してください');
        return;
      }

      if (hours <= 0) {
        _showMessage('必要時間を正しく入力してください');
        return;
      }

      if (selectedColor < 0 || selectedColor >= 10) {
        _showMessage('色を選択してください');
        return;
      }
      final fixedTask = Task(
        id: taskID,
        title: title,
        requiredHours: hours,
        color: selectedColor,
        repete: selectedRepeat,
        comment: commentController.text.isEmpty ? null : commentController.text,
        deadline: deadline,
        startTime: startTimes.isNotEmpty ? startTimes : null,
      );

      await ref.read(taskControllerProvider.notifier).updateTask(fixedTask);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  ScreenHomeToday(today: DateTime.now(), editmode: true),
        ),
      );
    } catch (e) {
      _showMessage('エラーが発生しました: $e');
    }
  }

  Future<void> _deleteTask(Task task) async {
    try {
      await ref.read(taskControllerProvider.notifier).deleteTask(task);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  ScreenHomeToday(today: DateTime.now(), editmode: true),
        ),
      );
    } catch (e) {
      _showMessage('エラーが発生しました: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: Icon(Icons.calendar_today, color: Colors.black, size: 45),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        ScreenHomeToday(today: DateTime.now(), editmode: true),
              ),
            );
          },
        ),

        title: Text(
          (widget.edittask == null ? 'New' : 'Edit'),
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,

        actions: [
          /* タスク編集モードのとき表示 */
          widget.edittask != null
              ?
              // IconButton(
              //   icon: const Icon(Icons.delete_outline, color: Colors.red, size: 45), // 右端のアイコン
              //   onPressed: () {
              //         showDialog(
              //           context: context,
              //           builder: (BuildContext context) {
              //             return AlertDialog(
              //               shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(10),
              //               ),
              //               //title: const Text('このタスクを削除する？'),
              //               content: const Text('このタスクを削除する？', style: TextStyle(fontSize: 16)),
              //               actions: <Widget>[
              //                 TextButton(
              //                   child: const Text('いいえ'),
              //                   onPressed: () {
              //                     Navigator.of(context).pop(); // ダイアログを閉じる
              //                   },
              //                 ),
              //                 TextButton(
              //                   child: const Text('はい'),
              //                   onPressed: () {
              //                     Navigator.of(context).pop(); // ダイアログを閉じる
              //                     _deleteTask(widget.edittask!); // 実際の削除処理
              //                   },
              //                 ),
              //               ],
              //             );
              //           },
              //         );
              //   },
              // )
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),

                        //title: const Text('このタスクを削除する？'),
                        content: const Text(
                          'このタスクを削除する？',
                          style: TextStyle(fontSize: 16),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('いいえ'),
                            onPressed: () {
                              Navigator.of(context).pop(); // ダイアログを閉じる
                            },
                          ),
                          TextButton(
                            child: const Text('はい'),
                            onPressed: () {
                              Navigator.of(context).pop(); // ダイアログを閉じる
                              _deleteTask(widget.edittask!); // 実際の削除処理
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  side: BorderSide(color: Colors.transparent), // 薄い枠線（任意）
                ),
                child: Text('削除', style: TextStyle(fontSize: 17)),
              )
              : SizedBox.shrink(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              maxLength: 15,
              inputFormatters: [LengthLimitingTextInputFormatter(15)],
            ),
            TextField(
              controller: hoursController,
              decoration: const InputDecoration(labelText: 'Required Hours'),
              keyboardType: TextInputType.number,
              maxLength: 3,
              inputFormatters: [
                LengthLimitingTextInputFormatter(3),
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(labelText: 'Comment'),
              maxLength: 30,
              inputFormatters: [LengthLimitingTextInputFormatter(30)],
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
              children: List.generate(taskColors.length, (index) {
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
                      color: taskColors[index],
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
                  context,
                  showTitleActions: true,
                  minTime: DateTime(2020, 1, 1),
                  maxTime: DateTime(2100, 12, 31),
                  currentTime: deadline ?? DateTime.now(),
                  locale: LocaleType.jp, // 日本語
                  onConfirm: (DateTime date) {
                    setState(() {
                      deadline = date;
                    });
                  },
                );
              },
              child: Text(
                deadline != null
                    ? '期限: ${deadline!.year}/${deadline!.month}/${deadline!.day}'
                    : '期限を選択',
              ),
            ),

            // const SizedBox(height: 20),
            // const Text('開始日時（任意・複数追加可能）'),
            // ElevatedButton(
            //   onPressed: () {
            //     DatePicker.showDateTimePicker(
            //       context,
            //       showTitleActions: true,
            //       minTime: DateTime(2020, 1, 1),
            //       maxTime: DateTime(2100, 12, 31),
            //       currentTime: DateTime.now(),
            //       locale: LocaleType.jp,
            //       onConfirm: (DateTime date) {
            //         setState(() {
            //           startTimes.add(date);
            //         });
            //       },
            //     );
            //   },
            //   child: const Text('開始日時を追加'),
            // ),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children:
            //       startTimes.map((dt) {
            //         return Text(
            //           '・${dt.year}/${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}',
            //         );
            //       }).toList(),
            // ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (widget.edittask == null ? _saveTask : _updateTask),
              child: const Text('Save'),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
