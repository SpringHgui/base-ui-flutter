import 'package:flutter/material.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';
import '../widgets/demo_section.dart';

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  String _result = '—';

  static const _questions = [
    QuestionnaireQuestion(
      id: 'satisfaction',
      title: 'How satisfied are you with the product?',
      type: QuestionType.single,
      required: true,
      options: ['Very satisfied', 'Satisfied', 'Neutral', 'Dissatisfied'],
    ),
    QuestionnaireQuestion(
      id: 'features',
      title: 'Which features do you use most?',
      type: QuestionType.multiple,
      options: ['Data grid', 'Charts', 'Forms', 'Menus', 'Dialogs'],
    ),
    QuestionnaireQuestion(
      id: 'feedback',
      title: 'Anything else you would like to share?',
      type: QuestionType.text,
      helperText: 'Optional — tell us what could be better.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ScrollableControl(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoSection(
            title: 'Questionnaire',
            children: [
              Questionnaire(
                questions: _questions,
                onSubmit: (answers) =>
                    setState(() => _result = answers.length.toString()),
              ),
              const SizedBox(height: 8),
              Text('Answered questions: $_result'),
            ],
          ),
        ],
      ),
    );
  }
}
