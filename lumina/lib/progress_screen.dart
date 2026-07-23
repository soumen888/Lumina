import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'learn_screen.dart';
import 'computer_subjects_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final Map<String, int> _totalReels = {};
  final Map<String, int> _masteredReels = {};
  int _totalMastered = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final firestore = FirebaseFirestore.instance;
    final prefs = await SharedPreferences.getInstance();

    final subjects = ['English', 'Aptitude', 'General Knowledge', 'Computer'];
    int totalMastered = 0;

    for (String subject in subjects) {
      try {
        final countQuery = await firestore.collection('reels').where('subject', isEqualTo: subject).count().get();
        _totalReels[subject] = countQuery.count ?? 0;
      } catch (e) {
        _totalReels[subject] = 0;
      }

      final mastered = prefs.getStringList('mastered_$subject') ?? [];
      _masteredReels[subject] = mastered.length;
      totalMastered += mastered.length;
    }

    if (mounted) {
      setState(() {
        _totalMastered = totalMastered;
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
          'YOUR PROGRESS',
          style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
            letterSpacing: 2.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
        : SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // Overall Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.local_fire_department,
                    value: '1',
                    label: 'DAY STREAK',
                    color: AppTheme.tertiary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.psychology,
                    value: '$_totalMastered',
                    label: 'MASTERED',
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            Text(
              'SYLLABUS MASTERY',
              style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 16),
            
            // Grid of subjects
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSubjectCard(
                  title: 'English',
                  icon: Icons.menu_book,
                  color: const Color(0xFFC0C1FF),
                ),
                _buildSubjectCard(
                  title: 'Aptitude',
                  icon: Icons.calculate,
                  color: const Color(0xFF4EDEA3),
                ),
                _buildSubjectCard(
                  title: 'General Knowledge',
                  icon: Icons.public,
                  color: const Color(0xFFFFB2B7),
                ),
                _buildSubjectCard(
                  title: 'Computer',
                  icon: Icons.computer,
                  color: const Color(0xFF94A3B8),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Insights Widget
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.2),
                    AppTheme.surfaceContainerHighest,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'AI INSIGHT',
                        style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.primary,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select a subject above to begin learning! Your mastery score goes up when you successfully pass quizzes.',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTheme.darkTheme.textTheme.displayMedium,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    int total = _totalReels[title] ?? 0;
    int mastered = _masteredReels[title] ?? 0;
    double progress = total > 0 ? (mastered / total) : 0.0;

    return GestureDetector(
      onTap: () {
        if (title == 'Computer') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ComputerSubjectsScreen(isForSaved: false)),
          ).then((_) {
            _loadProgressData();
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LearnScreen(subject: title)),
          ).then((_) {
            // Reload progress when coming back
            _loadProgressData();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title.replaceAll(' ', '\n'), // Wraps 'General Knowledge' nicely
              style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.05),
              color: color,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      ),
    );
  }
}
