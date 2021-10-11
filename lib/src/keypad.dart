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
  MathSymbols.undo,
  MathSymbols.delete,
];

typedef MathSymbolOnPress = void Function(MathSymbol symbol);

class KeyPad extends StatefulWidget {
  final MathSymbolOnPress onPress;
  final KeyPadController controller;

  const KeyPad({Key key, @required this.onPress, this.controller}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _KeyPadState();
}

class _KeyPadState extends State<KeyPad> {
  @override
  void initState() {
    if (this.widget.controller != null) {
      this.widget.controller.addListener(this._handleChangedDisabledKeys);
    }

    super.initState();
  }

  @override
  void dispose() {
    if (this.widget.controller != null) {
      this.widget.controller.removeListener(this._handleChangedDisabledKeys);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Flexible(
          child: this._createNumberSymbolsPane(context, numberSymbols),
        ),
        Container(
          child: this._createOpSymbolsPane(context, opSymbols),
        ),
      ],
    );
  }

  Widget _createNumberSymbolsPane(BuildContext context, List<MathSymbol> numberSymbols) {
    final ThemeData theme = Theme.of(context);

    final List<Widget> numberPads = numberSymbols.map<Widget>((MathSymbol symbol) {
      final bool isClear = symbol == MathSymbols.clear;

      Widget pad = Container(
        alignment: Alignment.center,
        child: Text(
          symbol.text,
          style: TextStyle(
            color: isClear ? theme.primaryTextTheme.headline1.color : Colors.grey,
            fontSize: 14.0 * 3.0,
          ),
        ),
      );

      return FlatButton(
        color: isClear ? theme.primaryColor : null,
        shape: const CircleBorder(),
        onPressed: () => this.widget.onPress(symbol),
        child: pad,
      );
    }).toList();

    return GridView.custom(
      gridDelegate: const _NumberPadGridDelegate(),
      childrenDelegate: SliverChildListDelegate(numberPads, addRepaintBoundaries: false),
      padding: const EdgeInsets.symmetric(vertical: 6.0),
    );
  }

  Widget _createOpSymbolsPane(BuildContext context, List<MathSymbol> opSymbols) {
    final ThemeData theme = Theme.of(context);

    final List<Widget> opPads = opSymbols.map<Widget>((MathSymbol symbol) {
      final Widget opPad = this._createOpSymbolPad(context, symbol);
      final Color opPadColor = (opPad is FlatButton) ? opPad.color : null;

      return Expanded(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(width: 1.0, color: opPadColor ?? theme.dividerColor),
            ),
          ),
          child: opPad,
        ),
      );
    }).toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: opPads,
    );
  }

  Widget _createOpSymbolPad(BuildContext context, MathSymbol symbol) {
    if (symbol == MathSymbols.undo) {
      return this._createUndoOpSymbolPad(context);
    }

    final ThemeData theme = Theme.of(context);

    final double fontSize = 14.0 * 1.5;
    final ShapeBorder shape = const RoundedRectangleBorder(borderRadius: BorderRadius.zero);

    Color opPadColor;
    Widget opPad;
    bool disabled = this._isDisabledKey(symbol);

    switch (symbol) {
      case MathSymbols.delete:
        opPadColor = theme.primaryColor;
        opPad = Text(
          symbol.text,
          style: TextStyle(color: theme.primaryTextTheme.headline1.color, fontSize: fontSize),
        );
        break;
      default:
        opPad = Text(
          symbol.text,
          style: TextStyle(
            color: Colors.grey,
            fontSize: fontSize,
          ),
        );
    }

    return FlatButton(
      color: opPadColor,
      shape: shape,
      onPressed: disabled ? null : () => this.widget.onPress(symbol),
      child: opPad,
    );
  }

  Widget _createUndoOpSymbolPad(BuildContext context) {
    final double fontSize = 14.0 * 1.5;
    final ShapeBorder shape = const RoundedRectangleBorder(borderRadius: BorderRadius.zero);

    final ButtonThemeData buttonTheme = ButtonTheme.of(context);
    final double buttonMinWidth = buttonTheme.constraints.minWidth / 2;

    final bool disabledUndo = this._isDisabledKey(MathSymbols.undo);
    final bool disabledRedo = this._isDisabledKey(MathSymbols.redo);
    final Color disabledIconColor = Colors.black12;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        MaterialButton(
          shape: shape,
          // >>>> clear padding
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          // <<<< end
          minWidth: buttonMinWidth,
          onPressed: disabledUndo ? null : () => this.widget.onPress(MathSymbols.undo),
          child: Icon(
            Icons.undo,
            size: fontSize,
            color: disabledUndo ? disabledIconColor : Colors.grey,
          ),
        ),
        MaterialButton(
          shape: shape,
          // >>>> clear padding
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          // <<<< end
          minWidth: buttonMinWidth,
          onPressed: disabledRedo ? null : () => this.widget.onPress(MathSymbols.redo),
          child: Icon(
            Icons.redo,
            size: fontSize,
            color: disabledRedo ? disabledIconColor : Colors.grey,
          ),
        ),
      ],
    );
  }

  void _handleChangedDisabledKeys() {
    setState(() {});
  }

  bool _isDisabledKey(MathSymbol symbol) {
    return this.widget.controller != null ? this.widget.controller._disabledKeys.contains(symbol) : false;
  }
}

class KeyPadController extends ChangeNotifier {
  List<MathSymbol> _disabledKeys;

  KeyPadController(List<MathSymbol> disabledKeys) : this._disabledKeys = disabledKeys ?? [];

  void disableKeys(List<MathSymbol> keys) {
    if (listEquals(this._disabledKeys, keys)) {
      return;
    }

    this._disabledKeys = keys != null ? [...keys] : [];

    notifyListeners();
  }

  @override
  void dispose() {
    this._disabledKeys = [];

    super.dispose();
  }
}
