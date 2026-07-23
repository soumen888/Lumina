import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'ai_quiz_screen.dart';
import 'data/firestore_service.dart';

class QuizHubScreen extends StatefulWidget {
  const QuizHubScreen({super.key});

  @override
  State<QuizHubScreen> createState() => _QuizHubScreenState();
}

class _QuizHubScreenState extends State<QuizHubScreen> {
  final Map<String, int> _subjectCounts = {
    'Computer': 0,
    'Aptitude': 0,
    'GK': 0,
    'Current Affairs': 0,
    'English': 0,
    'Maths': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    for (String subject in _subjectCounts.keys) {
      int count = await FirestoreService.getSubjectQuestionCount(subject);
      if (mounted) {
        setState(() {
          _subjectCounts[subject] = count;
        });
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
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
      ),
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text(
              'Knowledge Core',
              style: GoogleFonts.sora(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Master complex concepts through precision-engineered assessments. Intellectual rigor, distilled.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // AI Generator Card
            _buildAIGeneratorCard(context),
            
            const SizedBox(height: 16),
            
            // Standard Subject Cards
            _buildDynamicSubjectCard(
              context: context,
              title: 'Computer',
              color: AppTheme.secondary,
            ),
            const SizedBox(height: 16),
            _buildDynamicSubjectCard(
              context: context,
              title: 'Aptitude',
              color: AppTheme.primary,
            ),
            const SizedBox(height: 16),
            _buildDynamicSubjectCard(
              context: context,
              title: 'GK',
              color: AppTheme.secondary,
            ),
            const SizedBox(height: 16),
            _buildDynamicSubjectCard(
              context: context,
              title: 'Current Affairs',
              color: AppTheme.primary,
              isHighlighted: true,
            ),
            const SizedBox(height: 16),
            _buildDynamicSubjectCard(
              context: context,
              title: 'English',
              color: AppTheme.primary,
            ),
            const SizedBox(height: 16),
            _buildDynamicSubjectCard(
              context: context,
              title: 'Maths',
              color: AppTheme.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIGeneratorCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AiQuizScreen(subject: 'Custom AI Quiz')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHigh.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Lumina AI',
                          style: GoogleFonts.sora(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Neural Quiz Generator',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    'NEW',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create a custom test on any topic',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, color: AppTheme.primary, size: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicSubjectCard({
    required BuildContext context,
    required String title,
    required Color color,
    bool isHighlighted = false,
  }) {
    int count = _subjectCounts[title] ?? 0;
    bool isLocked = count == 0;
    String subtitle = '$count Questions';
    String progressLabel = isLocked ? 'Coming Soon' : 'Ready to Start';
    double progress = 0.0;
    
    Color cardColor = isLocked ? AppTheme.onSurfaceVariant.withOpacity(0.5) : color;

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No questions available for $title yet.'),
              backgroundColor: AppTheme.surfaceContainerHigh,
            ),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AiQuizScreen(subject: title)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHigh.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(
              color: (isHighlighted && !isLocked) ? cardColor : Colors.transparent,
              width: 4,
            ),
            top: BorderSide(color: Colors.white.withOpacity(0.05)),
            right: BorderSide(color: Colors.white.withOpacity(0.05)),
            bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.sora(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isLocked ? AppTheme.onSurfaceVariant : AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  progressLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cardColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
