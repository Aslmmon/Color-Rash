// lib/domain/tutorial_page_content.dart
import 'package:flutter/material.dart'; // For Widget type in visuals

class TutorialPageContent {
  final String title;
  final String body;
  final String? imagePath; // Optional image to display
  final Widget? visualWidget; // Optional custom widget for visual aid

  const TutorialPageContent({
    required this.title,
    required this.body,
    this.imagePath,
    this.visualWidget,
  });
}
