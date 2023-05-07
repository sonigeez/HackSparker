import 'package:flutter/material.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevQuiz',
      home: Scaffold(
        appBar: AppBar(
          title: Text('DevQuiz'),
        ),
        body: Container(
          child: Center(
            child: Text('Hello World'),
          ),
        ),
      ),
    );
  }
}
