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

import './math_symbol.dart';

String stringifySymbol(MathSymbol symbol) {
  if (symbol.isOperator && !symbol.isSign && !symbol.isPercent) {
    return ' ${symbol.text} ';
  }

  return symbol.isLeftBracket ? '${symbol.text} ' : symbol.isRightBracket ? ' ${symbol.text}' : symbol.text;
}

class MathFormulaValidation {}

final random = math.Random();

class MathFormula {
  static const int INVALID_CURSOR = -1;

  final List<MathSymbol> _symbols;

  int _cursor = INVALID_CURSOR;

  MathFormula({expr}) : this._symbols = parseFormula(expr);

  int get cursor => this._cursor;

  List<MathSymbol> get symbols => [...this._symbols];

  @override
  String toString() {
    return this._symbols.map<String>((MathSymbol symbol) => stringifySymbol(symbol)).join();
  }

  void process(int cursor, MathSymbol symbol) {
    this._cursor = cursor;

    switch (symbol) {
      case MathSymbols.clear:
        this.clear();
        break;
      case MathSymbols.delete:
        this._deleteSymbolAtCursor();
        break;
      case MathSymbols.redo:
        this.redo();
        break;
      case MathSymbols.undo:
        this.undo();
        break;
      case MathSymbols.equals:
        break;
      default:
        this._addSymbolAtCursor(symbol);
    }
  }

  double evaluate() {
    // TODO if get an invalid result, just return `null`
    return random.nextDouble();
  }

  void clear() {
    this._symbols.clear();
    this._cursor = INVALID_CURSOR;
    // TODO record cursor and cleared symbols
  }

  void redo() {
    // TODO revert symbol and move cursor
  }

  bool canRedo() => false;

  void undo() {
    // TODO revert redo and move cursor
  }

  bool canUndo() => false;

  void _addSymbolAtCursor(MathSymbol symbol) {
    // TODO record cursor and added symbol
    if (!this._isAccepted(this.cursor, symbol)) {
      return;
    }

    switch (symbol) {
      case MathSymbols.bracket:
        this._insertSymbolAtCursor(MathSymbols.left_bracket);
        this._insertSymbolAtCursor(MathSymbols.right_bracket);
        this._cursor -= 1;
        break;
      default:
        this._insertSymbolAtCursor(symbol);
    }
  }

  void _deleteSymbolAtCursor() {
    // TODO record cursor and deleted symbol
    MathSymbol currentSymbol = this._getSymbol(this.cursor);
    if (currentSymbol == null) {
      return;
    }

    switch (currentSymbol) {
      case MathSymbols.right_bracket:
        this._removeRightBracketSymbolAtCursor();
        break;
      case MathSymbols.left_bracket:
        MathSymbol rightSymbol = this._getRightSymbol(this.cursor);

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

  bool _isAccepted(int index, MathSymbol symbol) {
    if (symbol == null) {
      return false;
    }
    return true;
  }

  MathSymbol _lastSymbol() {
    return this._symbols.isNotEmpty ? this._symbols.last : null;
  }

  MathSymbol _getSymbol(int index) {
    return index < 0 || index >= this._symbols.length ? null : this._symbols.elementAt(index);
  }

  MathSymbol _getLeftSymbol(int index) {
    return index <= 0 || index >= this._symbols.length ? null : this._getSymbol(index - 1);
  }

  MathSymbol _getRightSymbol(int index) {
    return index < 0 || index >= this._symbols.length - 1 ? null : this._getSymbol(index + 1);
  }

  void _insertSymbolAtCursor(MathSymbol symbol) {
    this._symbols.insert(this.cursor + 1, symbol);
    this._cursor += 1;
  }

  void _removeSymbolAtCursor() {
    this._symbols.removeAt(this.cursor);
    this._cursor -= 1;
  }

  void _removeRightBracketSymbolAtCursor() {
    int index = this.cursor - 1;

    List<MathSymbol> rightBrackets = <MathSymbol>[];

    while (index >= 0) {
      MathSymbol symbol = this._getSymbol(index);

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
