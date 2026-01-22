// packages/forum_repository/lib/src/models/forum_post_source.dart

import 'package:equatable/equatable.dart';

/// Source reference for a forum post
class ForumPostSource extends Equatable {
  const ForumPostSource({
    required this.title,
    required this.url,
    this.snippet,
  });

  final String title;
  final String url;
  final String? snippet;

  factory ForumPostSource.fromJson(Map<String, dynamic> json) {
    return ForumPostSource(
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
