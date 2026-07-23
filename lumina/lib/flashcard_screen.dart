import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'theme.dart';
import 'data/firestore_service.dart';
import 'models/reel_content.dart';

class FlashcardScreen extends StatefulWidget {
  final String subject;
  
  const FlashcardScreen({
    super.key, 
    required this.subject,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  late Future<List<ReelContent>> _reelsFuture;
  final CardSwiperController _swiperController = CardSwiperController();
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isArchiveMode = false;

  @override
  void initState() {
    super.initState();
    _reelsFuture = _fetchReels();
  }

  Future<List<ReelContent>> _fetchReels() async {
    final prefs = await SharedPreferences.getInstance();
    final mastered = prefs.getStringList('mastered_${widget.subject}') ?? [];
    
    final res = await FirestoreService.fetchReelsPage(widget.subject, limit: 500);
    
    if (_isArchiveMode) {
      if (mastered.isEmpty) return [];
      return res.reels.where((r) => mastered.contains(r.conceptTitle)).toList();
    }
    
    return res.reels;
  }
  
  // Mastery check is strictly done via MCQ in LearnScreen now.

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ReelContent>>(
      future: _reelsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.background,
            body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          );
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            backgroundColor: AppTheme.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent, 
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  if (_isArchiveMode) {
                    setState(() {
                      _isArchiveMode = false;
                      _currentIndex = 0;
                      _isFlipped = false;
                      _reelsFuture = _fetchReels();
                    });
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.white24),
                    const SizedBox(height: 16),
                    Text(
                      _isArchiveMode ? 'Your Archive is Empty!' : 'No Flashcards Available',
                      style: AppTheme.darkTheme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isArchiveMode 
                        ? 'Go to the Learn tab and pass some Mastery Checks. Once you master a reel, it will be moved here for you to review later.'
                        : 'We could not find any flashcards for this subject.',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(color: Colors.white60),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final reels = snapshot.data!;
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.surface.withOpacity(0.8),
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                if (_isArchiveMode) {
                  setState(() {
                    _isArchiveMode = false;
                    _currentIndex = 0;
                    _isFlipped = false;
                    _reelsFuture = _fetchReels();
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: Row(
              children: [
                const Icon(Icons.bolt, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  _isArchiveMode ? 'ARCHIVED REELS' : widget.subject.toUpperCase(),
                  style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primary,
                    letterSpacing: 2.0,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Review Mode',
                            style: AppTheme.darkTheme.textTheme.headlineSmall,
                          ),
                          Text(
                            '${_currentIndex + 1}/${reels.length} Flashcards',
                            style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / reels.length,
                    backgroundColor: AppTheme.surfaceContainerHighest,
                    color: AppTheme.secondary,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  const SizedBox(height: 32),
                  
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: reels.isEmpty 
                          ? const Center(child: Text('All caught up!'))
                          : CardSwiper(
                              controller: _swiperController,
                              cardsCount: reels.length,
                              onSwipe: (previousIndex, currentIndex, direction) {
                                setState(() {
                                  _currentIndex = currentIndex ?? _currentIndex;
                                  _isFlipped = false;
                                });
                                return true;
                              },
                              cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isFlipped = !_isFlipped;
                                    });
                                  },
                                  child: _buildActiveCard(reels[index]),
                                );
                              },
                            ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (!_isArchiveMode) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isArchiveMode = true;
                                _currentIndex = 0;
                                _isFlipped = false;
                                _reelsFuture = _fetchReels(); // Refresh the list for archive mode
                              });
                            },
                            icon: const Icon(Icons.inventory_2_outlined),
                            label: const Text('ARCHIVES'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.onSurfaceVariant,
                              backgroundColor: AppTheme.surfaceContainerHighest,
                              side: const BorderSide(color: Colors.white10),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_currentIndex < reels.length - 1) {
                              _swiperController.swipe(CardSwiperDirection.right);
                            } else if (_currentIndex == reels.length - 1 && reels.isNotEmpty) {
                              // Final swipe, swiper handles it visually. We just force a state update so it shows "All caught up"
                              setState(() { _currentIndex++; });
                            }
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('GOT IT'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppTheme.background,
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveCard(ReelContent content) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      content.sectionTitle,
                      style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.primary,
                        fontSize: 10,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    content.conceptTitle,
                    style: AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isFlipped ? content.flashcard.back : content.flashcard.front,
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      fontSize: _isFlipped ? 20 : 16,
                      fontWeight: _isFlipped ? FontWeight.w500 : FontWeight.normal,
                      color: _isFlipped ? Colors.white : AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _isFlipped = !_isFlipped;
                });
              },
              icon: const Icon(Icons.refresh, color: Colors.white60),
              label: Text(
                _isFlipped ? 'TAP TO SEE QUESTION' : 'TAP TO SEE ANSWER',
                style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                  color: Colors.white60,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
