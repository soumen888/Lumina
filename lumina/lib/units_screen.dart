import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'data/firestore_service.dart';
import 'learn_screen.dart';

class UnitsScreen extends StatefulWidget {
  final String subject;

  const UnitsScreen({super.key, required this.subject});

  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  bool _isLoading = true;
  List<String> _units = [];

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    final units = await FirestoreService.fetchUnitsForSubject(widget.subject);
    if (mounted) {
      setState(() {
        _units = units;
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
          '${widget.subject.toUpperCase()} UNITS',
          style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : _units.isEmpty
                ? Center(
                    child: Text(
                      'No units available for ${widget.subject}.',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: _units.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final unit = _units[index];
                      return _buildUnitCard(context, unit, index);
                    },
                  ),
      ),
    );
  }

  Widget _buildUnitCard(BuildContext context, String unitTitle, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LearnScreen(
              subject: widget.subject,
              sectionTitle: unitTitle,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.sora(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                unitTitle,
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white30),
          ],
        ),
      ),
    );
  }
}
