import 'package:flutter/material.dart';
import 'package:flutter_application/screens/screen_home_today.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


Future<void> main() async{
  await initializeDateFormatting('ja_JP').then(
    (_){
      runApp(
       const ProviderScope(
         child: MyApp(),
        ),
      );
    }
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
      ),
      debugShowCheckedModeBanner: false,
      home: ScreenHomeToday(today: DateTime.now(), editmode: false,),
      );
  }
}