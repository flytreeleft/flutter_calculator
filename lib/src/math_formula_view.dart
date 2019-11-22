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

  MathFormula get _formula => this.widget.controller.formula;

  MathSymbol get _symbol => this.widget.controller._symbol;

  int get _charOffset => this._textController.value.selection.baseOffset;

  @override
  void initState() {
    super.initState();

    this._textController.addListener(this._handleTextEditingChanged);
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
    this._textController.removeListener(this._handleTextEditingChanged);
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

  void _handleTextEditingChanged() {
    // Only change cursor
    this._processMathSymbolAtCursor(null);
  }

  void _didProcessMathSymbol() {
    this._processMathSymbolAtCursor(this._symbol);

    this._textController.value = this._textController.value.copyWith(
          text: _stringifySymbols(this._formula.symbols),
          selection: TextSelection.collapsed(
            offset: _getCharOffsetByFormulaCursor(this._formula.symbols, this._formula.cursor),
          ),
        );
  }

  void _processMathSymbolAtCursor(MathSymbol symbol) {
    // The location of the char which is behind the cursor
    final cursor = _getFormulaCursorByCharOffset(this._formula.symbols, this._charOffset);

    this._formula.process(cursor, symbol);
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

String _stringifySymbols(List<MathSymbol> symbols) {
  String expr = symbols.map<String>((MathSymbol symbol) => stringifySymbol(symbol)).join();

  return expr.isEmpty ? '0' : expr;
}

int _getCharOffsetByFormulaCursor(List<MathSymbol> symbols, int cursor) {
  if (cursor == MathFormula.INVALID_CURSOR) {
    return 1;
  }

  return symbols
      .getRange(0, cursor + 1)
      .map<int>((MathSymbol symbol) => stringifySymbol(symbol).length)
      .reduce((total, v) => total + v);
}

int _getFormulaCursorByCharOffset(List<MathSymbol> symbols, int charOffset) {
  int charAt = charOffset - 1;
  if (charAt < 0 || symbols.isEmpty) {
    return MathFormula.INVALID_CURSOR;
  }

  int offset = -1;
  for (int i = 0; i < symbols.length; i++) {
    MathSymbol symbol = symbols[i];

    int leftSpace = (symbol.isOperator && !symbol.isSign && !symbol.isPercent) || symbol.isRightBracket ? 1 : 0;

    offset += leftSpace;
    if (charAt <= offset) {
      return i - (leftSpace > 0 ? 1 : 0);
    }

    int rightSpace = (symbol.isOperator && !symbol.isSign && !symbol.isPercent) || symbol.isLeftBracket ? 1 : 0;

    offset += symbol.text.length + rightSpace;
    if (charAt <= offset) {
      return i;
    }
  }

  return symbols.length - 1;
}
