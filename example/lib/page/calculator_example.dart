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

import './calculator_example_embedded.dart';
import './calculator_example_dialog.dart';

class CalculatorExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              text: 'Embedded',
            ),
            Tab(
              text: 'Dialog',
            ),
          ],
        ),
        body: TabBarView(
          children: [
            CalculatorExampleEmbeddedPage(),
            CalculatorExampleDialogPage(),
          ],
        ),
      ),
    );
  }
}
