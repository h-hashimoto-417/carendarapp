import 'package:flutter/material.dart';
import 'package:flutter_application/models/model.dart';
import 'package:flutter_application/data/data_manager.dart';
import 'package:flutter_application/screens/screen_addtask.dart';
import 'package:flutter_application/data/database.dart';
import 'package:flutter_application/screens/screen_calendar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:collection/collection.dart';
// import '../data/data_manager.dart';

class ScreenHomeToday extends ConsumerStatefulWidget {
  const ScreenHomeToday({
    super.key,
    required this.today,
    required this.editmode,
  });
  final DateTime today;
  final bool editmode;

  @override
  ConsumerState<ScreenHomeToday> createState() => _ScreenHomeTodayState();
}

class _ScreenHomeTodayState extends ConsumerState<ScreenHomeToday> {
  //final DateTime today = widget.today;
  final PanelController _panelController = PanelController();
  bool isEdditing = false;
  //bool showEditButton = false;
  Map<int, bool> showEditMap = {};
  Map<int, int> numTempoPlacedTask = {};

  int countFromToday = 0;
  int month = 0;
  int day = 0;
  int weekday = 0;
  int count = 0;
  DateTime someday = DateTime.now();
  List<Color> timeColors = List.generate(24, (index) => Colors.white);
  List<Color> textColors = List.generate(24, (index) => Colors.white);
  List<String> taskTitles = List.generate(24, (index) => '');
  List<String> taskComments = List.generate(24, (index) => '');
  List<int> taskIDs = List.generate(24, (index) => 0);
  int? selectedHour;
  Task? selectedTask;
  Map<int, Task> taskHourMap = {};
  late List<GlobalKey<State<StatefulWidget>>> _hourKeys = List.generate(
    24,
    (_) => GlobalKey<State<StatefulWidget>>(),
  );
  //final taskProvider = ref.watch(taskControllerProvider);

