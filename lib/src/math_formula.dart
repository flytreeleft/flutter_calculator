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
  if (symbol.isOperator) {
    return ' ${symbol.text} ';
  }

  return symbol.isLeftBracket ? '${symbol.text} ' : symbol.isRightBracket ? ' ${symbol.text}' : symbol.text;
}

class MathFormulaValidation {}

class MathFormula {
  static const int _INVALID_CURSOR = -1;

  final List<MathSymbol> _symbols;

  int _cursor = _INVALID_CURSOR;

  MathFormula({expr}) : this._symbols = parseFormula(expr);

  int get cursor => this._cursor;

  String get expr {
    String expr = this._symbols.map<String>((MathSymbol symbol) => stringifySymbol(symbol)).join();

    return expr.isEmpty ? '0' : expr;
  }

  void process(MathSymbol symbol) {
    switch (symbol) {
      case MathSymbols.clear:
        this.clear();
        break;
      case MathSymbols.delete:
        this.deleteSymbolAtCursor();
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
        this.addSymbolAtCursor(symbol);
    }
  }

  double evaluate() {
    // TODO if get an invalid result, just return `null`
    return null;
  }

  void clear() {
    this._symbols.clear();
    this._cursor = _INVALID_CURSOR;
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

  int getCharOffsetAtCursor() {
    if (this.cursor == _INVALID_CURSOR) {
      return 1;
    }

    return this
        ._symbols
        .getRange(0, this.cursor + 1)
        .map<int>((MathSymbol symbol) => stringifySymbol(symbol).length)
        .reduce((total, v) => total + v);
  }

  void moveCursorToCharOffset(int charOffset) {
    this._cursor = this.getCursorToCharOffset(charOffset);
  }

  void addSymbolAtCursor(MathSymbol symbol) {
    // TODO record cursor and added symbol
    if (!this.isAccepted(this.cursor, symbol)) {
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

  void deleteSymbolAtCursor() {
    // TODO record cursor and deleted symbol
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

  int getCursorToCharOffset(int charOffset) {
    int charAt = charOffset - 1;
    if (charAt < 0 || this._symbols.isEmpty) {
      return _INVALID_CURSOR;
    }

    int offset = -1;
    for (int i = 0; i < this._symbols.length; i++) {
      MathSymbol symbol = this._symbols[i];

      int leftSpace = symbol.isOperator || symbol.isRightBracket ? 1 : 0;

      offset += leftSpace;
      if (charAt <= offset) {
        return i - (leftSpace > 0 ? 1 : 0);
      }

      int rightSpace = symbol.isOperator || symbol.isLeftBracket ? 1 : 0;

      offset += symbol.text.length + rightSpace;
      if (charAt <= offset) {
        return i;
      }
    }

    return this._symbols.length - 1;
  }

  bool isAccepted(int index, MathSymbol symbol) {
    if (symbol == null) {
      return false;
    }
    return true;
  }

  MathSymbol lastSymbol() {
    return this._symbols.isNotEmpty ? this._symbols.last : null;
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
