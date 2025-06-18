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
          '6月',  // 日付データを取得する！
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
                      border: Border.all(color:Colors.black, width: 1),
                      //boxShadow: [BoxShadow(color: Colors.black, blurRadius: 1)],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(25, (index) => Padding(
                          padding: EdgeInsets.all(25),
                          child: Align( 
                            alignment: Alignment.topLeft,
                            child: Text('$index : 00',),
                        ))),
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
                  icon: Icon(Icons.arrow_left, size: 70, color: Colors.amberAccent),
                  onPressed: () {},
                ),
                ClipPath(
                  clipper: HalfMoonClipper(), // 修正したクリッパーを適用
                  child: Container(
                    width: 200, // 少し大きめに調整
                    height: 100, // 高さを調整
                    color: const Color.fromARGB(255, 243, 194, 33),
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween, // 上下に配置
                      crossAxisAlignment: CrossAxisAlignment.center, // 横方向中央揃え
                      children: [
                        Text(
                          "WED", // 日付データを取得する！
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "25",
                          style: TextStyle(fontSize: 43, fontWeight: FontWeight.bold),
                        ),

                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right, size: 70, color: Colors.amberAccent),
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
    path.moveTo(0, 0); // 下部の左端
    path.arcTo(Rect.fromCircle(center: Offset(size.width / 2, 0), radius: size.width / 2), 0, 3.14, false); // 半円を上向きに描画
    path.lineTo(size.width, 0); // 下部の右端へ
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

