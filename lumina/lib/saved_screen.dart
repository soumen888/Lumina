import 'package:flutter/material.dart';
import 'theme.dart';
import 'flashcard_screen.dart';
import 'computer_subjects_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface.withOpacity(0.8),
        elevation: 0,
        title: Text(
          'SAVED FLASHCARDS',
          style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text(
              'REVIEW BY SUBJECT',
              style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSubjectCard(
                  context: context,
                  title: 'English',
                  icon: Icons.menu_book,
                  color: const Color(0xFFC0C1FF),
                ),
                _buildSubjectCard(
                  context: context,
                  title: 'Aptitude',
                  icon: Icons.calculate,
                  color: const Color(0xFF4EDEA3),
                ),
                _buildSubjectCard(
                  context: context,
                  title: 'General Knowledge',
                  icon: Icons.public,
                  color: const Color(0xFFFFB2B7),
                ),
                _buildSubjectCard(
                  context: context,
                  title: 'Computer',
                  icon: Icons.computer,
                  color: const Color(0xFF94A3B8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        if (title == 'Computer') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ComputerSubjectsScreen(isForSaved: true)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FlashcardScreen(subject: title)),
          );
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const Spacer(),
            Text(
              title.replaceAll(' ', '\n'),
              style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
