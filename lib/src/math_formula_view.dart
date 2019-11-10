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

import './math_formula.dart';
import './math_symbol.dart';
import './auto_size_editable_text.dart';

class MathFormulaView extends StatefulWidget {
  final MathFormulaViewController controller;

  MathFormulaView(this.controller);

  @override
  State<StatefulWidget> createState() => _MathFormulaViewState();
}

class _MathFormulaViewState extends State<MathFormulaView> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();

    this.widget.controller._masterListener = this._didProcessMathSymbol;

    this._didProcessMathSymbol();
  }

  @override
  void didUpdateWidget(MathFormulaView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (this.widget.controller != oldWidget.controller) {
      oldWidget.controller._masterListener = null;
      this.widget.controller._masterListener = this._didProcessMathSymbol;
    }

    this._didProcessMathSymbol();
  }

  @override
  void dispose() {
    this.widget.controller._masterListener = null;
    this._textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AutoSizeEditableText(
      showCursor: true,
      readOnly: true,
      autofocus: true,
      maxLines: 4,
      focusNode: this._focusNode,
      controller: this._textController,
      minFontSize: 12.0,
      style: TextStyle(
        fontSize: 14.0 * 2.0,
        color: theme.primaryTextTheme.title.color,
      ),
      textAlign: TextAlign.right,
      cursorColor: Colors.grey,
      backgroundCursorColor: theme.focusColor,
    );
  }

  void _didProcessMathSymbol() {
    final MathFormula formula = this.widget.controller.formula;

    // The location of the char which is behind the cursor
    int charOffset = this._textController.value.selection.baseOffset;
    formula.moveCursorToCharOffset(charOffset);

    formula.process(this.widget.controller._symbol);

    this._textController.value = this._textController.value.copyWith(
          text: formula.expr,
          selection: TextSelection.collapsed(offset: formula.getCharOffsetAtCursor()),
        );
  }
}

class MathFormulaViewController extends ChangeNotifier {
  final MathFormula _formula;

  VoidCallback _masterListener;

  MathSymbol _symbol;

  MathFormulaViewController({String expr}) : this._formula = MathFormula(expr: expr);

  MathFormula get formula => this._formula;

  void process(MathSymbol symbol) {
    this._symbol = symbol;

    if (this._masterListener == null) {
      return;
    }

    this._masterListener();
    notifyListeners();
  }

  @override
  void dispose() {
    this._masterListener = null;

    super.dispose();
  }
}
