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

enum _MathSymbolType {
  number,
  operator,
  controller,
  bracket,
  left_bracket,
  right_bracket,
  function,
  decimal,
}

enum _MathSymbolCombination {
  left,
  right,
}

double _opPlus(a, b) => a + b;

double _opMinus(a, b) => a - b;

double _opMultiply(a, b) => a * b;

double _opDivide(a, b) => a / b;

double _opSign(a) => -a;

double _opPercent(a) => a * 0.01;

const _visibleSymbols = [
  MathSymbols.plus,
  MathSymbols.minus,
  MathSymbols.multiply,
  MathSymbols.divide,
  MathSymbols.sign,
  MathSymbols.percent,
  MathSymbols.left_bracket,
  MathSymbols.right_bracket,
  MathSymbols.decimal,
  MathSymbols.zero,
  MathSymbols.one,
  MathSymbols.two,
  MathSymbols.three,
  MathSymbols.four,
  MathSymbols.five,
  MathSymbols.six,
  MathSymbols.seven,
  MathSymbols.eight,
  MathSymbols.nine,
];

abstract class MathSymbols {
  // Controllers
  static const MathSymbol clear = const MathSymbol('C', _MathSymbolType.controller);
  static const MathSymbol delete = const MathSymbol('Del', _MathSymbolType.controller);
  static const MathSymbol redo = const MathSymbol('Redo', _MathSymbolType.controller);
  static const MathSymbol undo = const MathSymbol('Undo', _MathSymbolType.controller);
  static const MathSymbol equals = const MathSymbol('=', _MathSymbolType.controller);

  // Operators
  static const MathSymbol plus = const MathOperatorSymbol('+', _MathSymbolCombination.left, _opPlus, 2, 0);
  static const MathSymbol minus = const MathOperatorSymbol('-', _MathSymbolCombination.left, _opMinus, 2, 0);
  static const MathSymbol multiply = const MathOperatorSymbol('×', _MathSymbolCombination.left, _opMultiply, 2, 10);
  static const MathSymbol divide = const MathOperatorSymbol('÷', _MathSymbolCombination.left, _opDivide, 2, 10);
  static const MathSymbol sign = const MathOperatorSymbol('±', _MathSymbolCombination.right, _opSign, 1, 20);
  static const MathSymbol percent = const MathOperatorSymbol('%', _MathSymbolCombination.left, _opPercent, 1, 30);

  // Brackets
  static const MathSymbol bracket = const MathSymbol('( )', _MathSymbolType.bracket);
  static const MathSymbol left_bracket = const MathSymbol('(', _MathSymbolType.left_bracket);
  static const MathSymbol right_bracket = const MathSymbol(')', _MathSymbolType.right_bracket);

  // Functions
  // ...

  // Decimal
  static const MathSymbol decimal = const MathSymbol('.', _MathSymbolType.decimal);

  // Numbers
  static const MathSymbol zero = const MathSymbol('0', _MathSymbolType.number);
  static const MathSymbol one = const MathSymbol('1', _MathSymbolType.number);
  static const MathSymbol two = const MathSymbol('2', _MathSymbolType.number);
  static const MathSymbol three = const MathSymbol('3', _MathSymbolType.number);
  static const MathSymbol four = const MathSymbol('4', _MathSymbolType.number);
  static const MathSymbol five = const MathSymbol('5', _MathSymbolType.number);
  static const MathSymbol six = const MathSymbol('6', _MathSymbolType.number);
  static const MathSymbol seven = const MathSymbol('7', _MathSymbolType.number);
  static const MathSymbol eight = const MathSymbol('8', _MathSymbolType.number);
  static const MathSymbol nine = const MathSymbol('9', _MathSymbolType.number);
}

class MathSymbol {
  final String text;
  final _MathSymbolType _type;

  const MathSymbol(this.text, this._type);

  bool get isController => this._type == _MathSymbolType.controller;

  bool get isOperator => this._type == _MathSymbolType.operator;

  bool get isFunction => this._type == _MathSymbolType.function;

  bool get isLeftBracket => this._type == _MathSymbolType.left_bracket;

  bool get isRightBracket => this._type == _MathSymbolType.right_bracket;

  bool get isBracket => this.isLeftBracket || this.isRightBracket;

  bool get isDecimal => this._type == _MathSymbolType.decimal;

  bool get isNumber => this._type == _MathSymbolType.number;

  bool get isSign => this == MathSymbols.sign;

  bool get isPercent => this == MathSymbols.percent;

  @override
  String toString() => this.text;
}

class MathOperatorSymbol extends MathSymbol {
  final _MathSymbolCombination combination;
  final Function fn;
  final int fnArgs;
  final int priority;

  const MathOperatorSymbol(String value, this.combination, this.fn, this.fnArgs, this.priority)
      : super(value, _MathSymbolType.operator);

  bool get isLeftCombination => this.combination == _MathSymbolCombination.left;

  bool get isRightCombination => this.combination == _MathSymbolCombination.right;
}

List<MathSymbol> parseFormula(String formula) {
  List<MathSymbol> symbols = <MathSymbol>[];

  for (int i = 0; i < (formula ?? '').length; i++) {
    String text = formula[i];
    MathSymbol key = _visibleSymbols.firstWhere((key) => key.text == text, orElse: () => null);

    if (key != null) {
      symbols.add(key);
    }
  }
  return symbols;
}
