import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;

// https://github.com/leisim/auto_size_text/blob/master/lib/src/auto_size_text.dart
class AutoSizeEditableText extends EditableText {
  // The default font size if none is specified.
  static const double _defaultFontSize = 14.0;

  /// The minimum text size constraint to be used when auto-sizing text.
  ///
  /// Is being ignored if [presetFontSizes] is set.
  final double minFontSize;

  /// The maximum text size constraint to be used when auto-sizing text.
  ///
  /// Is being ignored if [presetFontSizes] is set.
  final double maxFontSize;

  /// The step size in which the font size is being adapted to constraints.
  ///
  /// The Text scales uniformly in a range between [minFontSize] and
  /// [maxFontSize].
  /// Each increment occurs as per the step size set in stepGranularity.
  ///
  /// Most of the time you don't want a stepGranularity below 1.0.
  ///
  /// Is being ignored if [presetFontSizes] is set.
  final double stepGranularity;

  /// Predefines all the possible font sizes.
  ///
  /// **Important:** PresetFontSizes have to be in descending order.
  final List<double> presetFontSizes;

  /// Whether words which don't fit in one line should be wrapped.
  ///
  /// If false, the fontSize is lowered as far as possible until all words fit
  /// into a single line.
  final bool wrapWords;

  AutoSizeEditableText({
    Key key,
    @required controller,
    @required focusNode,
    readOnly = false,
    obscureText = false,
    autocorrect = true,
    @required style,
    StrutStyle strutStyle,
    @required cursorColor,
    @required backgroundCursorColor,
    textAlign = TextAlign.start,
    textDirection,
    locale,
    textScaleFactor,
    maxLines = 1,
    minLines,
    expands = false,
    forceLine = true,
    textWidthBasis = TextWidthBasis.parent,
    autofocus = false,
    bool showCursor,
    showSelectionHandles = false,
    selectionColor,
    selectionControls,
    TextInputType keyboardType,
    textInputAction,
    textCapitalization = TextCapitalization.none,
    onChanged,
    onEditingComplete,
    onSubmitted,
    onSelectionChanged,
    onSelectionHandleTapped,
    List<TextInputFormatter> inputFormatters,
    rendererIgnoresPointer = false,
    cursorWidth = 2.0,
    cursorRadius,
    cursorOpacityAnimates = false,
    cursorOffset,
    paintCursorAboveText = false,
    scrollPadding = const EdgeInsets.all(20.0),
    keyboardAppearance = Brightness.light,
    dragStartBehavior = DragStartBehavior.start,
    enableInteractiveSelection = true,
    scrollController,
    scrollPhysics,
    toolbarOptions = const ToolbarOptions(copy: true, cut: true, paste: true, selectAll: true),
    this.minFontSize = 12.0,
    this.maxFontSize = double.infinity,
    this.presetFontSizes,
    this.stepGranularity = 1,
    this.wrapWords = true,
  }) : super(
          key: key,
          controller: controller,
          focusNode: focusNode,
          readOnly: readOnly,
          obscureText: obscureText,
          autocorrect: autocorrect,
          style: style,
          strutStyle: strutStyle,
          cursorColor: cursorColor,
          backgroundCursorColor: backgroundCursorColor,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
          minLines: minLines,
          expands: expands,
          forceLine: forceLine,
          autofocus: autofocus,
          showCursor: showCursor,
          showSelectionHandles: showSelectionHandles,
          selectionColor: selectionColor,
          selectionControls: selectionControls,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          onSubmitted: onSubmitted,
          onSelectionChanged: onSelectionChanged,
          onSelectionHandleTapped: onSelectionHandleTapped,
          rendererIgnoresPointer: rendererIgnoresPointer,
          cursorWidth: cursorWidth,
          cursorRadius: cursorRadius,
          cursorOpacityAnimates: cursorOpacityAnimates,
          cursorOffset: cursorOffset,
          paintCursorAboveText: paintCursorAboveText,
          keyboardAppearance: keyboardAppearance,
          enableInteractiveSelection: enableInteractiveSelection,
          scrollController: scrollController,
          scrollPhysics: scrollPhysics,
        );

  @override
  AutoSizeEditableTextState createState() => AutoSizeEditableTextState();
}

class AutoSizeEditableTextState extends EditableTextState {
  BoxConstraints _boxConstraints;

  @override
  void initState() {
    super.initState();

    this.widget.controller.addListener(this._didUpdateText);
  }

