// packages/forum_repository/lib/src/forum_repository.dart

import 'package:api_client/api_client.dart';
import 'package:drift/drift.dart';

import 'database/forum_database.dart';
import 'models/forum_answer_line.dart';
import 'models/forum_comment.dart';
import 'models/forum_line_comment.dart';
import 'models/forum_post.dart';
import 'models/forum_post_source.dart';
import 'dart:convert';
import 'models/sync_status.dart';
import 'sync/conflict_resolver.dart';
import 'sync/sync_manager.dart';

/// Forum repository - handles forum posts, comments, and offline sync
class ForumRepository {
  ForumRepository({
    required ApiClient apiClient,
    required ForumDatabase database,
  })  : _apiClient = apiClient,
        _database = database,
        _syncManager = SyncManager(apiClient: apiClient, database: database),
        _conflictResolver = ConflictResolver(database: database);

  final ApiClient _apiClient;
  final ForumDatabase _database;
  final SyncManager _syncManager;
  final ConflictResolver _conflictResolver;

  // ============================================================
  // LOCAL OPERATIONS (always available offline)
  // ============================================================

  /// Get all posts from local database
  Future<List<ForumPost>> getLocalPosts() async {
    final posts = await _database.getAllPosts();
    return posts.map((data) => ForumPost.fromDatabase(data)).toList();
  }

  /// Get comments for a post from local database
  Future<List<ForumComment>> getLocalComments(String postId) async {
    final comments = await _database.getCommentsForPost(postId);
    return comments.map((data) => ForumComment.fromDatabase(data)).toList();
  }

  /// Create post locally (instant feedback)
  Future<void> createLocalPost({
    required String localId,
    required String title,
    required String content,
    required String authorId,
    required String authorName,
    List<ForumPostSource> sources = const [],
    List<String> tags = const [],
  }) async {
    await _database.insertPost(ForumPostsCompanion.insert(
      localId: localId,
      authorId: authorId,
      authorName: authorName,
      title: title,
      content: content,
      createdAt: DateTime.now(),
      syncStatus: const Value('pending'),
      sources: Value(sources.isNotEmpty ? jsonEncode(sources.map((e) => e.toJson()).toList()) : null),
      tags: Value(tags.isNotEmpty ? jsonEncode(tags) : null),
    ));
  }

  /// Create comment locally (instant feedback)
  Future<void> createLocalComment({
    required String localId,
    required String postId,
    required String content,
    required String authorId,
    required String authorName,
  }) async {
    await _database.insertComment(ForumCommentsCompanion.insert(
      localId: localId,
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      content: content,
      createdAt: DateTime.now(),
      syncStatus: const Value('pending'),
    ));
  }

  // ============================================================
  // SYNC OPERATIONS (requires network)
  // ============================================================

  /// Add item to sync queue
  Future<void> addToSyncQueue({
    required String entityType,
    required String entityId,
    required String action,
  }) async {
    await _database.addToSyncQueue(
      entityType: entityType,
      entityId: entityId,
      action: action,
    );
  }

  /// Process sync queue (upload pending changes)
  Future<void> processSyncQueue() async {
    await _syncManager.processSyncQueue();
  }

  /// Fetch posts from server and merge with local
  Future<void> fetchPostsFromServer({DateTime? since}) async {
    final serverPosts = await _syncManager.fetchPostsFromServer(since: since);
    await _conflictResolver.mergeServerPosts(serverPosts);
  }

