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

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import './math_symbol.dart';

const double _numberPadRowHeight = 42.0;

class _NumberPadGridDelegate extends SliverGridDelegate {
  const _NumberPadGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = 3;
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    final double viewTileHeight = constraints.viewportMainAxisExtent / 4.5;
    final double tileHeight = math.max(_numberPadRowHeight, viewTileHeight);

    return SliverGridRegularTileLayout(
      crossAxisCount: columnCount,
      mainAxisStride: tileHeight,
      crossAxisStride: tileWidth,
      childMainAxisExtent: tileHeight,
      childCrossAxisExtent: tileWidth,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_NumberPadGridDelegate oldDelegate) => false;
}

const List<MathSymbol> numberSymbols = <MathSymbol>[
  MathSymbols.seven,
  MathSymbols.eight,
  MathSymbols.nine,
  MathSymbols.four,
  MathSymbols.five,
  MathSymbols.six,
  MathSymbols.one,
  MathSymbols.two,
  MathSymbols.three,
  MathSymbols.clear,
  MathSymbols.decimal,
  MathSymbols.zero,
];
const List<MathSymbol> opSymbols = <MathSymbol>[
  MathSymbols.percent,
  MathSymbols.bracket,
  MathSymbols.divide,
  MathSymbols.multiply,
  MathSymbols.minus,
  MathSymbols.plus,
  MathSymbols.redo,
  MathSymbols.delete,
];

typedef MathSymbolOnPress = void Function(MathSymbol symbol);

class KeyPad extends StatefulWidget {
  final MathSymbolOnPress onPress;

  const KeyPad({Key key, @required this.onPress}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _KeyPadState();
}

class _KeyPadState extends State<KeyPad> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Widget> numberPads = numberSymbols.map<Widget>((MathSymbol symbol) {
      final bool isClear = symbol == MathSymbols.clear;

      Widget pad = Container(
        alignment: Alignment.center,
        child: Text(
          symbol.text,
          style: TextStyle(
            color: isClear ? theme.primaryTextTheme.title.color : Colors.grey,
            fontSize: 14.0 * 3.0,
          ),
        ),
      );

      return FlatButton(
        color: isClear ? theme.primaryColor : null,
        shape: CircleBorder(),
        onPressed: () => this.widget.onPress(symbol),
        child: pad,
      );
    }).toList();

    return Row(
      children: <Widget>[
        Flexible(
          child: GridView.custom(
            gridDelegate: const _NumberPadGridDelegate(),
            childrenDelegate: SliverChildListDelegate(numberPads, addRepaintBoundaries: false),
            padding: const EdgeInsets.symmetric(vertical: 6.0),
          ),
        ),
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: opSymbols.map<Widget>((MathSymbol symbol) {
              Color opPadColor;
              Widget opPad;

              switch (symbol) {
                case MathSymbols.redo:
                  opPadColor = theme.dividerColor;
                  opPad = Icon(
                    Icons.redo,
                    size: 14.0 * 2.0,
                    color: Colors.grey,
                  );
                  break;
                case MathSymbols.delete:
                  opPadColor = theme.primaryColor;
                  opPad = Text(
                    symbol.text,
                    style: TextStyle(color: theme.primaryTextTheme.title.color, fontSize: 14.0 * 1.5),
                  );
                  break;
                default:
                  opPad = Text(
                    symbol.text,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0 * 1.5,
                    ),
                  );
              }

              return Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 1.0, color: opPadColor != null ? opPadColor : theme.dividerColor),
                    ),
                  ),
                  child: FlatButton(
                    color: opPadColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    onPressed: () => this.widget.onPress(symbol),
                    child: Container(
                      alignment: Alignment.center,
                      child: opPad,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
