class ReelContent {
  final String subject;
  final String moduleId;
  final String sectionTitle;
  final String conceptTitle;
  final String coreRule;
  final List<Example> examples;
  final MasteryCheck masteryCheck;
  final Flashcard flashcard;

  ReelContent({
    required this.subject,
    required this.moduleId,
    required this.sectionTitle,
    required this.conceptTitle,
    required this.coreRule,
    required this.examples,
    required this.masteryCheck,
    required this.flashcard,
  });

  factory ReelContent.fromJson(Map<String, dynamic> json) {
    // Use the specific subject if available, otherwise fallback
    String subject = json['subject'] ?? 'English';
    if (json['subject'] == null && json['segment'] == 'computer') {
      subject = 'Computer';
    }

    return ReelContent(
      subject: subject,
      moduleId: json['moduleId'] ?? '',
      sectionTitle: json['sectionTitle'] ?? '',
      conceptTitle: json['conceptTitle'] ?? '',
      coreRule: json['coreRule'] ?? json['coreConcept'] ?? '',
      examples: (json['examples'] as List).map((e) => Example.fromJson(e)).toList(),
      masteryCheck: MasteryCheck.fromJson(json['masteryCheck']),
      flashcard: Flashcard.fromJson(json['flashcard']),
    );
  }
}

class Example {
  final String text;
  final bool isCorrect;

  Example({required this.text, required this.isCorrect});

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      text: json['text'] ?? json['code'] ?? '',
      isCorrect: json['isCorrect'] ?? true, // Default to true for C code snippets
    );
  }
}

class MasteryCheck {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  MasteryCheck({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory MasteryCheck.fromJson(Map<String, dynamic> json) {
    return MasteryCheck(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctIndex: json['correctIndex'],
      explanation: json['explanation'],
    );
  }
}

class Flashcard {
  final String front;
  final String back;

  Flashcard({required this.front, required this.back});

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      front: json['front'],
      back: json['back'],
    );
  }
}
