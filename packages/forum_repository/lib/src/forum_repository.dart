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

  Future<void> createLocalPost({
    required String localId,
    required String title,
    required String content,
    required String authorId,
    required String authorName,
    List<ForumPostSource> sources = const [],
    List<String> tags = const [],
    String? originalAnswerId,
  }) async {
    print('DEBUG: ForumRepository.createLocalPost - localId: $localId');
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
      originalAnswerId: Value(originalAnswerId),
    ));
    print('DEBUG: ForumRepository.createLocalPost - SUCCESS');
  }

  /// Create comment locally (instant feedback)
  Future<void> createLocalComment({
    required String localId,
    required String postId,
    required String content,
    required String authorId,
    required String authorName,
    String? authorRole,
    String? authorProfession,
  }) async {
    print('DEBUG: ForumRepository.createLocalComment - localId: $localId');
    await _database.insertComment(ForumCommentsCompanion.insert(
      localId: localId,
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      authorRole: Value(authorRole),
      authorProfession: Value(authorProfession),
      content: content,
      createdAt: DateTime.now(),
      syncStatus: const Value('pending'),
    ));
    print('DEBUG: ForumRepository.createLocalComment - SUCCESS');
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
    print('DEBUG: ForumRepository.addToSyncQueue - $entityType $action for $entityId');
    await _database.addToSyncQueue(
      entityType: entityType,
      entityId: entityId,
      action: action,
    );
    print('DEBUG: ForumRepository.addToSyncQueue - SUCCESS');
  }

  /// Delete a post from local database
  Future<void> deletePost(String localId) async {
    await _database.deletePost(localId);
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

  /// Fetch all posts from server (for community feed)
  Future<List<ForumPost>> fetchAllPostsFromServer() async {
    try {
      final response = await _apiClient.get('/api/v1/forum/posts');
      final List<dynamic> postsJson = response.data['posts'] as List<dynamic>;
      return postsJson.map((json) => ForumPost.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ForumException('Failed to fetch posts: ${e.toString()}');
    }
  }

  /// Search for posts
  Future<List<ForumPost>> searchPosts(String query) async {
    try {
      final response = await _apiClient.get('/api/v1/forum/search', queryParameters: {'q': query});
      final List<dynamic> postsJson = response.data['posts'] as List<dynamic>;
      return postsJson.map((json) => ForumPost.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ForumException('Failed to search posts: ${e.toString()}');
    }
  }

  /// Prepare post content (LLM Title + Formatting)
  Future<Map<String, String>> preparePost(String query, String content) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/forum/prepare',
        data: {'query': query, 'content': content},
      );
      return {
        'title': response.data['title'] as String,
        'content': response.data['content'] as String,
      };
    } catch (e) {
      // Fallback to simple title
      return {
        'title': 'Discussion on: ${query.length > 40 ? '${query.substring(0, 40)}...' : query}',
        'content': content,
      };
    }
  }

  /// Toggle like on post
  Future<void> togglePostLike(String postId, {bool? isLiked, int? likeCount}) async {
    try {
      // 1. Update local database immediately for resilience
      if (isLiked != null && likeCount != null) {
        await _database.updatePostLike(
          postId: postId,
          isLiked: isLiked,
          likeCount: likeCount,
        );
      }
      
      // 2. Hit API
      final response = await _apiClient.post('/api/v1/forum/posts/$postId/like');
      
      if (response.statusCode == 200) {
        final serverLiked = response.data['liked'] as bool;
        final serverCount = response.data['like_count'] as int;
        
        // 3. Sync with actual server state
        await _database.updatePostLike(
          postId: postId,
          isLiked: serverLiked,
          likeCount: serverCount,
        );
      }
    } catch (e) {
      throw ForumException('Failed to like post: ${e.toString()}');
    }
  }

  /// Toggle like on comment
  Future<void> toggleCommentLike(String commentId) async {
    try {
      await _apiClient.post('/api/v1/forum/comments/$commentId/like');
    } catch (e) {
      throw ForumException('Failed to like comment: ${e.toString()}');
    }
  }

  /// Flag/Report a post
  Future<void> flagPost(String postId) async {
    try {
      await _apiClient.post('/api/v1/forum/posts/$postId/flag');
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

  /// Get or create lines for a general forum post
  Future<List<ForumAnswerLine>> getLinesForPost(int postId) async {
    // 1. Try server first for counts
    try {
      print('DEBUG: Fetching lines for post $postId from server...');
      final response = await _apiClient.get('/api/v1/forum/posts/$postId/lines');
      final list = response.data['lines'] as List;
      
      print('DEBUG: Server returned ${list.length} lines');
      for (var lineJson in list) {
        print('DEBUG: Server line ${lineJson['line_id']}: commentCount = ${lineJson['comment_count']}');
      }
      
      final lines = list.map((e) => ForumAnswerLine.fromJson(e as Map<String, dynamic>)).toList();
      
      print('DEBUG: Parsed ${lines.length} ForumAnswerLine objects');
      for (var line in lines) {
        print('DEBUG: Parsed line ${line.lineId}: commentCount = ${line.commentCount}');
      }

      // 2. Update local cache
      await _database.batchInsertLines(lines.map((l) => ForumAnswerLinesCompanion.insert(
        lineId: l.lineId,
        postId: Value(postId),
        lineNumber: l.lineNumber,
        textContent: l.text,
        discussionTitle: Value(l.discussionTitle),
        commentCount: Value(l.commentCount),
      )).toList());
      
      print('DEBUG: Updated local cache with ${lines.length} lines');

      return lines;
    } catch (e) {
      print('DEBUG: getLinesForPost - server failed, falling back to local: $e');
      // 3. Fallback to local cache
      final localLines = await _database.getLinesForPost(postId);
      if (localLines.isNotEmpty) {
        return localLines.map((l) => ForumAnswerLine(
          lineId: l.lineId,
          answerId: l.answerId ?? '',
          lineNumber: l.lineNumber,
          text: l.textContent,
          discussionTitle: l.discussionTitle ?? '',
          commentCount: l.commentCount,
        )).toList();
      }
      rethrow;
    }
  }

  /// Publish (or get) lines for a specific answer
  /// Checks local cache first, then server
  Future<List<ForumAnswerLine>> getLinesForAnswer(String answerId) async {
    // 1. Try server first
    try {
      final response = await _apiClient.post(
        '/api/v1/forum/answers/publish',
        data: {'answer_id': answerId, 'share_to_forum': true},
      );
      final list = response.data['lines'] as List;
      final lines = list.map((e) => ForumAnswerLine.fromJson(e as Map<String, dynamic>)).toList();

      // 2. Update local cache
      await _database.batchInsertLines(lines.map((l) => ForumAnswerLinesCompanion.insert(
        lineId: l.lineId,
        answerId: Value(l.answerId),
        lineNumber: l.lineNumber,
        textContent: l.text,
        discussionTitle: Value(l.discussionTitle),
        commentCount: Value(l.commentCount),
      )).toList());

      return lines;
    } catch (e) {
      print('DEBUG: getLinesForAnswer - server failed, falling back to local: $e');
      // 3. Fallback to local cache
      final localLines = await _database.getLinesForAnswer(answerId);
      if (localLines.isNotEmpty) {
        return localLines.map((l) => ForumAnswerLine(
          lineId: l.lineId,
          answerId: l.answerId ?? '',
          lineNumber: l.lineNumber,
          text: l.textContent,
          discussionTitle: l.discussionTitle ?? '',
          commentCount: l.commentCount,
        )).toList();
      }
      rethrow;
    }
  }

  /// Get comments for a specific line
  /// Checks local cache first
  Future<List<ForumLineComment>> getCommentsForLine(
    String lineId, {
    String filter = 'all',
  }) async {
    // 1. Try server first
    try {
      final response = await _apiClient.get(
        '/api/v1/forum/lines/$lineId/comments',
        queryParameters: {
          'filter': filter,
        },
      );
      final list = response.data['comments'] as List;
      final comments = list.map((e) => ForumLineComment.fromJson(e as Map<String, dynamic>)).toList();

      // 2. Update local cache (batch insert)
      await _database.batchInsertLineComments(comments.map((c) => ForumLineCommentsCompanion.insert(
        localId: c.id,
        serverId: Value(c.id),
        lineId: c.lineId,
        authorId: c.authorId,
        authorName: c.authorName,
        authorRole: c.authorRole.name,
        commentType: c.commentType.name,
        content: c.text,
        createdAt: c.createdAt,
        syncStatus: const Value('synced'),
      )).toList());

      return comments;
    } catch (e) {
      print('DEBUG: getCommentsForLine - server failed, falling back to local: $e');
      // 3. Fallback to local cache
      final localComments = await _database.getCommentsForLine(lineId);
      if (localComments.isNotEmpty) {
        return localComments.map((c) => ForumLineComment(
          id: c.localId,
          lineId: c.lineId,
          authorId: c.authorId,
          authorName: c.authorName,
          authorRole: _parseAuthorRole(c.authorRole),
          commentType: _parseCommentType(c.commentType),
          text: c.content,
          createdAt: c.createdAt,
          syncStatus: _parseSyncStatus(c.syncStatus),
        )).toList();
      }
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
      final comment = ForumLineComment.fromJson(response.data as Map<String, dynamic>);
      
      // Save locally as well
      await _database.insertLineComment(ForumLineCommentsCompanion.insert(
        localId: comment.id,
        serverId: Value(comment.id),
        lineId: comment.lineId,
        authorId: comment.authorId,
        authorName: comment.authorName,
        authorRole: comment.authorRole.name,
        commentType: comment.commentType.name,
        content: comment.text,
        createdAt: comment.createdAt,
        syncStatus: const Value('synced'),
      ));
      
      // Update the comment count in the local database
      await _database.incrementLineCommentCount(comment.lineId);

      return comment;
    } catch (e) {
      // Fallback: Save as pending for sync
      final localId = 'pending_${DateTime.now().millisecondsSinceEpoch}';
      // I need user info here... assuming we have a way to get it or wait for login status
      // For now, rethrow as we don't have a background sync for line comments yet
      throw ForumException('Failed to post comment: ${e.toString()}');
    }
  }

  /// Post a general comment to a forum post
  Future<ForumComment> addPostComment({
    required String postId,
    required String content,
    String? clientId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/forum/posts/$postId/comments',
        data: {
          'content': content,
          if (clientId != null) 'client_id': clientId,
        },
      );
      
      final comment = ForumComment.fromJson(response.data as Map<String, dynamic>);
      
      // Save locally
      await _database.insertComment(ForumCommentsCompanion.insert(
        localId: comment.localId,
        serverId: Value(comment.id),
        postId: postId,
        authorId: comment.authorId,
        authorName: comment.authorName,
        content: comment.content,
        createdAt: comment.createdAt,
        syncStatus: const Value('synced'),
      ));
      
      return comment;
    } catch (e) {
      throw ForumException('Failed to post comment: ${e.toString()}');
    }
  }

  CommentRole _parseAuthorRole(String role) {
    final r = role.toLowerCase();
    if (r == 'clinician') return CommentRole.clinician;
    if (r == 'mother') return CommentRole.mother;
    if (r == 'support_partner' || r == 'supportpartner') return CommentRole.supportPartner;
    return CommentRole.community;
  }

  SyncStatus _parseSyncStatus(String status) {
    switch (status) {
      case 'synced': return SyncStatus.synced;
      case 'pending': return SyncStatus.pending;
      case 'syncing': return SyncStatus.syncing;
      default: return SyncStatus.error;
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
        authorName: 'Sarah K.',
        authorRole: CommentRole.mother,
        authorProfession: 'Patient',
        commentType: CommentType.experience,
        text: 'I used it during my 28th week and it really helped with the migraines.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      ForumLineComment(
        id: 'c3',
        lineId: lineId,
        authorId: 'u3',
        authorName: 'Health Council',
        authorRole: CommentRole.clinician,
        commentType: CommentType.evidence,
        text: 'Large systematic reviews support the safety profile described here.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ForumLineComment(
        id: 'c4',
        lineId: lineId,
        authorId: 'u4',
        authorName: 'Kwame',
        authorRole: CommentRole.community,
        commentType: CommentType.concern,
        text: 'What about the potential link to childhood asthma? Some studies suggest caution.',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
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

  /// Clear all cached forum data
  Future<void> clearCache() async {
    await _database.clearCache();
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