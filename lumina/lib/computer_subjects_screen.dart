import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';
import 'learn_screen.dart';
import 'flashcard_screen.dart';
import 'units_screen.dart';

class ComputerSubjectsScreen extends StatelessWidget {
  final bool isForSaved;

  const ComputerSubjectsScreen({
    super.key,
    required this.isForSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface.withOpacity(0.8),
        elevation: 0,
        title: Text(
          'COMPUTER SUBJECTS',
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
              'SELECT A SUBJECT',
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
                  title: 'C Programming',
                  icon: Icons.code,
                  color: const Color(0xFF4DB6AC),
                ),
                _buildSubjectCard(
                  context: context,
                  title: 'Python',
                  icon: Icons.terminal,
                  color: const Color(0xFFFFD54F),
                ),
                _buildSubjectCard(
                  context: context,
                  title: 'SQL',
                  icon: Icons.dataset,
                  color: const Color(0xFF64B5F6),
                ),
                _buildSubjectCard(
                  context: context,
                  title: 'DBMS',
                  icon: Icons.storage,
                  color: const Color(0xFFBA68C8),
                ),
                _buildSubjectCard(
                  context: context,
                  title: 'DSA',
                  icon: Icons.account_tree,
                  color: const Color(0xFFFF8A65),
                ),
                _buildSubjectCard(
                  context: context,
                  title: 'Digital Logic',
                  icon: Icons.memory,
                  color: const Color(0xFFAED581),
                ),
                _buildSubjectCard(
                  context: context,
                  title: 'Computer Fundamentals',
                  icon: Icons.computer,
                  color: const Color(0xFF90A4AE),
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
        if (isForSaved) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FlashcardScreen(subject: title)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UnitsScreen(subject: title)),
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
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<AggregateQuerySnapshot>(
              future: FirebaseFirestore.instance.collection('reels').where('subject', isEqualTo: title).count().get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    'Calculating...',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white38,
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  );
                }
                final count = snapshot.data?.count ?? 0;
                return Text(
                  '$count REELS',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: color.withOpacity(0.9),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
