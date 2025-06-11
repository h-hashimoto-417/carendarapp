import 'package:flutter/material.dart';


class ScreenHomeToday extends StatefulWidget {
  const ScreenHomeToday({super.key});

  @override
  State<ScreenHomeToday> createState() => _ScreenHomeTodayState();
}


class _ScreenHomeTodayState extends State<ScreenHomeToday> {
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.calendar_month), // 左端のアイコン
          onPressed: () {      // カレンダーアイコンの動作を定義
          },
        ),
        title: Text(
          '6月',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
           IconButton(
             icon: const Icon(Icons.edit_note), // 右端のアイコン
             onPressed: () {
              // 編集アイコンの動作を定義
             },
            ),
        ],
      ),

      body: Center(
        child: Container(
          width: 300, // ウィンドウの幅
          height: 400, // ウィンドウの高さ
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(20, (index) => Padding(
                padding: EdgeInsets.all(10),
                child: Text('Item $index'),
              )),
            ),
          ),
        ),
      ),
    );

  }
}

