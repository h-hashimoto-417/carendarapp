import 'package:flutter/material.dart';


class ScreenHomeToday extends StatefulWidget {
  const ScreenHomeToday({super.key});

  @override
  State<ScreenHomeToday> createState() => _ScreenHomeTodayState();
}


class _ScreenHomeTodayState extends State<ScreenHomeToday> {
  String  month = '';

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.calendar_month, size: 45), // 左端のアイコン
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
             icon: const Icon(Icons.edit_note, size: 45), // 右端のアイコン
             onPressed: () {
              // 編集アイコンの動作を定義
             },
            ),
        ],
      ),

      // body: Center(
      //   child: Container(
      //     width: 350,
      //     height: 600,
      //     decoration: BoxDecoration(
      //       color: Colors.white,
      //       borderRadius: BorderRadius.circular(10),
      //       boxShadow: [BoxShadow(color: Colors.black, blurRadius: 1)],
      //     ),
      //     child: ListView.builder(
      //       itemCount: 24,
      //       itemBuilder: (context, index) => Padding(
      //         padding: EdgeInsets.all(10),
      //         child: Text('Item $index'),
      //       ),
      //     ),
      //   ),
      // ),

      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 50), // 半円をかぶせる余白を確保
              Expanded(
                child: Center(
                  child: Container(
                    width: 300,
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black, blurRadius: 1)],
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
              ),
            ],
          ),

          // 半円をスクロールウィンドウにかぶせる
          Positioned(
            top: 5, // スクロールウィンドウにしっかりかぶるように調整
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_left, size: 60, color: Colors.amberAccent),
                  onPressed: () {},
                ),
                ClipPath(
                  clipper: HalfMoonClipper(), // 修正したクリッパーを適用
                  child: Container(
                    width: 120, // 少し大きめに調整
                    height: 60, // 高さを調整
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right, size: 60, color: Colors.amberAccent),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      )

    );

  }
}

class HalfMoonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height); // 下部の左端
    path.arcTo(Rect.fromLTWH(0, 0, size.width, size.height * 2), 0, -3.14, false); // 半円を上向きに描画
    path.lineTo(size.width, size.height); // 下部の右端へ
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

