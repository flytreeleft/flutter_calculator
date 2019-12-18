import 'package:flutter/material.dart';

import './page/calculator_example.dart';

void main() => runApp(FlutterCalculatorExample());

class FlutterCalculatorExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calculator Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Calculator Example'),
        ),
        body: CalculatorExamplePage(),
      ),
    );
  }
}