  /// Search for posts
  Future<List<ForumPost>> searchPosts(String query) async {
    try {
      final response = await _apiClient.get('/forum/search', queryParameters: {'q': query});
      final List<dynamic> postsJson = response.data as List<dynamic>;
      return postsJson.map((json) => ForumPost.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ForumException('Failed to search posts: ${e.toString()}');
    }
  }

  /// Toggle like on post
  Future<void> togglePostLike(String postId) async {
    try {
      await _apiClient.post('/forum/posts/$postId/like');
    } catch (e) {
      throw ForumException('Failed to like post: ${e.toString()}');
    }
  }

  /// Toggle like on comment
  Future<void> toggleCommentLike(String commentId) async {
    try {
      await _apiClient.post('/forum/comments/$commentId/like');
    } catch (e) {
      throw ForumException('Failed to like comment: ${e.toString()}');
    }
  }

  /// Flag/Report a post
  Future<void> flagPost(String postId) async {
    try {
      await _apiClient.post('/forum/posts/$postId/flag');
    } catch (e) {
      throw ForumException('Failed to flag post: ${e.toString()}');
    }
  }

  /// Check if there are pending sync items
  Future<bool> hasPendingSyncItems() async {
    return await _database.hasPendingSyncItems();
  }

  /// Merge server data with local data
  Future<void> mergeServerData(List<ForumPost> serverPosts) async {
    await _conflictResolver.mergeServerPosts(serverPosts);
  }

  // ============================================================
  // LINE-LEVEL FORUM (NEW FEATURE)
  // ============================================================
  
  // Use real backend now
  final bool _useMock = false; 

  /// Publish (or get) lines for a specific answer
  Future<List<ForumAnswerLine>> getLinesForAnswer(String answerId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate net
      return _generateMockLines(answerId);
    }
    
    try {
      final response = await _apiClient.post(
        '/api/v1/forum/answers/publish',
        data: {'answer_id': answerId, 'share_to_forum': true},
      );
      final list = response.data['lines'] as List;
      return list.map((e) => ForumAnswerLine.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get comments for a specific line
  Future<List<ForumLineComment>> getCommentsForLine(
    String lineId, {
    String filter = 'all',
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _generateMockComments(lineId, filter);
    }

    try {
      final response = await _apiClient.get(
        '/api/v1/forum/lines/$lineId/comments',
        queryParameters: {'filter': filter},
      );
      final list = response.data['comments'] as List;
      return list.map((e) => ForumLineComment.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Post a comment to a line
  Future<ForumLineComment> postLineComment({
    required String lineId,
    required String text,
    required String commentType,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return ForumLineComment(
        id: 'mock_comment_${DateTime.now().millisecondsSinceEpoch}',
        lineId: lineId,
        authorId: 'current_user',
        authorName: 'You',
        authorRole: CommentRole.community,
        commentType: _parseCommentType(commentType),
        text: text,
        createdAt: DateTime.now(),
        syncStatus: SyncStatus.synced,
      );
    }

    try {
      final response = await _apiClient.post(
        '/api/v1/forum/lines/$lineId/comments',
        data: {
          'text': text,
          'comment_type': commentType,
        },
      );
      return ForumLineComment.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ForumException('Failed to post comment: ${e.toString()}');
    }
  }

  // --- MOCK DATA GENERATORS ---

  List<ForumAnswerLine> _generateMockLines(String answerId) {
    return [
      ForumAnswerLine(
        lineId: '${answerId}_L1',
        answerId: answerId,
        lineNumber: 1,
        text: 'Paracetamol is generally considered safe during pregnancy when used as directed.',
        discussionTitle: 'Paracetamol Safety',
        commentCount: 3,
      ),
      ForumAnswerLine(
        lineId: '${answerId}_L2',
        answerId: answerId,
        lineNumber: 2,
        text: 'It is primarily metabolized in the liver via glucuronidation.',
        discussionTitle: 'Liver Metabolism',
        commentCount: 0,
      ),
      ForumAnswerLine(
        lineId: '${answerId}_L3',
        answerId: answerId,
        lineNumber: 3,
        text: 'High doses may increase the risk of hepatotoxicity, though standard dosing is safe.',
        discussionTitle: 'Hepatotoxicity Risk',
        commentCount: 5,
      ),
      ForumAnswerLine(
        lineId: '${answerId}_L4',
        answerId: answerId,
        lineNumber: 4,
        text: 'First trimester use is well-studied and carries minimal risk.',
        discussionTitle: 'Trimester Safety',
        commentCount: 12,
      ),
    ];
  }

  List<ForumLineComment> _generateMockComments(String lineId, String filter) {
    final allComments = [
      ForumLineComment(
        id: 'c1',
        lineId: lineId,
        authorId: 'u1',
        authorName: 'Dr. Amina Mensah',
        authorRole: CommentRole.clinician,
        authorProfession: 'Midwife',
        commentType: CommentType.clinical,
        text: 'This is accurate for first and second trimester. Third trimester dosing may differ slightly.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ForumLineComment(
        id: 'c2',
        lineId: lineId,
        authorId: 'u2',
        authorName: 'Ama',
        authorRole: CommentRole.mother,
        commentType: CommentType.experience,
        text: 'My OB told me to avoid it unless I have a fever.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      ForumLineComment(
        id: 'c3',
        lineId: lineId,
        authorId: 'u3',
        authorName: 'Kwame',
        authorRole: CommentRole.community,
        commentType: CommentType.concern,
        text: 'Are there any herbal alternatives?',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    if (filter == 'all') return allComments;
    return allComments.where((c) => c.authorRole.toString().contains(filter) || c.commentType.toString().contains(filter)).toList();
  }

  CommentType _parseCommentType(String type) {
    switch (type) {
      case 'clinical': return CommentType.clinical;
      case 'evidence': return CommentType.evidence;
      case 'experience': return CommentType.experience;
      case 'concern': return CommentType.concern;
      default: return CommentType.general;
    }
  }

  Future<bool> checkConnectivity() async {
    // TODO: Implement with connectivity_plus package
    /*
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
    */
    return true; // Temporary - assume always online
  }

  /// Seed demo data for testing
  Future<void> seedDemoData() async {
    // await _database.deleteAllPosts(); // Optional: clear old data
    
    await createLocalPost(
      localId: 'demo_1',
      title: 'Is Paracetamol safe during 3rd trimester?',
      content: 'I have heard mixed things about taking paracetamol late in pregnancy. My doctor said it is fine for high fever, but I am worried about asthma risks. Has anyone looked at the latest studies?',
      authorId: 'u_demo_1',
      authorName: 'Sarah K.',
      tags: ['Pregnancy', 'Medication', 'Safety'],
    );
    
    await createLocalPost(
      localId: 'demo_2',
      title: 'Alternative pain relief options',
      content: 'Apart from paracetamol, what are safe natural remedies for headaches? I am trying to avoid pharmaceuticals if possible during my first trimester.',
      authorId: 'u_demo_2',
      authorName: 'Ama',
      tags: ['Pregnancy', 'Natural', 'PainRelief'],
    );
    
    await createLocalPost(
      localId: 'demo_3',
      title: 'Paracetamol dosing for infants',
      content: 'Changing topics slightly - what is the correct dosage calculation for a 6-month-old? The bottle is confusing.',
      authorId: 'u_demo_3',
      authorName: 'Kwame',
      tags: ['Medication', 'Pediatrics', 'Dosage'],
    );
  }
}

/// Custom exception for forum repository errors
class ForumException implements Exception {
  ForumException(this.message);
  final String message;

  @override
  String toString() => 'ForumException: $message';
}