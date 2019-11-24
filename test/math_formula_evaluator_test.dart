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

import 'package:test/test.dart';

import 'package:flutter_calculator/src/math_formula.dart';
import 'package:flutter_calculator/src/math_formula_evaluator.dart';

const List<List<dynamic>> samples = [
  ['.12 + 3.4 - (24 × 2. - 5%) × 6 + (2 ÷ 3)', '0.12 3.4 + 24 2.0 × 5 % - 6 × - 2 3 ÷ +', -283.5133333333334],
  ['1.2 × (5 + 6 ÷ (3 - 2.))% - 10', '1.2 5 6 3 2.0 - ÷ + % × 10 -', -9.868],
  ['0.01 + 0.02', '0.01 0.02 +', 0.03]
];

void main() {
  test("Testing MathFormulaEvaluator#evaluate()", () {
    for (int i = 0; i < samples.length; i++) {
      List<dynamic> sample = samples[i];

      MathFormula formula = MathFormula(expr: sample[0]);
      MathFormulaEvaluator evaluator = MathFormulaEvaluator(formula);

      double result = evaluator.evaluate();

      expect(result, equals(sample[2]));
    }
  });
}
