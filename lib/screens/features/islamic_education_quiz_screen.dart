import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/colors.dart';
import '../../features/islamic_education/models.dart';
import '../../features/islamic_education/services.dart';
import '../../features/auth/auth_controller.dart';

class IslamicEducationQuizHubScreen extends ConsumerStatefulWidget {
  const IslamicEducationQuizHubScreen({super.key});

  @override
  ConsumerState<IslamicEducationQuizHubScreen> createState() => _IslamicEducationQuizHubScreenState();
}

class _IslamicEducationQuizHubScreenState extends ConsumerState<IslamicEducationQuizHubScreen> {
  bool _isLoading = false;
  List<IslamicEducationalContent> _quizContent = [];

  @override
  void initState() {
    super.initState();
    _loadQuizContent();
  }

  Future<void> _loadQuizContent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load content that has quizzes
      final content = await IslamicEducationService.getEducationalContent(limit: 20);
      final quizContent = content.where((item) => item.quiz != null).toList();
      
      setState(() {
        _quizContent = quizContent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load quiz content: $e',
              style: GoogleFonts.nunitoSans(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz Hub',
          style: GoogleFonts.nunitoSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surfaceSecondary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quizContent.isEmpty
              ? _buildEmptyState()
              : _buildQuizList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Quizzes Available',
            style: GoogleFonts.nunitoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon for new quizzes!',
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _quizContent.length,
      itemBuilder: (context, index) {
        final content = _quizContent[index];
        return _QuizCard(
          content: content,
          onTap: () => _navigateToQuiz(content),
        );
      },
    );
  }

  void _navigateToQuiz(IslamicEducationalContent content) {
    final userId = ref.read(authControllerProvider).profile?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please sign in to take quizzes and track progress.',
            style: GoogleFonts.nunitoSans(),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IslamicEducationQuizScreen(
          quiz: content.quiz!,
          contentId: content.id,
          contentTitle: content.title,
          currentUserId: userId,
        ),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final IslamicEducationalContent content;
  final VoidCallback onTap;

  const _QuizCard({
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.quiz,
                  size: 24,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${content.quiz!.questions.length} questions • ${content.estimatedReadTime} min',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Quiz taking screen
class IslamicEducationQuizScreen extends StatefulWidget {
  final EducationalQuiz quiz;
  final String contentId;
  final String contentTitle;
  final String? currentUserId;

  const IslamicEducationQuizScreen({
    super.key,
    required this.quiz,
    required this.contentId,
    required this.contentTitle,
    this.currentUserId,
  });

  @override
  State<IslamicEducationQuizScreen> createState() => _IslamicEducationQuizScreenState();
}

class _IslamicEducationQuizScreenState extends State<IslamicEducationQuizScreen> {
  int _currentQuestionIndex = 0;
  final Map<String, String> _answers = {};
  Map<String, dynamic>? _results;
  late final Stopwatch _stopwatch;
  Timer? _timer;
  int? _remainingSeconds;
  bool _autoSubmitted = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    if (widget.quiz.timeLimit != null && widget.quiz.timeLimit! > 0) {
      _remainingSeconds = widget.quiz.timeLimit! * 60;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tickTimer());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: ${widget.contentTitle}'),
        backgroundColor: AppColors.surfaceSecondary,
        elevation: 0,
      ),
      body: _results != null
          ? _buildResultsScreen()
          : _buildQuestionScreen(),
    );
  }

  Widget _buildQuestionScreen() {
    if (_currentQuestionIndex >= widget.quiz.questions.length) {
      return _buildCompletionScreen();
    }

    final currentQuestion = widget.quiz.questions[_currentQuestionIndex];
    
    final total = widget.quiz.questions.length;
    final selected = _answers[currentQuestion.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_remainingSeconds != null)
          _QuizTimerBanner(
            remainingSeconds: _remainingSeconds!,
            totalSeconds: widget.quiz.timeLimit! * 60,
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / total,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 16),
              Text(
                'Question ${_currentQuestionIndex + 1} of $total',
                style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentQuestion.question,
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: currentQuestion.options.length,
            itemBuilder: (context, index) {
              final option = currentQuestion.options[index];
              final isSelected = selected == option;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _selectAnswer(currentQuestion.id, option),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected ? Colors.green : Colors.grey[600],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 16,
                              color: isSelected
                                  ? Colors.green
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Previous',
                        style:
                            GoogleFonts.nunitoSans(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selected != null ? _nextQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _currentQuestionIndex == total - 1 ? 'Submit' : 'Next',
                      style: GoogleFonts.nunitoSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Calculating your results...',
              style: GoogleFonts.nunitoSans(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    final score = _results?['score'] as double? ?? 0.0;
    final passed = _results?['passed'] as bool? ?? false;
    final percentage = (score * 100).toInt();
    final timeSpent = _results?['timeSpent'] as int?;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Results header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: passed ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: passed ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  passed ? Icons.check_circle : Icons.cancel,
                  size: 64,
                  color: passed ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  passed ? 'Quiz Completed!' : 'Quiz Failed',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: passed ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Score: $percentage%',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                if (timeSpent != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Time spent: ${_formatDuration(timeSpent)}',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                if (_autoSubmitted)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Time expired — quiz submitted automatically.',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 13,
                        color: Colors.red[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Back to Quiz Hub',
                style: GoogleFonts.nunitoSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(String questionId, String answer) {
    setState(() {
      _answers[questionId] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _submitQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitQuiz({bool autoSubmitted = false}) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    _autoSubmitted = autoSubmitted;
    _timer?.cancel();
    _stopwatch.stop();
    try {
      // Calculate score
      int correctAnswers = 0;
      for (final question in widget.quiz.questions) {
        if (_answers[question.id] == question.correctAnswer) {
          correctAnswers++;
        }
      }
      
      final score = correctAnswers / widget.quiz.questions.length;
      final passed = score >= widget.quiz.passingScore;
      final answers = widget.quiz.questions
          .map((question) => _answers[question.id] ?? '')
          .toList();
      final timeSpent = _stopwatch.elapsed.inSeconds;

      if (widget.currentUserId != null) {
        await IslamicEducationService.saveQuizResults(
          userId: widget.currentUserId!,
          contentId: widget.contentId,
          quizId: widget.quiz.id,
          answers: answers,
          score: score,
          passed: passed,
          timeSpent: timeSpent,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Quiz completed locally. Sign in to save your progress.',
              style: GoogleFonts.nunitoSans(),
            ),
          ),
        );
      }
      
      setState(() {
        _results = {
          'score': score,
          'passed': passed,
          'correctAnswers': correctAnswers,
          'totalQuestions': widget.quiz.questions.length,
          'timeSpent': timeSpent,
        };
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error submitting quiz: $e',
              style: GoogleFonts.nunitoSans(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    _isSubmitting = false;
  }

  void _tickTimer() {
    if (_remainingSeconds == null || _remainingSeconds == 0) return;

    setState(() {
      final next = _remainingSeconds! - 1;
      _remainingSeconds = next < 0 ? 0 : next;
    });

    if (_remainingSeconds == 0 && !_autoSubmitted) {
      _submitQuiz(autoSubmitted: true);
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _QuizTimerBanner extends StatelessWidget {
  const _QuizTimerBanner({
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  final int remainingSeconds;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final ratio = totalSeconds == 0 ? 0.0 : remainingSeconds / totalSeconds;
    final isCritical = ratio <= 0.2;
    final color = isCritical ? Colors.red : AppColors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: isCritical ? Colors.red.withValues(alpha: 0.08) : AppColors.surfaceSecondary,
      child: Row(
        children: [
          Icon(Icons.timer, color: color),
          const SizedBox(width: 8),
          Text(
            'Time remaining: ${_format(remainingSeconds)}',
            style: GoogleFonts.nunitoSans(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _format(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
