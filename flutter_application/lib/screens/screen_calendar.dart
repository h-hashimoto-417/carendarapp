import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ScreenCalendar extends StatefulWidget {
  const ScreenCalendar({super.key});

  @override
  State<ScreenCalendar> createState() => _ScreenCalendarState();
}

class _ScreenCalendarState extends State<ScreenCalendar>{
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, String> _notes = {};

  void onDaySelected(DateTime selectedDay, DateTime focusedDay){
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _goToPreviousMonth(){
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
    });
  }

  void _goToNextMonth(){
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
    });
  }
void _editNote(BuildContext context, DateTime day) async {
    final oldNote = _notes[day] ?? '';
    final controller = TextEditingController(text: oldNote);

    final newNote = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${day.year}/${day.month}/${day.day} のメモ'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'メモを入力'),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (newNote != null) {
      setState(() {
        _notes[day] = newNote;
      });
    }
  }
  @override
  Widget build(BuildContext context){
    final selectedNote = _notes[_selectedDay ?? DateTime(2000)] ?? '';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1), 
      lastDay: DateTime.utc(2050, 12, 31),
      focusedDay: _focusedDay,
      locale: 'ja_JP',
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronVisible: false,
        rightChevronVisible: false,
      ),
      onPageChanged: (newFocusedDay){
        setState(() {
          _focusedDay = newFocusedDay;
        });
      },
      calendarBuilders: CalendarBuilders(
        headerTitleBuilder: (context, day){
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                  Text(
                    '${day.year}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ), 
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _goToPreviousMonth,
                  ),
                
                  Text(
                    '${day.month}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _goToNextMonth,
                  ),
                ],
              ),
           ],
          );
        },
      ),
      )
    );
  }
}