import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'theme.dart';
import 'data/firestore_service.dart';
import 'models/quiz_question.dart';

class AiQuizScreen extends StatefulWidget {
  final String subject;
  const AiQuizScreen({super.key, required this.subject});

  @override
  State<AiQuizScreen> createState() => _AiQuizScreenState();
}

class _AiQuizScreenState extends State<AiQuizScreen> {
  int _selectedOption = -1;

  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _isAnswerChecked = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await FirestoreService.fetchQuizQuestions(subject: widget.subject);
    if (mounted) {
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleNextQuestion() {
    if (!_isAnswerChecked) {
      // Check the answer first
      setState(() {
        _isAnswerChecked = true;
      });
      return;
    }

    // Move to next question
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = -1;
        _isAnswerChecked = false;
      });
    } else {
      // Quiz finished logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz Completed!')),
      );
    }
  }

  void _skipQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = -1;
        _isAnswerChecked = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz Completed!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: const Center(child: Text('No questions available', style: TextStyle(color: Colors.white))),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ColorFilter.mode(Colors.transparent, BlendMode.src),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          children: [
                            _buildSubjectLabel(currentQuestion.subject),
                            const SizedBox(height: 40),
                            _buildQuestionHeader(currentQuestion),
                            const SizedBox(height: 40),
                            _buildOptionsGrid(currentQuestion),
                            if (_isAnswerChecked && _selectedOption != currentQuestion.correctIndex)
                              _buildCorrectionMessage(currentQuestion),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrectionMessage(QuizQuestion question) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppTheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'The correct answer is: ${question.options[question.correctIndex]}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surface.withOpacity(0.8),
      elevation: 0,
      title: Text(
        'AI Quiz',
        style: GoogleFonts.sora(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  Widget _buildSubjectLabel(String subject) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        subject.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  Widget _buildQuestionHeader(QuizQuestion question) {
    return Column(
      children: [
        Text(
          question.question,
          textAlign: TextAlign.center,
          style: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.onSurface,
            height: 1.4,
          ),
        ),
        if (question.context.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            question.context,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOptionsGrid(QuizQuestion question) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: question.options.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final isSelected = _selectedOption == index;
        final isCorrectOption = index == question.correctIndex;
        
        Color backgroundColor = AppTheme.surfaceContainerHigh.withOpacity(0.6);
        Color borderColor = Colors.white.withOpacity(0.08);
        Color textColor = AppTheme.onSurface;
        Color numberColor = AppTheme.primary.withOpacity(0.4);
        
        if (_isAnswerChecked) {
          if (isCorrectOption) {
            backgroundColor = AppTheme.secondary.withOpacity(0.15);
            borderColor = AppTheme.secondary;
            textColor = AppTheme.secondary;
            numberColor = AppTheme.secondary;
          } else if (isSelected && !isCorrectOption) {
            backgroundColor = AppTheme.error.withOpacity(0.15);
            borderColor = AppTheme.error;
            textColor = AppTheme.error;
            numberColor = AppTheme.error;
          } else {
            // Dim unselected wrong options
            textColor = AppTheme.onSurface.withOpacity(0.4);
          }
        } else if (isSelected) {
          backgroundColor = AppTheme.primary.withOpacity(0.1);
          borderColor = AppTheme.primary;
          numberColor = AppTheme.primary;
        }

        return GestureDetector(
          onTap: _isAnswerChecked ? null : () {
            setState(() {
              _selectedOption = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: (isSelected && !_isAnswerChecked)
                  ? [BoxShadow(color: AppTheme.primary.withOpacity(0.05), blurRadius: 20, spreadRadius: 0)]
                  : [],
            ),
            child: Row(
              children: [
                Text(
                  '0${index + 1}',
                  style: GoogleFonts.sora(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: numberColor,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    question.options[index],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: textColor,
                    ),
                  ),
                ),
                if (_isAnswerChecked && isCorrectOption)
                  const Icon(Icons.check_circle, color: AppTheme.secondary)
                else if (_isAnswerChecked && isSelected && !isCorrectOption)
                  const Icon(Icons.cancel, color: AppTheme.error)
                else
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.outline.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: (isSelected && !_isAnswerChecked) ? 10 : 0,
                        height: (isSelected && !_isAnswerChecked) ? 10 : 0,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: _skipQuestion,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    side: BorderSide(color: AppTheme.outline.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'SKIP',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectedOption != -1 ? _handleNextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.inversePrimary,
                    foregroundColor: AppTheme.onPrimaryContainer,
                    disabledBackgroundColor: AppTheme.surfaceContainerHighest,
                    disabledForegroundColor: AppTheme.onSurfaceVariant.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: _selectedOption != -1 ? 8 : 0,
                  ),
                  child: Text(
                    _isAnswerChecked ? 'NEXT QUESTION' : 'CHECK ANSWER',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
