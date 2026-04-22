class GeneratedCard{
  final String cardType; // flashcard | quiz | fillInBlank | explainer
  final Map<String, dynamic> content;

  const GeneratedCard({
    required this.cardType,
    required this.content,
  });
}