  @override
  void dispose() {
    this.widget.controller.removeListener(this._didUpdateText);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      this._boxConstraints = constraints;

      return super.build(context);
    });
  }

  @override
  TextSpan buildTextSpan() {
    if (this.widget.obscureText) {
      return super.buildTextSpan();
    }

    DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(this.context);

    TextStyle style = this.widget.style;
    if (style == null || style.inherit) {
      style = defaultTextStyle.style.merge(style);
    }
    if (style.fontSize == null) {
      style = style.copyWith(fontSize: AutoSizeEditableText._defaultFontSize);
    }

    String text = this.widget.controller.value.text;
    int maxLines = this.widget.maxLines ?? defaultTextStyle.maxLines;
    double fontSize = _calculateTextFontSize(this._boxConstraints, text, style, maxLines);

    return this.widget.controller.buildTextSpan(
          style: style.copyWith(fontSize: fontSize),
          withComposing: !this.widget.readOnly,
        );
  }

  void _didUpdateText() {
    setState(() {});
  }

  double _calculateTextFontSize(BoxConstraints constraints, String text, TextStyle style, int maxLines) {
    AutoSizeEditableText widget = this.widget;
    TextSpan textSpan = TextSpan(
      style: style,
      text: text,
    );

    int left;
    int right;
    double userScale = widget.textScaleFactor ?? MediaQuery.textScaleFactorOf(this.context);

    List<double> presetFontSizes = widget.presetFontSizes?.reversed?.toList();
    if (presetFontSizes == null) {
      double defaultFontSize = style.fontSize.clamp(widget.minFontSize, widget.maxFontSize);
      double defaultScale = defaultFontSize * userScale / style.fontSize;

      if (_checkTextFits(constraints, textSpan, defaultScale, maxLines)) {
        return defaultFontSize * userScale;
      }

      left = (widget.minFontSize / widget.stepGranularity).floor();
      right = (defaultFontSize / widget.stepGranularity).ceil();
    } else {
      left = 0;
      right = presetFontSizes.length - 1;
    }

    bool lastValueFits = false;
    while (left <= right) {
      double scale;
      int mid = (left + (right - left) / 2).toInt();

      if (presetFontSizes == null) {
        scale = mid * userScale * widget.stepGranularity / style.fontSize;
      } else {
        scale = presetFontSizes[mid] * userScale / style.fontSize;
      }

      if (_checkTextFits(constraints, textSpan, scale, maxLines)) {
        left = mid + 1;
        lastValueFits = true;
      } else {
        right = mid - 1;
      }
    }

    if (!lastValueFits) {
      right += 1;
    }

    double fontSize;
    if (presetFontSizes == null) {
      fontSize = right * userScale * widget.stepGranularity;
    } else {
      fontSize = presetFontSizes[right] * userScale;
    }

    return fontSize;
  }

  bool _checkTextFits(BoxConstraints constraints, TextSpan textSpan, double scale, int maxLines) {
    AutoSizeEditableText widget = this.widget;

    if (!widget.wrapWords) {
      List<String> words = textSpan.toPlainText().split(RegExp('\\s+'));

      TextPainter wordWrapPainter = TextPainter(
        text: TextSpan(
          style: textSpan.style,
          text: words.join('\n'),
        ),
        textAlign: widget.textAlign ?? TextAlign.left,
        textDirection: widget.textDirection ?? TextDirection.ltr,
        textScaleFactor: scale ?? 1,
        maxLines: words.length,
        locale: widget.locale,
        strutStyle: widget.strutStyle,
      );

      wordWrapPainter.layout(maxWidth: constraints.maxWidth);

      if (wordWrapPainter.didExceedMaxLines || wordWrapPainter.width > constraints.maxWidth) {
        return false;
      }
    }

    TextPainter textPainter = TextPainter(
      text: textSpan,
      textAlign: widget.textAlign ?? TextAlign.left,
      textDirection: widget.textDirection ?? TextDirection.ltr,
      textScaleFactor: scale ?? 1,
      maxLines: maxLines,
      locale: widget.locale,
      strutStyle: widget.strutStyle,
    );

    textPainter.layout(maxWidth: constraints.maxWidth);

    return !(textPainter.didExceedMaxLines ||
        textPainter.height > constraints.maxHeight ||
        textPainter.width > constraints.maxWidth);
  }
}
