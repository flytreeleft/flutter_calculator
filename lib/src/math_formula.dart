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

import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import './math_symbol.dart';
import './math_formula_validator.dart';
import './math_formula_evaluator.dart';

String stringifySymbol(MathSymbol symbol) {
  if (symbol.isOperator && !symbol.isSign && !symbol.isPercent) {
    return ' ${symbol.text} ';
  }

  return symbol.isLeftBracket ? '${symbol.text} ' : symbol.isRightBracket ? ' ${symbol.text}' : symbol.text;
}

class MathFormula {
  static const int INVALID_CURSOR = -1;

  final List<_History> _undoHistories = [];
  final List<_History> _redoHistories = [];

  List<MathSymbol> _symbols;
  MathFormulaValidator _validator;
  MathFormulaEvaluator _evaluator;

  int _cursor = INVALID_CURSOR;

  MathFormula({expr}) : this._symbols = parseFormula(expr) {
    this._validator = MathFormulaValidator(this);
    this._evaluator = MathFormulaEvaluator(this);
  }

  int get cursor => this._cursor;

  List<MathSymbol> get symbols => [...this._symbols];

  @override
  String toString() {
    return this._symbols.map<String>((MathSymbol symbol) => stringifySymbol(symbol)).join();
  }

  void process(int cursor, MathSymbol symbol) {
    switch (symbol) {
      case MathSymbols.redo:
        return this.redo();
      case MathSymbols.undo:
        return this.undo();
      case MathSymbols.equals:
        return;
    }

    int oldCursor = this._cursor;
    List<MathSymbol> oldSymbols = [...this._symbols];

    this._cursor = cursor;
    switch (symbol) {
      case MathSymbols.clear:
        this._clearAllSymbols();
        break;
      case MathSymbols.delete:
        this._deleteSymbolAtCursor();
        break;
      default:
        this._addSymbolAtCursor(symbol);
    }

    this._recordHistory(oldCursor, oldSymbols);
  }

  double evaluate() {
    return this._evaluator.evaluate();
  }

  void redo() {
    if (!this.canRedo()) {
      return;
    }

    // Record current state
    this._undoHistories.add(_History(this._cursor, [...this._symbols]));

    // Revert to previous state
    _History history = this._redoHistories.removeLast();
    this._applyHistory(history);
  }

  bool canRedo() => this._redoHistories.isNotEmpty;

  void undo() {
    if (!this.canUndo()) {
      return;
    }

    // Record current state
    this._redoHistories.add(_History(this._cursor, [...this._symbols]));

    // Revert to previous state
    _History history = this._undoHistories.removeLast();
    this._applyHistory(history);
  }

  bool canUndo() => this._undoHistories.isNotEmpty;

  List<MathSymbol> getSymbols(int start, {int end: -1}) {
    return this._symbols.getRange(start, end == -1 ? this._symbols.length : end);
  }

  MathSymbol getSymbol(int index) {
    return index < 0 || index >= this._symbols.length ? null : this._symbols.elementAt(index);
  }

  MathSymbol getLeftSymbol(int index) {
    return index <= 0 || index >= this._symbols.length ? null : this.getSymbol(index - 1);
  }

  MathSymbol getRightSymbol(int index) {
    return index < 0 || index >= this._symbols.length - 1 ? null : this.getSymbol(index + 1);
  }

  void _applyHistory(_History history) {
    if (history._cursor != null) {
      this._cursor = history._cursor;
    }

    if (history._symbols != null) {
      this._symbols = [...history._symbols];
    }
  }

  void _recordHistory(int oldCursor, List<MathSymbol> oldSymbols) {
    bool cursorEquals = oldCursor == this._cursor;
    bool symbolsEquals = listEquals(oldSymbols, this._symbols);

    if (cursorEquals && symbolsEquals) {
      return;
    }

    this._redoHistories.clear();
    this._undoHistories.add(_History(
          cursorEquals ? null : oldCursor,
          symbolsEquals ? null : oldSymbols,
        ));
  }

  void _clearAllSymbols() {
    this._symbols.clear();
    this._cursor = INVALID_CURSOR;
  }

  void _addSymbolAtCursor(MathSymbol symbol) {
    if (!this._validator.isAccepted(this.cursor, symbol)) {
      return;
    }

    switch (symbol) {
      case MathSymbols.bracket:
        this._insertBracketSymbolAtCursor();
        break;
      default:
        this._insertSymbolAtCursor(symbol);
    }
  }

  void _deleteSymbolAtCursor() {
    MathSymbol currentSymbol = this.getSymbol(this.cursor);
    if (currentSymbol == null) {
      return;
    }

    switch (currentSymbol) {
      case MathSymbols.right_bracket:
        this._removeRightBracketSymbolAtCursor();
        break;
      case MathSymbols.left_bracket:
        MathSymbol rightSymbol = this.getRightSymbol(this.cursor);

        if (rightSymbol == null) {
          this._removeSymbolAtCursor();
        } else if (rightSymbol.isRightBracket) {
          this._cursor += 1;
          this._removeRightBracketSymbolAtCursor();
        }
        break;
      default:
        this._removeSymbolAtCursor();
    }
  }

  void _insertSymbolAtCursor(MathSymbol symbol) {
    this._symbols.insert(this.cursor + 1, symbol);
    this._cursor += 1;
  }

  void _removeSymbolAtCursor() {
    this._symbols.removeAt(this.cursor);
    this._cursor -= 1;
  }

  void _insertBracketSymbolAtCursor() {
    this._symbols.insert(this.cursor + 1, MathSymbols.left_bracket);
    this._cursor += 1;
    this._symbols.insert(this.cursor + 1, MathSymbols.right_bracket);
  }

  void _removeRightBracketSymbolAtCursor() {
    int index = this.cursor - 1;

    List<MathSymbol> rightBrackets = <MathSymbol>[];

    while (index >= 0) {
      MathSymbol symbol = this.getSymbol(index);

      if (symbol.isRightBracket) {
        rightBrackets.add(symbol);
      } else if (symbol.isLeftBracket) {
        if (rightBrackets.isNotEmpty) {
          rightBrackets.removeLast();
        } else {
          break;
        }
      }

      index -= 1;
    }

    this._symbols.removeRange(math.max(0, index), this.cursor + 1);
    this._cursor = index - 1;
  }
}

class _History {
  final List<MathSymbol> _symbols;
  final int _cursor;

  _History(this._cursor, this._symbols);
}
