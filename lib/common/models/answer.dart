class Answer {
  final String questionId;
  final bool needText;
  final String? text;
  final bool needPhoto;
  final String? photoUrl;

  Answer({
    required this.questionId,
    required this.needText,
    this.text,
    required this.needPhoto,
    this.photoUrl,
  });
}
