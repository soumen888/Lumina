import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'dart:ui';
import 'theme.dart';
import 'data/firestore_service.dart';
import 'models/reel_content.dart';

class LearnScreen extends StatefulWidget {
  final String subject;
  final String? sectionTitle;
  
  const LearnScreen({super.key, required this.subject, this.sectionTitle});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  int _totalReelsCount = 0;
  int _masteredCount = 0;

  List<ReelContent> _reels = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = true;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadSavedProgress();
    
    // Initialize PageController with the loaded saved index
    _pageController = PageController(initialPage: _currentIndex);
    
    await _loadMasteryProgress();
    await _fetchInitialReels();
  }

  Future<void> _fetchInitialReels() async {
    setState(() => _isLoading = true);
    
    // Fetch enough to reach _currentIndex, plus a small buffer
    final limit = _currentIndex + 5;
    
    final prefs = await SharedPreferences.getInstance();
    final mastered = prefs.getStringList('mastered_${widget.subject}') ?? [];
    
    final result = await FirestoreService.fetchReelsPage(
      widget.subject, 
      sectionTitle: widget.sectionTitle,
      limit: limit,
      excludeTitles: mastered,
    );
    if (mounted) {
      setState(() {
        _reels = result.reels;
        _lastDocument = result.lastDocument;
        _hasMore = result.hasMore;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMasteryProgress() async {
    final firestore = FirebaseFirestore.instance;
    final prefs = await SharedPreferences.getInstance();
    
    try {
      Query query = firestore.collection('reels').where('subject', isEqualTo: widget.subject);
      if (widget.sectionTitle != null) {
        query = query.where('sectionTitle', isEqualTo: widget.sectionTitle);
      }
      final countQuery = await query.count().get();
      _totalReelsCount = countQuery.count ?? 0;
    } catch (e) {
      _totalReelsCount = 0;
    }

    final mastered = prefs.getStringList('mastered_${widget.subject}') ?? [];
    if (mounted) {
      setState(() {
        _masteredCount = mastered.length;
      });
    }
  }

  Future<void> _fetchMoreReels() async {
    if (!_hasMore || _isFetchingMore) return;

    setState(() => _isFetchingMore = true);
    
    final prefs = await SharedPreferences.getInstance();
    final mastered = prefs.getStringList('mastered_${widget.subject}') ?? [];
    
    final result = await FirestoreService.fetchReelsPage(
      widget.subject, 
      sectionTitle: widget.sectionTitle,
      startAfter: _lastDocument,
      excludeTitles: mastered,
    );
    
    if (mounted) {
      setState(() {
        _reels.addAll(result.reels);
        _lastDocument = result.lastDocument;
        _hasMore = result.hasMore;
        _isFetchingMore = false;
      });
    }
  }

  Future<void> _loadSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndexKey = widget.sectionTitle != null ? 'last_reel_index_${widget.subject}_${widget.sectionTitle}' : 'last_reel_index_${widget.subject}';
    final savedIndex = prefs.getInt(savedIndexKey) ?? 0;
    if (mounted) {
      _currentIndex = savedIndex;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.bolt, color: AppTheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                (widget.sectionTitle ?? widget.subject).toUpperCase(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: _totalReelsCount > 0
              ? LinearProgressIndicator(
                  value: _masteredCount / _totalReelsCount,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  color: AppTheme.secondary,
                  minHeight: 4,
                )
              : const SizedBox(height: 4),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : _reels.isEmpty
              ? Center(
                  child: Text('No contents generated for ${widget.subject} yet.',
                      style: const TextStyle(color: Colors.white70)),
                )
              : PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
                  itemCount: _reels.length + (_hasMore ? 1 : 0),
                  onPageChanged: (index) async {
                    setState(() {
                      _currentIndex = index;
                    });
                    
                    // Fetch more when approaching the end
                    if (index >= _reels.length - 2) {
                      _fetchMoreReels();
                    }

                    final prefs = await SharedPreferences.getInstance();
                    final savedIndexKey = widget.sectionTitle != null ? 'last_reel_index_${widget.subject}_${widget.sectionTitle}' : 'last_reel_index_${widget.subject}';
                    prefs.setInt(savedIndexKey, index);
                  },
                  itemBuilder: (context, index) {
                    if (index == _reels.length) {
                      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                    }

                    return ReelCard(
                      content: _reels[index],
                      isCurrent: index == _currentIndex,
                      onCorrectAnswer: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                        );
                      },
                      onMasteryGained: () {
                        setState(() {
                          _masteredCount++;
                        });
                      },
                    );
                  },
                ),
    );
  }
}

class ReelCard extends StatefulWidget {
  final ReelContent content;
  final bool isCurrent;
  final VoidCallback onCorrectAnswer;
  final VoidCallback onMasteryGained;

  const ReelCard({
    super.key, 
    required this.content, 
    required this.isCurrent, 
    required this.onCorrectAnswer,
    required this.onMasteryGained,
  });

