//models.dart
import 'package:flutter/material.dart';

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class CategoryData {
  final String name;
  final IconData icon;
  final Color color;
  final int quizCount;

  CategoryData(this.name, this.icon, this.color, this.quizCount);
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}
class QuizQuestionData {
  String question;
  List<String> options;
  int correctAnswer;

  QuizQuestionData({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}