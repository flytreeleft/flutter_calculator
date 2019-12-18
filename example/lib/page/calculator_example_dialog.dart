/*
 * Copyright (C) 2019 flytreeleft<flytreeleft@crazydan.org>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/material.dart';

import 'package:flutter_calculator/flutter_calculator.dart';

class CalculatorExampleDialogPage extends StatefulWidget {
  @override
  _CalculatorExampleDialogPageState createState() => _CalculatorExampleDialogPageState();
}

class _CalculatorExampleDialogPageState extends State<CalculatorExampleDialogPage> {
  final TextEditingController _textController = TextEditingController(text: '0.00');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    this._textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 20),
        const Text('Click the following text field to show the calculator:'),
        TextField(
          showCursor: false,
          readOnly: true,
          controller: this._textController,
          onTap: () => this._showCalculatorDialog(context),
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.bottom,
          style: TextStyle(
            fontSize: 14.0 * 3.0,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showCalculatorDialog(BuildContext context) async {
    final result = await showCalculator(context: context) ?? 0.00;

    this._textController.value = this._textController.value.copyWith(
          text: result.toStringAsFixed(2),
        );
  }
}
