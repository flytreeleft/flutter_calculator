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

import './math_symbol.dart';
import './math_formula.dart';

class MathFormulaEvaluator {
  final MathFormula _formula;

  MathFormulaEvaluator(MathFormula formula) : this._formula = formula;

  double evaluate() {
    try {
      return this._doEvaluate(this._formula.symbols);
    } catch (e) {
      print(e);
      return 0.0;
    }
  }

  // https://zh.wikipedia.org/wiki/%E9%80%86%E6%B3%A2%E5%85%B0%E8%A1%A8%E7%A4%BA%E6%B3%95
  double _doEvaluate(List<MathSymbol> symbols) {
    if (symbols.isEmpty) {
      return 0.0;
    }

    List<_Mark> rpnMarks = _parseRPN(symbols);
    List<double> valueStack = [];

    for (int i = 0; i < rpnMarks.length; i++) {
      _Mark mark = rpnMarks[i];

      if (mark.isNumber) {
        valueStack.add(mark.toNumber());
      } else {
        MathOperatorSymbol operator = mark.symbols.first;
        List<double> operands = [];

        for (int j = operator.fnArgs; valueStack.isNotEmpty && j > 0; j--) {
          double number = valueStack.removeLast();
          operands.add(number);
        }

        if (operands.length != operator.fnArgs) {
          throw 'Expected ${operator.fnArgs} operands in stack, but got ${operands.length}';
        } else {
          double number = Function.apply(operator.fn, operands.reversed.toList());
          valueStack.add(number);
        }
      }
    }

    if (valueStack.length == 1) {
      return valueStack[0];
    } else {
      throw 'Has extra operators';
    }
  }

  // https://zh.wikipedia.org/wiki/%E8%B0%83%E5%BA%A6%E5%9C%BA%E7%AE%97%E6%B3%95
  List<_Mark> _parseRPN(List<MathSymbol> symbols) {
    List<_Mark> output = [];
    List<_Mark> opsStack = [];

    for (int i = 0; i < symbols.length; i++) {
      MathSymbol symbol = symbols[i];

      if (symbol.isNumber || symbol.isDecimal) {
        _Mark mark = _readNumber(symbols, i);
        output.add(mark);
        i += mark.symbols.length - 1;
      }
      // Process operator
      else if (symbol.isOperator) {
        _Mark top;
        while ((top = opsStack.length > 0 ? opsStack.last : null) != null &&
            top.isOperator &&
            this._needToPopupMark(top, symbol)) {
          opsStack.removeLast();
          output.add(top);
        }

        opsStack.add(_Mark(i, _MarkType.operator, [symbol]));
      }
      // Process left bracket
      else if (symbol.isLeftBracket) {
        opsStack.add(_Mark(i, _MarkType.bracket, [symbol]));
      }
      // Process right bracket
      else if (symbol.isRightBracket) {
        _Mark top;
        while ((top = opsStack.length > 0 ? opsStack.last : null) != null && (top.isOperator || !top.isLeftBracket)) {
          opsStack.removeLast();
          output.add(top);
        }

        if (top == null) {
          throw 'No matched left bracket';
        } else if (top.isLeftBracket) {
          opsStack.removeLast();
        }
      }
    }

    _Mark top;
    while ((top = opsStack.length > 0 ? opsStack.last : null) != null) {
      if (top.isLeftBracket) {
        throw 'No matched right bracket';
      } else if (top.isRightBracket) {
        throw 'No matched left bracket';
      } else {
        opsStack.removeLast();
        output.add(top);
      }
    }

    return output;
  }

  _Mark _readNumber(List<MathSymbol> symbols, int startIndex) {
    List<MathSymbol> numbers = [];

    bool hasDot = false;
    for (int i = startIndex; i < symbols.length; i++) {
      MathSymbol symbol = symbols[i];

      if (symbol.isDecimal) {
        if (hasDot) {
          throw 'Has Dot';
        }
        hasDot = true;
      } else if (!symbol.isNumber) {
        break;
      }
      numbers.add(symbol);
    }

    if (numbers.length == 1 && numbers.first.isDecimal) {
      throw 'Only A Dot';
    }

    return _Mark(startIndex, _MarkType.number, numbers);
  }

  bool _needToPopupMark(_Mark topMark, MathOperatorSymbol currentSymbol) {
    MathOperatorSymbol topSymbol = topMark.symbols.first;

    return (currentSymbol.isLeftCombination && currentSymbol.priority <= topSymbol.priority) ||
        (currentSymbol.isRightCombination && currentSymbol.priority < topSymbol.priority);
  }
}

enum _MarkType {
  number,
  operator,
  bracket,
}

class _Mark {
  final int index;
  final _MarkType type;
  final List<MathSymbol> symbols;

  const _Mark(this.index, this.type, this.symbols);

  bool get isNumber => this.type == _MarkType.number;

  bool get isOperator => this.type == _MarkType.operator;

  bool get isLeftBracket => this.symbols.first.isLeftBracket;

  bool get isRightBracket => this.symbols.first.isRightBracket;

  bool get isBracket => this.type == _MarkType.bracket;

  double toNumber() => this.isNumber ? double.parse(toString()) : 0;

  @override
  String toString() {
    if (this.isNumber) {
      List<MathSymbol> list = [...this.symbols];

      if (list.first.isDecimal) {
        list.insert(0, MathSymbols.zero);
      } else if (list.last.isDecimal) {
        list.add(MathSymbols.zero);
      }

      return list.join();
    }
    return this.symbols.join();
  }
}
