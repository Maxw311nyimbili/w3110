// packages/chat_repository/lib/src/models/source_reference.dart

import 'package:equatable/equatable.dart';

/// Source reference/citation for AI responses
class SourceReference extends Equatable {
  const SourceReference({
    required this.title,
    required this.url,
    this.snippet,
  });

  final String title;
  final String url;
  final String? snippet;

  factory SourceReference.fromJson(Map<String, dynamic> json) {
    return SourceReference(
      title: json['title'] as String,
      url: json['url'] as String,
      snippet: json['snippet'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'snippet': snippet,
    };
  }

  @override
  List<Object?> get props => [title, url, snippet];
}
