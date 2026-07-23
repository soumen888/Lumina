import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reel_content.dart';
import '../models/quiz_question.dart';

class PaginatedReelsResult {
  final List<ReelContent> reels;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  PaginatedReelsResult({
    required this.reels,
    this.lastDocument,
    required this.hasMore,
  });
}

class FirestoreService {
  static Future<PaginatedReelsResult> fetchReelsPage(String subject, {String? sectionTitle, DocumentSnapshot? startAfter, int limit = 5, List<String>? excludeTitles}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // 1. Query Firestore with subject filter and pagination limits
      Query query = firestore
          .collection('reels')
          .where('subject', isEqualTo: subject);
          
      if (sectionTitle != null && sectionTitle.isNotEmpty) {
        query = query.where('sectionTitle', isEqualTo: sectionTitle);
      }
      
      query = query.orderBy('orderIndex');
      // Fetch a larger batch (e.g. 30) since we might filter out many mastered ones client-side
      query = query.limit(limit > 30 ? limit : 30);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final QuerySnapshot querySnapshot = await query.get();
      
      List<ReelContent> reels = querySnapshot.docs.map((doc) => ReelContent.fromJson(doc.data() as Map<String, dynamic>)).toList();
      
      if (excludeTitles != null && excludeTitles.isNotEmpty) {
        reels = reels.where((r) => !excludeTitles.contains(r.conceptTitle)).toList();
      }

      // We no longer truncate to `limit` because that causes the `lastDoc` pointer to 
      // skip over un-returned items. We just return all the valid reels we found in this batch!
      final hasMore = querySnapshot.docs.length == (limit > 30 ? limit : 30);
      final lastDoc = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;

      return PaginatedReelsResult(
        reels: reels,
        lastDocument: lastDoc,
        hasMore: hasMore,
      );
    } catch (e) {
      print("Error fetching paginated reels: $e");
      return PaginatedReelsResult(reels: [], hasMore: false);
    }
  }

  static Future<List<String>> fetchUnitsForSubject(String subject) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore
          .collection('reels')
          .where('subject', isEqualTo: subject)
          .orderBy('orderIndex')
          .get();

      // Use a LinkedHashSet to preserve order while removing duplicates
      final Set<String> units = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('sectionTitle') && data['sectionTitle'] != null) {
          final title = data['sectionTitle'] as String;
          if (title.isNotEmpty) {
            units.add(title);
          }
        }
      }
      return units.toList();
    } catch (e) {
      print("Error fetching units for $subject: $e");
      return [];
    }
  }

  static Future<List<QuizQuestion>> fetchQuizQuestions({required String subject, int limit = 25}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore
          .collection('mcqs')
          .where('subject', isEqualTo: subject)
          .limit(limit)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        // Return some dummy data if database is empty so the UI doesn't break
        return [
          QuizQuestion(
            id: 'mock1',
            subject: subject.toUpperCase(),
            question: 'What is a core concept in $subject?',
            context: 'Select the most appropriate answer to demonstrate foundational knowledge.',
            options: ['Concept A', 'Concept B', 'Concept C', 'Concept D'],
            correctIndex: 0,
          ),
          QuizQuestion(
            id: 'mock2',
            subject: subject.toUpperCase(),
            question: 'Which of the following best describes an advanced feature in $subject?',
            context: 'Think about higher-level applications.',
            options: ['Feature X', 'Feature Y', 'Feature Z', 'Feature W'],
            correctIndex: 1,
          ),
        ];
      }

      return querySnapshot.docs
          .map((doc) => QuizQuestion.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print("Error fetching quiz questions: $e");
      return [];
    }
  }

  static Future<int> getSubjectQuestionCount(String subject) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore
          .collection('mcqs')
          .where('subject', isEqualTo: subject)
          .count()
          .get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      print("Error fetching count for $subject: $e");
      return 0;
    }
  }
}
