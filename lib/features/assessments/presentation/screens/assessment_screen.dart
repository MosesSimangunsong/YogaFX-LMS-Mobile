import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/shell_skeleton.dart';
import '../../domain/assessment_result.dart';
import '../../domain/assessment_session.dart';
import '../controllers/assessment_detail_controller.dart';
import '../controllers/assessment_submit_controller.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({
    super.key,
    required this.moduleId,
    required this.lessonId,
    required this.assessmentId,
  });

  static const routeName = 'assessment';
  static const routePath =
      '/modules/:moduleId/lessons/:lessonId/assessments/:assessmentId';

  final String moduleId;
  final String lessonId;
  final String assessmentId;

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  final Map<String, dynamic> _answers = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(
      assessmentDetailControllerProvider(widget.assessmentId),
    );
    final submitState = ref.watch(
      assessmentSubmitControllerProvider(widget.assessmentId),
    );

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: sessionState.when(
            data: (session) => _AssessmentContent(
              moduleId: widget.moduleId,
              lessonId: widget.lessonId,
              session: session,
              answers: _answers,
              submitState: submitState,
              onAnswerChanged: _updateAnswer,
              onSubmit: () => _submit(session),
            ),
            loading: () => const _AssessmentLoadingState(),
            error: (error, _) => AppErrorView(message: error.toString()),
          ),
        ),
      ),
    );
  }

  void _updateAnswer(String questionId, dynamic value) {
    setState(() {
      _answers[questionId] = value;
    });
  }

  Future<void> _submit(AssessmentSession session) async {
    final validationError = _validateRequiredQuestions(session);
    if (validationError != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }

    await ref
        .read(assessmentSubmitControllerProvider(widget.assessmentId).notifier)
        .submit(
          moduleId: widget.moduleId,
          lessonId: widget.lessonId,
          answers: _answers,
        );
  }

  String? _validateRequiredQuestions(AssessmentSession session) {
    for (final question in session.questions) {
      if (!question.required) {
        continue;
      }

      final answer = _answers[question.id];
      if (question.isTextInput) {
        if (answer == null || answer.toString().trim().isEmpty) {
          return 'Please answer all required questions before submitting.';
        }
      } else if (question.isMultipleChoice) {
        if (answer is! Set<String> || answer.isEmpty) {
          return 'Please answer all required questions before submitting.';
        }
      } else {
        if (answer == null || answer.toString().isEmpty) {
          return 'Please answer all required questions before submitting.';
        }
      }
    }

    return null;
  }
}

class _AssessmentContent extends StatelessWidget {
  const _AssessmentContent({
    required this.moduleId,
    required this.lessonId,
    required this.session,
    required this.answers,
    required this.submitState,
    required this.onAnswerChanged,
    required this.onSubmit,
  });

  final String moduleId;
  final String lessonId;
  final AssessmentSession session;
  final Map<String, dynamic> answers;
  final AsyncValue<AssessmentResult?> submitState;
  final void Function(String questionId, dynamic value) onAnswerChanged;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = submitState.valueOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lesson $lessonId', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text(session.title, style: theme.textTheme.headlineMedium),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: theme.cardColor.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session.description, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 10),
              Text(
                '${session.questions.length} question(s)',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (session.questions.isEmpty)
          const SizedBox(
            height: 220,
            child: AppEmptyView(
              title: 'No questions available',
              message:
                  'This assessment did not return any playable question data.',
              icon: Icons.quiz_outlined,
            ),
          )
        else
          ...session.questions.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _QuestionCard(
                questionNumber: entry.key + 1,
                question: entry.value,
                answer: answers[entry.value.id],
                onAnswerChanged: (value) =>
                    onAnswerChanged(entry.value.id, value),
              ),
            );
          }),
        if (submitState.hasError) ...[
          const SizedBox(height: 8),
          Text(
            submitState.error.toString(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: submitState.isLoading ? null : onSubmit,
          icon: submitState.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.send_rounded),
          label: const Text('Submit assessment'),
        ),
        if (result != null) ...[
          const SizedBox(height: 24),
          _AssessmentResultCard(result: result),
        ],
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.questionNumber,
    required this.question,
    required this.answer,
    required this.onAnswerChanged,
  });

  final int questionNumber;
  final AssessmentQuestion question;
  final dynamic answer;
  final ValueChanged<dynamic> onAnswerChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question $questionNumber', style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          Text(question.prompt, style: theme.textTheme.titleMedium),
          const SizedBox(height: 14),
          if (question.isTextInput)
            TextFormField(
              initialValue: answer?.toString() ?? '',
              minLines: 3,
              maxLines: 5,
              onChanged: onAnswerChanged,
              decoration: const InputDecoration(
                hintText: 'Type your answer here',
              ),
            )
          else if (question.isMultipleChoice)
            ...question.options.map((option) {
              final selected =
                  answer is Set<String> && answer.contains(option.id);
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: selected,
                title: Text(option.label),
                onChanged: (value) {
                  final next = <String>{
                    ...(answer as Set<String>? ?? <String>{}),
                  };
                  if (value == true) {
                    next.add(option.id);
                  } else {
                    next.remove(option.id);
                  }
                  onAnswerChanged(next);
                },
              );
            })
          else
            ...question.options.map((option) {
              final isSelected = answer?.toString() == option.id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onAnswerChanged(option.id),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.dividerColor,
                      ),
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.02),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.white70,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(option.label)),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _AssessmentResultCard extends StatelessWidget {
  const _AssessmentResultCard({required this.result});

  final AssessmentResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assessment result', style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          Text('Status: ${result.status}', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 6),
          Text('Score: ${result.scoreLabel}', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 10),
          Text(result.summary, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _AssessmentLoadingState extends StatelessWidget {
  const _AssessmentLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: const [
        Row(
          children: [
            ShellSkeleton(height: 44, width: 44, radius: 22),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShellSkeleton(height: 12, width: 100, radius: 8),
                  SizedBox(height: 8),
                  ShellSkeleton(height: 28, width: double.infinity, radius: 12),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 18),
        ShellSkeleton(height: 110, width: double.infinity, radius: 24),
        SizedBox(height: 18),
        ShellSkeleton(height: 220, width: double.infinity, radius: 24),
      ],
    );
  }
}
