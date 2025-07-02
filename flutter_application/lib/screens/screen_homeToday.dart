import 'package:flutter/material.dart';
//import 'package:flutter_application/screens/screen_calendar.dart';
import 'package:flutter_application/models/model.dart';
import 'package:flutter_application/data/data_manager.dart';
import 'package:flutter_application/screens/screen_addtask.dart';
//import 'package:flutter_application/data/TaskManager.dart';
import 'package:flutter_application/data/database.dart';
import 'package:flutter_application/screens/screen_calendar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ScreenHomeToday extends ConsumerStatefulWidget {
  const ScreenHomeToday({super.key, required this.today});
  final DateTime today;

  @override
  ConsumerState<ScreenHomeToday> createState() => _ScreenHomeTodayState();
}

class _ScreenHomeTodayState extends ConsumerState<ScreenHomeToday> {
  //final DateTime today = widget.today;
  final PanelController _panelController = PanelController();
  bool isEdditing = false;
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

  //final taskProvider = ref.watch(taskControllerProvider);

  @override
  void initState() {
    super.initState();
    someday = widget.today;
    month = someday.month;
    day = someday.day;
    weekday = someday.weekday;
  }

  //@override
  void _dateTransition() {
    setState(() {
      //DateTime someday; // = widget.today.add(Duration(days: countFromToday));
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

  @override
  Widget build(BuildContext context) {
    // DateTime now = widget.today;
    // month = now.month;
    // day = now.day;
    // weekday = now.weekday;
    // build内にあるからbuildされるたびに毎回初期化される。

    final taskProvider = ref.watch(taskControllerProvider);
    final List<Task> notPlacedTasks = getNotPlacedTask(taskProvider);

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
      for (int i = 0; i < tasks.length; i++) {
        timeColors[tasks[i].dateTime.hour] = taskColors[tasks[i].task.color];
        taskTitles[tasks[i].dateTime.hour] = tasks[i].task.title;
        taskComments[tasks[i].dateTime.hour] = tasks[i].task.comment ?? '';
        if (tasks[i].task.color == 0 || tasks[i].task.color == 1) {
          textColors[tasks[i].dateTime.hour] = Colors.black;
        }
      }
    }

    taskblock();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.calendar_month, size: 45), // 左端のアイコン
          onPressed:
              () => {
                // カレンダーアイコンの動作を定義
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScreenCalendar()),
                ),
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

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => ScreenAddTask()),
              // );
            },
          ),
        ],
      ),

      // ボトムシートの表示
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: isEdditing ? 60 : 0,
        maxHeight: 350,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),

        // panel: PreferredSize(
        //   preferredSize: Size.fromHeight(30), // AppBar の高さ
        //   child: AppBar(
        //     automaticallyImplyLeading: false, // 戻るボタンなどを自動でつけない
        //     backgroundColor: Colors.white,
        //     elevation: 0,
        //     leading: IconButton(
        //       icon: Icon(Icons.save, size: 40, color: Colors.black),
        //       onPressed: () {
        //         _panelController.close();
        //         setState(() => isEdditing = false);
        //       },
        //     ),
        //     title: Text('編集中', style: TextStyle(color: Colors.black)),
        //     centerTitle: true,
        //     actions: [
        //       IconButton(
        //         icon: Icon(Icons.add_box,  size: 40, color: Colors.black),
        //         onPressed: () {
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(builder: (context) => ScreenAddTask()),
        //           );
        //         },
        //       ),
        //     ],
        //   ),
        // ),
        panel: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 50, // リボンの高さ
              decoration: BoxDecoration(
                color: Colors.grey[200], // リボンの色
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  //Spacer(),
                  IconButton(
                    icon: Icon(Icons.save, size: 40, color: Colors.blue),
                    onPressed: () {
                      _panelController.close(); // パネルを閉じる
                      setState(() {
                        isEdditing = false;
                      });
                    },
                  ),
                  Text(
                    '編集中',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_box, size: 40, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScreenAddTask(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white, // パネル全体の背景色
                child: SingleChildScrollView(
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: List.generate(notPlacedTasks.length, (index) {
                      return Padding(
                        padding: EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: taskColors[notPlacedTasks[index].color],
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            maximumSize: Size(80, 60), // 幅150, 高さ60
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular( 12, ), // ← ここで角丸を指定
                            ),
                          ),
                          child: Text(notPlacedTasks[index].title),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),

        // panel: Padding(
        //   padding: const EdgeInsets.all(16),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     mainAxisSize: MainAxisSize.min,

        //     children: [
        //       //Spacer(),
        //       IconButton(
        //         icon: Icon(Icons.save, size: 32, color: Colors.blue),
        //         onPressed: () {
        //           _panelController.close(); // パネルを閉じる
        //           setState(() {isEdditing = false;});
        //         },
        //       ),
        //       Text(
        //         '編集中',
        //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        //       ),
        //       IconButton(
        //         icon: Icon(Icons.add_box, size: 32, color: Colors.blue),
        //         onPressed: () {
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(builder: (context) => ScreenAddTask()),
        //           );
        //         },
        //       ),
        //     ],
        //   ),
        // ),

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
                      width: 350,
                      height: 690,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.black, width: 1),
                        //boxShadow: [BoxShadow(color: Colors.black, blurRadius: 1)],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...List.generate(
                              24,
                              (index) => Container(
                                padding: EdgeInsets.all(10),
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
                                    Container(
                                      width: double.infinity, // 横幅いっぱい
                                      height: 60, // 高さ60の長方形
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: timeColors[index], // ボックスの色
                                        borderRadius: BorderRadius.circular(7),
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
                                  ],
                                ),
                              ),
                            ),
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
                    icon: Icon(
                      Icons.arrow_left,
                      size: 70,
                      color: Colors.amberAccent,
                    ),
                    onPressed: () {
                      countFromToday--;
                      _dateTransition();
                      //taskblock();
                    },
                  ),
                  ClipPath(
                    clipper: HalfMoonClipper(), // 修正したクリッパーを適用
                    child: Container(
                      width: 200, // 少し大きめに調整
                      height: 100, // 高さを調整
                      color: const Color.fromARGB(255, 243, 194, 33),
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
                      color: Colors.amberAccent,
                    ),
                    onPressed: () {
                      countFromToday++;
                      //someday = now.add(Duration(days: countFromToday));
                      _dateTransition();
                      //taskblock();
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




// class ScreenCalendar extends HookConsumerWidget {
//   const ScreenCalendar({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final selectedDayState = useState(DateTime.now());
//     final focusedDayState = useState(DateTime.now());
    

//     void goToPreviousMonth() {
//       focusedDayState.value = DateTime(
//         focusedDayState.value.year,
//         focusedDayState.value.month - 1,
//       );
//     }

//     void goToNextMonth() {
//       focusedDayState.value = DateTime(
//         focusedDayState.value.year,
//         focusedDayState.value.month + 1,
//       );
//     }

//   return Scaffold(){};
//   }
// }