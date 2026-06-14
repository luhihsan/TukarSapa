class Question {
  final int id;
  final String category;
  final String question;

  Question({
    required this.id,
    required this.category,
    required this.question,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      category: json['category'] as String,
      question: json['question'] as String,
    );
  }
}