  @override
  State<ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<ReelCard> with TickerProviderStateMixin {
  int? _selectedOptionIndex;
  bool _isMasteryCheckVisible = false;

  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isCurrent) {
      _entranceController.forward();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ReelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrent && !oldWidget.isCurrent) {
      _entranceController.forward(from: 0.0);
      _pulseController.repeat(reverse: true);
    } else if (!widget.isCurrent && oldWidget.isCurrent) {
      _entranceController.reset();
      _pulseController.stop();
      setState(() {
        _isMasteryCheckVisible = false;
        _selectedOptionIndex = null;
      });
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedItem(Widget child, int index, int totalItems) {
    final double start = (index / totalItems) * 0.6;
    final double end = start + 0.4;
    
    final Animation<double> opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );

    final Animation<Offset> offset = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: offset,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content;

    return Container(
      color: AppTheme.background,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildAnimatedItem(
                                    Text(
                                      content.sectionTitle,
                                      style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                                        color: Colors.white38,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                    0, 5,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildAnimatedItem(
                                    Text(
                                      content.conceptTitle,
                                      textAlign: TextAlign.center,
                                      style: AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
                                        height: 1.2,
                                      ),
                                    ),
                                    1, 5,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildAnimatedItem(
                                    Text(
                                      content.coreRule,
                                      textAlign: TextAlign.center,
                                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                    ),
                                    2, 5,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildAnimatedItem(
                                    Column(
                                      children: content.examples.map((example) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: _buildExampleCard(
                                          text: example.text,
                                          isCorrect: example.isCorrect,
                                        ),
                                      )).toList(),
                                    ),
                                    3, 5,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                          _buildAnimatedItem(
                            Column(
                              children: [
                                const Divider(color: Colors.white10),
                                const SizedBox(height: 8),
                                AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 400),
                                  crossFadeState: _isMasteryCheckVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                  firstChild: Center(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _isMasteryCheckVisible = true;
                                        });
                                      },
                                      icon: const Icon(Icons.school, color: AppTheme.onSurfaceVariant),
                                      label: Text(
                                        'TAKE MASTERY CHECK',
                                        style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2.0,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(double.infinity, 56),
                                        side: BorderSide(color: Colors.white.withOpacity(0.05)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                  secondChild: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isMasteryCheckVisible = false;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'MASTERY CHECK',
                                                style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                                                  color: Colors.white30,
                                                  letterSpacing: 2.0,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(Icons.expand_less, color: Colors.white30, size: 16),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        content.masteryCheck.question,
                                        textAlign: TextAlign.center,
                                        style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.white70,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: List.generate(content.masteryCheck.options.length, (index) {
                                          final isSelected = _selectedOptionIndex == index;
                                          final isCorrect = index == content.masteryCheck.correctIndex;
                                          
                                          Color buttonColor = Colors.white.withOpacity(0.05);
                                          Color textColor = Colors.white60;
                                          
                                          if (_selectedOptionIndex != null) {
                                            if (isCorrect) {
                                              buttonColor = AppTheme.secondary.withOpacity(0.2);
                                              textColor = AppTheme.secondary;
                                            } else if (isSelected) {
                                              buttonColor = AppTheme.error.withOpacity(0.2);
                                              textColor = AppTheme.error;
                                            }
                                          }

                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: OutlinedButton(
                                              onPressed: () async {
                                                if (_selectedOptionIndex == null) {
                                                  setState(() {
                                                    _selectedOptionIndex = index;
                                                  });
                                                  if (index == content.masteryCheck.correctIndex) {
                                                    final prefs = await SharedPreferences.getInstance();
                                                    List<String> mastered = prefs.getStringList('mastered_${content.subject}') ?? [];
                                                    if (!mastered.contains(content.conceptTitle)) {
                                                      mastered.add(content.conceptTitle);
                                                      await prefs.setStringList('mastered_${content.subject}', mastered);
                                                      
                                                      // Notify parent to update progress bar
                                                      if (mounted) {
                                                        widget.onMasteryGained();
                                                      }
                                                    }
                                                    
                                                    // Automatically scroll to next reel after a short delay
                                                    Future.delayed(const Duration(milliseconds: 800), () {
                                                      if (mounted && widget.isCurrent) {
                                                        widget.onCorrectAnswer();
                                                      }
                                                    });
                                                  }
                                                }
                                              },
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: textColor,
                                                side: BorderSide(
                                                  color: textColor.withOpacity(0.3),
                                                ),
                                                backgroundColor: buttonColor,
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                              ),
                                              child: Text(
                                                content.masteryCheck.options[index],
                                                style: const TextStyle(letterSpacing: 0.5, fontWeight: FontWeight.bold, fontSize: 13),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            4, 5,
                          ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

  Widget _buildExampleCard({required String text, required bool isCorrect}) {
    final bool isCode = widget.content.subject.toLowerCase().contains('c ') || widget.content.subject.toLowerCase().contains('programming') || widget.content.subject.toLowerCase() == 'computer';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: isCode
          ? HighlightView(
              text,
              language: 'c',
              theme: Map<String, TextStyle>.from(atomOneDarkTheme)..update(
                'root', 
                (style) => TextStyle(backgroundColor: Colors.transparent, color: style.color),
                ifAbsent: () => const TextStyle(backgroundColor: Colors.transparent, color: Color(0xffabb2bf)),
              ),
              textStyle: GoogleFonts.jetBrainsMono(
                fontSize: 16,
                height: 1.6,
              ),
              padding: EdgeInsets.zero,
            )
          : Text(
              text,
              style: TextStyle(
                color: isCorrect ? Colors.white : Colors.white54,
                fontStyle: isCorrect ? FontStyle.normal : FontStyle.italic,
                decoration: isCorrect ? TextDecoration.none : TextDecoration.lineThrough,
                decorationColor: AppTheme.error.withOpacity(0.8),
                fontSize: 16,
                height: 1.6,
              ),
            ),
    );
  }
}

