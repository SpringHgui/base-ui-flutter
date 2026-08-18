import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../common/button.dart';
import '../common/check_box.dart';
import '../common/radio_button.dart';
import '../common/textarea.dart';

/// Question types of a [Questionnaire].
enum QuestionType {
  /// Single choice (radio buttons).
  single,

  /// Multiple choice (check boxes).
  multiple,

  /// Free text (text area).
  text,
}

/// One question of a [Questionnaire].
class QuestionnaireQuestion {
  const QuestionnaireQuestion({
    required this.id,
    required this.title,
    this.type = QuestionType.single,
    this.options = const [],
    this.required = false,
    this.helperText,
  });

  final String id;
  final String title;
  final QuestionType type;

  /// Choice labels for [QuestionType.single] / [QuestionType.multiple].
  final List<String> options;

  final bool required;
  final String? helperText;
}

/// A form-style questionnaire — the counterpart of the shadcn
/// (experimental) "Questionnaire". Reuses the library's own `RadioButton`,
/// `CheckBox` and `Textarea` controls so the look stays consistent.
class Questionnaire extends StatefulWidget {
  const Questionnaire({
    super.key,
    required this.questions,
    this.onChanged,
    this.onSubmit,
    this.submitLabel = 'Submit',
    this.tokens,
  });

  /// The questions, in order.
  final List<QuestionnaireQuestion> questions;

  /// Called with the current answers (`Map<questionId, value>`) on change.
  final ValueChanged<Map<String, Object?>>? onChanged;

  /// Called with the final answers when [submitLabel] is activated.
  final ValueChanged<Map<String, Object?>>? onSubmit;

  final String submitLabel;
  final DesktopTokens? tokens;

  @override
  State<Questionnaire> createState() => _QuestionnaireState();
}

class _QuestionnaireState extends State<Questionnaire> {
  final Map<String, Object?> _answers = {};
  final Map<String, String?> _errors = {};

  void _setAnswer(String id, Object? value) {
    setState(() {
      _answers[id] = value;
      _errors.remove(id);
    });
    widget.onChanged?.call(Map.of(_answers));
  }

  bool _validate() {
    final errors = <String, String?>{};
    for (final q in widget.questions) {
      if (q.required && _isUnanswered(q)) {
        errors[q.id] = 'This question is required';
      }
    }
    setState(() => _errors..clear()..addAll(errors));
    return errors.isEmpty;
  }

  bool _isUnanswered(QuestionnaireQuestion q) {
    final value = _answers[q.id];
    if (value == null) return true;
    if (value is String && value.trim().isEmpty) return true;
    if (value is List && value.isEmpty) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < widget.questions.length; i++) ...[
          _QuestionCard(
            question: widget.questions[i],
            index: i,
            answer: _answers[widget.questions[i].id],
            error: _errors[widget.questions[i].id],
            onChanged: _setAnswer,
            tokens: t,
          ),
          if (i < widget.questions.length - 1)
            SizedBox(height: t.compactSpacing * 2),
        ],
        SizedBox(height: t.controlPaddingX),
        Align(
          alignment: Alignment.centerRight,
          child: Button(
            text: widget.submitLabel,
            onPressed: () {
              if (_validate()) widget.onSubmit?.call(Map.of(_answers));
            },
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.index,
    required this.answer,
    required this.error,
    required this.onChanged,
    required this.tokens,
  });

  final QuestionnaireQuestion question;
  final int index;
  final Object? answer;
  final String? error;
  final void Function(String id, Object? value) onChanged;
  final DesktopTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Container(
      decoration: BoxDecoration(
        color: t.cardColor,
        border: Border.all(
          color: error != null ? t.destructiveColor : t.borderColor,
          width: t.borderWidth,
        ),
        borderRadius: BorderRadius.circular(t.cornerRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(t.controlPaddingX),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ${question.title}'
                  '${question.required ? ' *' : ''}',
                  style: TextStyle(
                    fontFamily: t.fontFamily,
                    fontSize: t.fontSize,
                    fontWeight: FontWeight.w600,
                    color: t.foregroundColor,
                    height: 1.3,
                  ),
                ),
                if (question.helperText != null) ...[
                  SizedBox(height: t.compactSpacing * 0.5),
                  Text(
                    question.helperText!,
                    style: TextStyle(
                      fontFamily: t.fontFamily,
                      fontSize: t.fontSize * 0.75,
                      color: t.mutedForegroundColor,
                      height: 1.3,
                    ),
                  ),
                ],
                SizedBox(height: t.compactSpacing * 1.5),
                _buildInput(t),
                if (error != null) ...[
                  SizedBox(height: t.compactSpacing),
                  Text(
                    error!,
                    style: TextStyle(
                      fontFamily: t.fontFamily,
                      fontSize: t.fontSize * 0.75,
                      color: t.destructiveColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(DesktopTokens t) {
    switch (question.type) {
      case QuestionType.single:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final option in question.options)
              Padding(
                padding: EdgeInsets.symmetric(vertical: t.compactSpacing * 0.5),
                child: RadioButton<String>(
                  value: option,
                  groupValue: answer as String?,
                  onChanged: (v) => onChanged(question.id, v),
                  label: option,
                  tokens: t,
                ),
              ),
          ],
        );
      case QuestionType.multiple:
        final selected = (answer as List<String>?) ?? const <String>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final option in question.options)
              Padding(
                padding: EdgeInsets.symmetric(vertical: t.compactSpacing * 0.5),
                child: CheckBox(
                  value: selected.contains(option),
                  onChanged: (checked) {
                    final next = List<String>.of(selected);
                    if (checked == true) {
                      if (!next.contains(option)) next.add(option);
                    } else {
                      next.remove(option);
                    }
                    onChanged(question.id, next);
                  },
                  label: option,
                  tokens: t,
                ),
              ),
          ],
        );
      case QuestionType.text:
        return Textarea(
          hint: 'Your answer…',
          minLines: 2,
          maxLines: 4,
          tokens: t,
          onChanged: (v) => onChanged(question.id, v),
        );
    }
  }
}