  @override
  void initState() {
    super.initState();
    _hourKeys = List.generate(24, (_) => GlobalKey<State<StatefulWidget>>());
    someday = widget.today;
    month = someday.month;
    day = someday.day;
    weekday = someday.weekday;
    isEdditing = widget.editmode;
    // 初期表示時に editmode が true ならパネルを開く
    if (isEdditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _panelController.open();
      });
    }

    if (widget.today.hour >= 0 && widget.today.hour < 24) {
      selectedHour = widget.today.hour + 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedHour();
        setState(() {
          selectedHour = null;
        });
      });
    } else {
      selectedHour = null;
    }
  }

  //@override
  /* somedayに日付けを取得する */
  void _dateTransition() {
    setState(() {
      if (countFromToday == 0) {
        someday = widget.today;
      } else if (countFromToday > 0) {
        someday = widget.today.add(Duration(days: countFromToday));
      } else {
        someday = widget.today.subtract(Duration(days: (-countFromToday)));
      }

      month = someday.month;
      day = someday.day;
      weekday = someday.weekday;
      count = countFromToday;
    });
  }

  /* showEditMap（編集ボタン表示）の初期化 */
  void _hideEditButton() {
    setState(() {
      showEditMap.updateAll((key, value) => false);
    });
  }

  void _removeScheduledAtHour(int hour) {
    () async {
      final scheduledTasks = getScheduledTasksForDay(
        someday,
        ref.read(taskControllerProvider),
      );

      final toRemove =
          scheduledTasks
              .where((st) => !st.exception)
              .firstWhereOrNull((st) => st.dateTime.hour == hour) ??
          scheduledTasks.firstWhereOrNull((st) => st.dateTime.hour == hour);

      if (toRemove == null) return;

      final task = toRemove.task;
      final originalList = task.startTime ?? [];

      final updatedList =
          originalList.where((dt) {
            return !(dt.year == someday.year &&
                dt.month == someday.month &&
                dt.day == someday.day &&
                dt.hour == hour);
          }).toList();

      final updatedTask = task.copyWith(startTime: updatedList, excepts: []);

      await ref.read(taskControllerProvider.notifier).updateTask(updatedTask);
      setState(() {
        taskHourMap.remove(hour);
      });
    }();
  }

  Future<void> _addExceptAtHour(int hour) async {
    final scheduledTasks = getScheduledTasksForDay(
      someday,
      ref.read(taskControllerProvider),
    );

    final target = scheduledTasks.firstWhereOrNull(
      (st) => st.dateTime.hour == hour,
    );

    if (target == null) return;

    final task = target.task;
    final originalList = task.excepts ?? [];

    // 既に登録済みなら何もしない
    if (originalList.any(
      (ex) =>
          ex.year == someday.year &&
          ex.month == someday.month &&
          ex.day == someday.day &&
          ex.hour == hour,
    )) {
      return;
    }

    final updatedExcepts = List<DateTime>.from(originalList)
      ..add(DateTime(someday.year, someday.month, someday.day, hour, 0));

    final updatedTask = task.copyWith(excepts: updatedExcepts);

    await ref.read(taskControllerProvider.notifier).updateTask(updatedTask);

    setState(() {
      // 状態変化をUIに伝えるため空で良い
    });
  }

  Future<void> _removeExceptAtHour(int hour) async {
    final scheduledTasks = getScheduledTasksForDay(
      someday,
      ref.read(taskControllerProvider),
    );

    final toRemove = scheduledTasks.firstWhereOrNull(
      (st) => st.dateTime.hour == hour,
    );

    if (toRemove == null) return;

    final task = toRemove.task;
    final originalList = task.excepts ?? [];

    final updatedList =
        originalList.where((dt) {
          return !(dt.year == someday.year &&
              dt.month == someday.month &&
              dt.day == someday.day &&
              dt.hour == hour);
        }).toList();

    final updatedTask = task.copyWith(excepts: updatedList);

    await ref.read(taskControllerProvider.notifier).updateTask(updatedTask);

    setState(() {
      // UI反映用。taskHourMapはexcepts操作では不要
    });
  }

  void _scrollToSelectedHour() {
    if (selectedHour != null &&
        _hourKeys[selectedHour!].currentContext != null) {
      Scrollable.ensureVisible(
        _hourKeys[selectedHour!].currentContext!,
        duration: Duration(milliseconds: 300),
        alignment: 0.2, // 上から20%くらいの位置に
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // DateTime now = widget.today;
    // month = now.month;
    // day = now.day;
    // weekday = now.weekday;
    // build内にあるからbuildされるたびに毎回初期化される。

    final taskProvider = ref.watch(taskControllerProvider);
    final List<Task> notPlacedTasks = getNotPlacedTask(taskProvider);
    int notPlacedTasksLength = 0;

    if (notPlacedTasks != []) {
      notPlacedTasksLength = notPlacedTasks.length;
    }
    // if (isEdditing) {
    //   _panelController.open(); // パネルを開く
    // }

    Future<bool?> showSaveDialog(BuildContext context) {
      return showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Center(
              child: Text('編集内容を保存しますか？', style: TextStyle(fontSize: 20)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // 保存
                    },
                    child: Text('保存'),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // 保存しない
                    },
                    child: Text('保存しない'),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(null); // キャンセル
                    },
                    child: Text('キャンセル'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    void taskblock() {
      // somedayにおけるtaskデータを取得（タスク, 開始時間）
      List<ScheduledTask> tasks = getScheduledTasksForDay(
        someday,
        taskProvider,
      );
      // Listを参照してcontainerblockの色をtaskの色に設定
      timeColors.fillRange(0, timeColors.length, Colors.white);
      textColors.fillRange(0, timeColors.length, Colors.white);
      taskTitles.fillRange(0, taskTitles.length, '');
      taskComments.fillRange(0, taskComments.length, '');
      taskIDs.fillRange(0, taskIDs.length, 0);
      for (int i = 0; i < tasks.length; i++) {
        timeColors[tasks[i].dateTime.hour] =
            tasks[i].exception
                ? isEdditing &&
                        timeColors[tasks[i].dateTime.hour] == Colors.white
                    ? taskColors[tasks[i].task.color].withAlpha(100)
                    : timeColors[tasks[i].dateTime.hour]
                : taskColors[tasks[i].task.color];
        if (tasks[i].task.color == 0 || tasks[i].task.color == 1) {
          textColors[tasks[i].dateTime.hour] =
              tasks[i].exception
                  ? taskTitles[tasks[i].dateTime.hour] == ''
                      ? Colors.grey
                      : textColors[tasks[i].dateTime.hour]
                  : Colors.black;
        }
        taskComments[tasks[i].dateTime.hour] =
            tasks[i].exception
                ? isEdditing && taskTitles[tasks[i].dateTime.hour] == ''
                    ? tasks[i].task.comment ?? ''
                    : taskComments[tasks[i].dateTime.hour]
                : tasks[i].task.comment ?? '';

        taskIDs[tasks[i].dateTime.hour] =
            tasks[i].exception
                ? isEdditing && taskTitles[tasks[i].dateTime.hour] == ''
                    ? tasks[i].task.id
                    : taskIDs[tasks[i].dateTime.hour]
                : tasks[i].task.id;
        taskTitles[tasks[i].dateTime.hour] =
            tasks[i].exception
                ? isEdditing && taskTitles[tasks[i].dateTime.hour] == ''
                    ? tasks[i].task.title
                    : taskTitles[tasks[i].dateTime.hour]
                : tasks[i].task.title;
        // else {
        //   textColors[i] = Colors.white;
        // }
      }

      taskHourMap.forEach((hour, task) {
        timeColors[hour] = taskColors[task.color];
        taskTitles[hour] = task.title;
        taskComments[hour] = task.comment ?? '';
        if (task.color == 0 || task.color == 1) {
          textColors[hour] = Colors.black;
        } else {
          textColors[hour] = Colors.white;
        }
      });
    }

    /* タスクを仮配置する */
    void placeTask(int index) {
      setState(() {
        // 現在選択された時間にタスクを一旦配置
        // taskHourMap[selectedHour!] = notPlacedTasks[index];

        // ---- 埋まっている時間の一覧を作成（保存済み + 配置中） ----
        Set<int> occupiedHours = {};

        // 保存済みタスク（当日）
        final scheduledTasks = getScheduledTasksForDay(someday, taskProvider);
        for (var task in scheduledTasks) {
          if (!task.exception) {
            occupiedHours.add(task.dateTime.hour);
          }
        }

        // 配置中タスク
        occupiedHours.addAll(taskHourMap.keys);

        // ---- selectedHour から次の空き時間を検索 ----
        int nextHour = selectedHour!;
        while (nextHour < 24 && occupiedHours.contains(nextHour)) {
          nextHour++;
        }

        // 空き時間がなければ何もしない
        if (nextHour >= 24) {
          selectedHour = null;
          selectedTask = null;
          setState(() {});
          return;
        }

        setState(() {
          // 空いている時間に配置
          taskHourMap[nextHour] = notPlacedTasks[index];

          // 次の空き時間をさらに検索
          int followingHour = nextHour + 1;
          while (followingHour < 24 && occupiedHours.contains(followingHour)) {
            followingHour++;
          }
          selectedHour = followingHour < 24 ? followingHour : null;
          selectedTask = null;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToSelectedHour();
        });
      });
    }

    Future<void> savePlacedTasks({
      required Map<int, Task> taskHourMap,
      required DateTime date,
      required WidgetRef ref,
      required VoidCallback onCompleted,
    }) async {
      // Task → 複数の hour をまとめる
      final Map<Task, List<int>> taskToHoursMap = {};
      taskHourMap.forEach((hour, task) {
        taskToHoursMap.putIfAbsent(task, () => []).add(hour);
      });

      // 各タスクを更新
      for (final entry in taskToHoursMap.entries) {
        final task = entry.key;
        final hours = entry.value;

        final newTimes =
            hours.map((hour) {
              return DateTime(date.year, date.month, date.day, hour);
            }).toList();

        final updatedStartTimes =
            {
              if (task.startTime != null) ...task.startTime!,
              ...newTimes,
            }.toList();

        final updatedTask = task.copyWith(startTime: updatedStartTimes);

        await ref.read(taskControllerProvider.notifier).updateTask(updatedTask);
      }

      // コンフリクトを削除（リピートにかぶってしまった単発タスクを消す）
      await ref
          .read(taskControllerProvider.notifier)
          .cleanAllConflictingSingleTimeTasks();

      // UIなどの後処理
      onCompleted();
    }

    /* idを照らし合わせて未配置タスクの数をインクリメント */
    void setNumTempoPlacedTask(int taskid) {
      setState(() {
        numTempoPlacedTask[taskid] =
            (numTempoPlacedTask[taskid] == null)
                ? 0
                : numTempoPlacedTask[taskid]! - 1;
      });
    }

    taskblock();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.calendar_month, size: 45), // 左端のアイコン
          onPressed: () async {
            if (isEdditing && taskHourMap.isNotEmpty) {
              // 編集モードであれば保存ダイアログを表示

              final result = await showSaveDialog(context);
              if (result == true) {
                // 保存してから移動
                await savePlacedTasks(
                  taskHourMap: taskHourMap,
                  date: someday,
                  ref: ref,
                  onCompleted: () {
                    setState(() {
                      _panelController.close();
                      selectedHour = null;
                      taskHourMap.clear();
                      isEdditing = false;
                      numTempoPlacedTask.updateAll((key, value) => 0);
                    });
                  },
                );
                if (!context.mounted) return; // 画面がマウントされているか確認
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScreenCalendar()),
                );
              } else if (result == false) {
                setState(() {
                  _panelController.close();
                  selectedHour = null;
                  taskHourMap.clear();
                  isEdditing = false;
                });
                if (!context.mounted) return; // 画面がマウントされているか確認
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScreenCalendar()),
                );
              } else {
                // キャンセル
              }
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScreenCalendar()),
              );
            }
          },
        ),
        title: Text(
          '$month月', // 日付データを取得する！
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note, size: 45), // 右端のアイコン

            onPressed: () {
              // 編集アイコンの動作を定義
              setState(() {
                isEdditing = true;
              });
              _panelController.open(); // パネルを開く
            },
          ),
        ],
      ),

      // ボトムシートの表示
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: isEdditing ? 65 : 0,
        maxHeight: 350,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),

        panel: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 50, // リボンの高さ
              decoration: BoxDecoration(
                color: Colors.white, // リボンの色
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //Spacer(),
                  /* 保存ボタン */
                  IconButton(
                    icon: Icon(Icons.done, size: 40, color: Colors.blue),
                    onPressed: () {
                      savePlacedTasks(
                        taskHourMap: taskHourMap,
                        date: someday,
                        ref: ref,
                        onCompleted: () {
                          setState(() {
                            _panelController.close();
                            selectedHour = null;
                            taskHourMap.clear();
                            isEdditing = false;
                            numTempoPlacedTask.updateAll((key, value) => 0);
                          });
                        },
                      );
                    },
                  ),
                  Text(
                    '未配置のタスク',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  /* 新規作成ボタン */
                  IconButton(
                    icon: Icon(
                      Icons.add_box_outlined,
                      size: 40,
                      color: Colors.blue,
                    ),
                    onPressed: () async {
                      if (isEdditing && taskHourMap.isNotEmpty) {
                        final result = await showSaveDialog(context);
                        if (result == true) {
                          savePlacedTasks(
                            taskHourMap: taskHourMap,
                            date: someday,
                            ref: ref,
                            onCompleted: () {
                              setState(() {
                                _panelController.close();
                                selectedHour = null;
                                taskHourMap.clear();
                                isEdditing = false;
                                numTempoPlacedTask.updateAll((key, value) => 0);
                              });
                            },
                          );
                          if (!context.mounted) return; // 画面がマウントされているか確認
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ScreenAddTask(edittask: null),
                            ),
                          );
                        } else if (result == false) {
                          setState(() {
                            _panelController.close();
                            selectedHour = null;
                            taskHourMap.clear();
                            isEdditing = false;
                          });

                          if (!context.mounted) return; // 画面がマウントされているか確認
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ScreenAddTask(edittask: null),
                            ),
                          );
                        } else {
                          // キャンセル
                        }
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScreenAddTask(edittask: null),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent, // 背景タップも検知
                onTap: _hideEditButton,
                child: Container(
                  color: Colors.white, // パネル全体の背景色

                  child: GridView.count(
                    crossAxisCount: 2, // グリッドの列
                    childAspectRatio: 2.3, // グリッドの比
                    padding: EdgeInsets.all(8),
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                    children: List.generate(notPlacedTasksLength, (index) {
                      return Material(
                        color: Colors.transparent,
                        child: Stack(
                          children: [
                            InkWell(
                              // ボタン機能を持たせる
                              // ...existing code...
                              onTap: () {
                                if (isEdditing && selectedHour != null) {
                                  if (!numTempoPlacedTask.containsKey(
                                    notPlacedTasks[index].id,
                                  )) {
                                    numTempoPlacedTask[notPlacedTasks[index]
                                            .id] =
                                        1;
                                    placeTask(index);
                                  } else if (numTempoPlacedTask[notPlacedTasks[index]
                                          .id]! <
                                      getnumOfNotPlacedTask(
                                        notPlacedTasks[index],
                                      )) {
                                    numTempoPlacedTask[notPlacedTasks[index]
                                            .id] =
                                        numTempoPlacedTask[notPlacedTasks[index]
                                            .id]! +
                                        1;
                                    placeTask(index);
                                  }
                                  _hideEditButton();

                                  return;
                                }
                              },
                              onLongPress: () {
                                setState(() {
                                  _hideEditButton();
                                  showEditMap[index] = true;
                                });
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          taskColors[notPlacedTasks[index]
                                              .color],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        notPlacedTasks[index].title,
                                        style: TextStyle(
                                          color:
                                              (notPlacedTasks[index].color ==
                                                          0 ||
                                                      notPlacedTasks[index]
                                                              .color ==
                                                          1)
                                                  ? Colors.black
                                                  : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  /* ブロックの左上に赤丸を表示 */
                                  Positioned(
                                    top: -2,
                                    left: -2,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.redAccent,
                                      child: Text(
                                        // 未配置のタスク数（タップするたび0になるまでデクリメント）
                                        '${getnumOfNotPlacedTask(notPlacedTasks[index]) - (numTempoPlacedTask.containsKey(notPlacedTasks[index].id) ? numTempoPlacedTask[notPlacedTasks[index].id]! : 0)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            /* タスク編集ボタンの表示 */
                            if (showEditMap[index] == true)
                              Positioned(
                                top: 17,
                                right: 0,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ScreenAddTask(
                                              edittask: notPlacedTasks[index],
                                            ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    side: BorderSide(
                                      color: Colors.black12,
                                    ), // 薄い枠線（任意）
                                  ),
                                  child: Text(
                                    '編集',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),

        // スクロールウィンドウの表示
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                SizedBox(height: 0), // 半円をかぶせる余白を確保
                Expanded(
                  child: Center(
                    child: Container(
                      width: 320,
                      height: MediaQuery.of(context).size.height * 0.75,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black, width: 1),
                        //boxShadow: [BoxShadow(color: Colors.black, blurRadius: 1)],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...List.generate(24, (index) {
                              // ここでローカル変数として宣言
                              final scheduledTasks = getScheduledTasksForDay(
                                someday,
                                ref.read(taskControllerProvider),
                              );
                              final scheduled = scheduledTasks.firstWhereOrNull(
                                (st) => st.dateTime.hour == index,
                              );
                              // 配置中のタスクかどうか
                              final isTempPlaced = taskHourMap.containsKey(
                                index,
                              );

                              bool showDelete = false;
                              int showException = 0;

                              if (isTempPlaced) {
                                showDelete = true;
                                showException = 0;
                              } else if (scheduled != null) {
                                // リピートなしの通常タスク
                                if (scheduled.task.repete == RepeteType.none) {
                                  showDelete = true;
                                  showException = 0;
                                } else {
                                  // リピートありタスク → 編集時にだけ Exception 表示の判定へ
                                  if (scheduled.task.startTime != null) {
                                    showDelete = scheduled.task.startTime!.any(
                                      (dt) =>
                                          dt.year == someday.year &&
                                          dt.month == someday.month &&
                                          dt.day == someday.day &&
                                          dt.hour == index,
                                    );
                                  }
                                  // ① 編集中で、②リピートタスクで、③ exceptionフラグに応じて showException を設定
                                  if (isEdditing) {
                                    if (scheduled.exception) {
                                      // 例外ブロック (exception == true) だが、上に何も置かれていない場合だけ表示
                                      if (!taskHourMap.containsKey(index) &&
                                          scheduled.task.id == taskIDs[index]) {
                                        showException = 1;
                                        showDelete = true; // 例外ブロックは削除可能
                                      } else {
                                        showException = 0; // 上に別のタスクがあるなら非表示
                                      }
                                    } else {
                                      // 通常リピートとして出現しているもの (exception == false)
                                      showException = 2;
                                    }
                                  }
                                }
                              }

                              return InkWell(
                                key: _hourKeys[index], // 各時間帯のキーを設定
                                onTap:
                                    isEdditing
                                        ? () {
                                          setState(() {
                                            selectedHour = index;
                                          });
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                                _scrollToSelectedHour();
                                              });
                                        }
                                        : null,

                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  color:
                                      selectedHour == index
                                          ? Colors.grey[300]
                                          : Colors.transparent,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start, // 左寄せ
                                    children: [
                                      Text(
                                        '$index : 00',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      SizedBox(height: 6), // テキストと長方形の間にスペース
                                      Stack(
                                        children: [
                                          Container(
                                            width: double.infinity, // 横幅いっぱい
                                            height: 60, // 高さ60の長方形
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color:
                                                  selectedHour == index &&
                                                          timeColors[index] ==
                                                              Colors.white
                                                      ? Colors
                                                          .grey[300] // 選択されていて、色が白の場合
                                                      : timeColors[index], // 選択されていない場合はtaskの色
                                              // ボックスの色
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              //crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  taskTitles[index], // task名を表示！
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: textColors[index],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  //textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  taskComments[index], // comment(副題)を表示！
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: textColors[index],
                                                  ),
                                                  //textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (showException == 1)
                                            Positioned(
                                              left: 5,
                                              top: 5,
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.remove_circle_outline,
                                                  color: textColors[index],
                                                  size: 35,
                                                ),
                                                onPressed: () async {
                                                  await _removeExceptAtHour(
                                                    index,
                                                  );
                                                },
                                              ),
                                            ),

                                          if (showException == 2)
                                            Positioned(
                                              left: 5,
                                              top: 5,
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.remove_circle,
                                                  color: textColors[index],
                                                  size: 35,
                                                ),
                                                onPressed: () async {
                                                  await _addExceptAtHour(index);
                                                },
                                              ),
                                            ),

                                          if (isEdditing &&
                                              timeColors[index] !=
                                                  Colors.white &&
                                              showDelete)
                                            Positioned(
                                              right: 5,
                                              top: 5,
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: textColors[index],
                                                  size: 35,
                                                ),
                                                onPressed: () {
                                                  if (isEdditing &&
                                                      taskHourMap.containsKey(
                                                        index,
                                                      )) {
                                                    setNumTempoPlacedTask(
                                                      taskHourMap[index]!.id,
                                                    );
                                                    setState(() {
                                                      taskHourMap.remove(index);
                                                      selectedHour = null;
                                                    });
                                                  } else {
                                                    _removeScheduledAtHour(
                                                      index,
                                                    );
                                                    setState(() {
                                                      selectedHour = null;
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            Container(
                              // リストの下部に余白を確保
                              height: 330, // 好きな高さに
                              color: Colors.transparent, // あるいは Colors.white
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 半円をスクロールウィンドウにかぶせる
            Positioned(
              top: 0, // スクロールウィンドウにしっかりかぶるように調整
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left, size: 70, color: Colors.green),
                    onPressed: () async {
                      if (isEdditing && taskHourMap.isNotEmpty) {
                        final result = await showSaveDialog(context);
                        if (result == true) {
                          savePlacedTasks(
                            taskHourMap: taskHourMap,
                            date: someday,
                            ref: ref,
                            onCompleted: () {
                              setState(() {
                                _panelController.close();
                                selectedHour = null;
                                taskHourMap.clear();
                                isEdditing = false;
                                numTempoPlacedTask.updateAll((key, value) => 0);
                              });
                            },
                          );
                          countFromToday--;
                          _dateTransition();
                        } else if (result == false) {
                          // 保存せず仮置きmap初期化して移動
                          setState(() {
                            _panelController.close(); // パネルを閉じる
                            selectedHour = null;
                            taskHourMap.clear();
                            isEdditing = false;
                          });
                          countFromToday--;
                          _dateTransition();
                        } else {}
                      } else {
                        countFromToday--;
                        _dateTransition();
                      }
                    },
                  ),
                  ClipPath(
                    clipper: HalfMoonClipper(), // 修正したクリッパーを適用
                    child: Container(
                      width: 200, // 少し大きめに調整
                      height: 100, // 高さを調整
                      color:
                          Theme.of(
                            context,
                          ).colorScheme.inversePrimary, // 半円の背景色
                      child: Column(
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween, // 上下に配置
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // 横方向中央揃え
                        children: [
                          Text(
                            weekdayName[weekday], // 日付データ(曜日)を取得する！
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$day', // 日付けを表示
                            style: TextStyle(
                              fontSize: 43,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_right,
                      size: 70,
                      color: Colors.green,
                    ),
                    onPressed: () async {
                      if (isEdditing && taskHourMap.isNotEmpty) {
                        final result = await showSaveDialog(context);
                        if (result == true) {
                          // 保存してから移動

                          savePlacedTasks(
                            taskHourMap: taskHourMap,
                            date: someday,
                            ref: ref,
                            onCompleted: () {
                              setState(() {
                                _panelController.close();
                                selectedHour = null;
                                taskHourMap.clear();
                                isEdditing = false;
                                numTempoPlacedTask.updateAll((key, value) => 0);
                              });
                            },
                          );
                          countFromToday++;
                          _dateTransition();
                        } else if (result == false) {
                          // 保存せず仮置きmap初期化して移動
                          setState(() {
                            _panelController.close(); // パネルを閉じる
                            selectedHour = null;
                            taskHourMap.clear();
                            isEdditing = false;
                          });
                          countFromToday++;
                          _dateTransition();
                        } else {}
                      } else {
                        countFromToday++;
                        _dateTransition();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HalfMoonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0); // 下部の左端
    path.arcTo(
      Rect.fromCircle(
        center: Offset(size.width / 2, 0),
        radius: size.width / 2,
      ),
      0,
      3.14,
      false,
    ); // 半円を上向きに描画
    path.lineTo(size.width, 0); // 下部の右端へ
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
