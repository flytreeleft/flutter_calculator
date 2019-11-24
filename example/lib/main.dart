import 'package:flutter/material.dart';

import 'package:flutter_calculator/flutter_calculator.dart';

void main() => runApp(FlutterCalculatorExample());

class FlutterCalculatorExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calculator Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Flutter Calculator Example'),
    );
  }
}

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({Key key, this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController(text: '0.00');

  @override
  void initState() {
    this._focusNode.addListener(this._showCalculatorDialog);

    super.initState();
  }

  @override
  void dispose() {
    this._focusNode.removeListener(this._showCalculatorDialog);
    this._textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),
          const Text('Click the following text field to show the calculator:'),
          TextField(
            showCursor: false,
            readOnly: true,
            focusNode: this._focusNode,
            controller: this._textController,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.bottom,
            style: TextStyle(
              fontSize: 14.0 * 3.0,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showCalculatorDialog() async {
    if (!this._focusNode.hasFocus) {
      return;
    }

    final result = await showCalculator(context: this.context);

    this._textController.value = this._textController.value.copyWith(
          text: result?.toString() ?? '0.00',
        );
  }
}
