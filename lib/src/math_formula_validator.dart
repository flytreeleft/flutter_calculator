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

class MathFormulaValidator {
  final MathFormula _formula;

  MathFormulaValidator(MathFormula formula) : this._formula = formula;

  bool isAccepted(int index, MathSymbol symbol) {
    if (symbol == null || symbol.isController) {
      return false;
    }

    MathSymbol leftSymbol = this._formula.getSymbol(index);
    MathSymbol rightSymbol = this._formula.getRightSymbol(index);

    if (symbol == MathSymbols.sign) {
      // [ Op | ( ] ± [ Num | . ]
      return (leftSymbol == null || leftSymbol.isLeftBracket || leftSymbol.isOperator) &&
          (rightSymbol == null || rightSymbol.isNumber || rightSymbol.isDecimal);
    }
    // For percent
    else if (symbol == MathSymbols.percent) {
      // Num % [ Op | ) ]
      // ) % [ Op | ) ]  ->  ( 3 + 1 )%
      if ((leftSymbol != null && (leftSymbol.isNumber || leftSymbol.isRightBracket)) &&
          (rightSymbol == null || rightSymbol.isOperator || rightSymbol.isRightBracket)) {
        return true;
      }

      MathSymbol moreLeftSymbol = this._formula.getLeftSymbol(index);
      // Num . % [ Op | ) ]
      return (leftSymbol != null && leftSymbol.isDecimal && moreLeftSymbol != null && moreLeftSymbol.isNumber) &&
          (rightSymbol == null || rightSymbol.isOperator || rightSymbol.isRightBracket);
    }
    // For bracket
    else if (symbol == MathSymbols.bracket) {
      // [ Op | ( ] () [ Op | ) | % ]
      return (leftSymbol == null || leftSymbol.isOperator || leftSymbol.isLeftBracket) &&
          (rightSymbol == null || rightSymbol.isOperator || rightSymbol.isRightBracket || rightSymbol.isPercent);
    }
    // For decimal
    else if (symbol == MathSymbols.decimal) {
      // .
      // [ Op | Sign | ( ] . [ Num | ) ]
      if ((leftSymbol == null || leftSymbol.isOperator || leftSymbol.isSign || leftSymbol.isLeftBracket) &&
          (rightSymbol == null || rightSymbol.isNumber || rightSymbol.isRightBracket)) {
        return true;
      }
      // Num . [ Op | Num | ) | % ]
      if (leftSymbol == null || !leftSymbol.isNumber) {
        return false;
      }

      MathSymbol nonNumKey = this
          ._formula
          .getSymbols(0, end: index)
          .toList()
          .reversed
          .firstWhere((MathSymbol k) => !k.isNumber, orElse: () => null);

      if (nonNumKey != null && nonNumKey.isDecimal) {
        return false;
      }
      if (rightSymbol == null || rightSymbol.isOperator || rightSymbol.isRightBracket || rightSymbol.isPercent) {
        return true;
      } else if (!rightSymbol.isNumber) {
        return false;
      }

      nonNumKey = this._formula.getSymbols(index + 1).firstWhere((MathSymbol k) => !k.isNumber, orElse: () => null);
      return nonNumKey == null || !nonNumKey.isDecimal;
    }
    // For operator
    else if (symbol.isOperator) {
      // Num Op [ Num | ( | ) | . | ± ]
      // . Op [ Num | ( | ) | . | ± ]
      // % Op [ Num | ( | ) | . | ± ]
      // ) Op [ Num | ( | ) | . | ± ]
      return (leftSymbol != null &&
              (leftSymbol.isNumber || leftSymbol.isDecimal || leftSymbol.isPercent | leftSymbol.isRightBracket)) &&
          (rightSymbol == null ||
              rightSymbol.isNumber ||
              rightSymbol.isLeftBracket ||
              rightSymbol.isDecimal ||
              rightSymbol.isSign ||
              rightSymbol.isRightBracket);
    }
    // For number
    else if (symbol.isNumber) {
      // [ Num | Op | . | ( | ± ] Num [ Num | Op | . | ) | % ]
      return (leftSymbol == null ||
              leftSymbol.isNumber ||
              leftSymbol.isOperator ||
              leftSymbol.isDecimal ||
              leftSymbol.isLeftBracket ||
              leftSymbol.isSign) &&
          (rightSymbol == null ||
              rightSymbol.isNumber ||
              rightSymbol.isOperator ||
              rightSymbol.isDecimal ||
              rightSymbol.isRightBracket ||
              rightSymbol.isPercent);
    }

    return true;
  }
}
