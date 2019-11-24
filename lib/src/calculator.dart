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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import './math_symbol.dart';
import './math_formula_view.dart';
import './keypad.dart';
import './auto_size_editable_text.dart';

class Calculator extends StatefulWidget {
  final String expr;

  Calculator({this.expr});

  @override
  State<StatefulWidget> createState() => _CalculatorState(this.expr);
}

class _CalculatorState extends State<Calculator> {
  final MathFormulaViewController _formulaViewController;

  final KeyPadController _keyPadController = KeyPadController([MathSymbols.undo, MathSymbols.redo]);
  final TextEditingController _formulaResultController = TextEditingController();

  _CalculatorState(expr) : this._formulaViewController = MathFormulaViewController(expr: expr);

  @override
  void initState() {
    super.initState();

    this._formulaViewController.addListener(this._handleFormulaUpdated);

    this._handleFormulaUpdated();
  }

  @override
  void didUpdateWidget(Calculator oldWidget) {
    super.didUpdateWidget(oldWidget);

    this._handleFormulaUpdated();
  }

  @override
  void dispose() {
    this._formulaViewController.dispose();
    this._keyPadController.dispose();
    this._formulaResultController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    double height = MediaQuery.of(context).size.height / 2.5;

    return Theme(
      data: theme.copyWith(
        dialogBackgroundColor: Colors.transparent,
      ),
      child: Dialog(
        child: Container(
          color: theme.dialogBackgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12.0),
                color: theme.primaryColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    MathFormulaView(this._formulaViewController),
                    AutoSizeEditableText(
                      readOnly: true,
                      autofocus: false,
                      maxLines: 1,
                      focusNode: FocusNode(),
                      controller: this._formulaResultController,
                      minFontSize: 14.0,
                      style: TextStyle(
                        fontSize: 14.0 * 3.0,
                        color: theme.primaryTextTheme.title.color,
                      ),
                      textAlign: TextAlign.right,
                      cursorColor: Colors.grey,
                      backgroundCursorColor: theme.focusColor,
                    ),
                  ],
                ),
              ),
              Container(
                height: height,
                child: KeyPad(
                  controller: this._keyPadController,
                  onPress: this._handlePressedKey,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 1.0, color: theme.dividerColor),
                  ),
                ),
                child: ButtonTheme.bar(
                  child: ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: this._handleCancel,
                      ),
                      FlatButton(
                        child: Text('OK'),
                        onPressed: this._handleOk,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOk() {
    Navigator.pop(context, this._formulaViewController.formula.evaluate());
  }

  void _handlePressedKey(MathSymbol symbol) {
    this._formulaViewController.process(symbol);

    List<MathSymbol> disabledKeys = [];
    if (!this._formulaViewController.formula.canUndo()) {
      disabledKeys.add(MathSymbols.undo);
    }
    if (!this._formulaViewController.formula.canRedo()) {
      disabledKeys.add(MathSymbols.redo);
    }

    this._keyPadController.disableKeys(disabledKeys);
  }

  void _handleFormulaUpdated() {
    final double result = this._formulaViewController.formula.evaluate();

    this._formulaResultController.value = this._formulaResultController.value.copyWith(
          text: "= ${result?.toString() ?? '0.0'}",
        );
  }
}

Future<double> showCalculator({
  @required BuildContext context,
  String expr,
  Locale locale,
  TextDirection textDirection,
  TransitionBuilder builder,
}) async {
  assert(context != null);

  Widget child = Calculator(
    expr: expr,
  );

  if (textDirection != null) {
    child = Directionality(
      textDirection: textDirection,
      child: child,
    );
  }

  if (locale != null) {
    child = Localizations.override(
      context: context,
      locale: locale,
      child: child,
    );
  }

  return await showDialog<double>(
    context: context,
    builder: (BuildContext context) {
      return builder == null ? child : builder(context, child);
    },
  );
}
