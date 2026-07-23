class QuizQuestion {
  final String id;
  final String subject;
  final String question;
  final String context;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({
    required this.id,
    required this.subject,
    required this.question,
    required this.context,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json, String documentId) {
    return QuizQuestion(
      id: documentId,
      subject: json['subject'] ?? 'GENERAL',
      question: json['question'] ?? '',
      context: json['context'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correctIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'question': question,
      'context': context,
      'options': options,
      'correctIndex': correctIndex,
    };
  }
}
