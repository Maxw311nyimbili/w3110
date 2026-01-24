// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum_database.dart';

// ignore_for_file: type=lint
class $ForumPostsTable extends ForumPosts
    with TableInfo<$ForumPostsTable, ForumPostData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ForumPostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorNameMeta = const VerificationMeta(
    'authorName',
  );
  @override
  late final GeneratedColumn<String> authorName = GeneratedColumn<String>(
    'author_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentCountMeta = const VerificationMeta(
    'commentCount',
  );
  @override
  late final GeneratedColumn<int> commentCount = GeneratedColumn<int>(
    'comment_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _likeCountMeta = const VerificationMeta(
    'likeCount',
  );
  @override
  late final GeneratedColumn<int> likeCount = GeneratedColumn<int>(
    'like_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _viewCountMeta = const VerificationMeta(
    'viewCount',
  );
  @override
  late final GeneratedColumn<int> viewCount = GeneratedColumn<int>(
    'view_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isLikedMeta = const VerificationMeta(
    'isLiked',
  );
  @override
  late final GeneratedColumn<bool> isLiked = GeneratedColumn<bool>(
    'is_liked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_liked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _sourcesMeta = const VerificationMeta(
    'sources',
  );
  @override
  late final GeneratedColumn<String> sources = GeneratedColumn<String>(
    'sources',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncAttemptMeta = const VerificationMeta(
    'lastSyncAttempt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAttempt =
      GeneratedColumn<DateTime>(
        'last_sync_attempt',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _syncRetryCountMeta = const VerificationMeta(
    'syncRetryCount',
  );
  @override
  late final GeneratedColumn<int> syncRetryCount = GeneratedColumn<int>(
    'sync_retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    authorId,
    authorName,
    title,
    content,
    createdAt,
    updatedAt,
    commentCount,
    likeCount,
    viewCount,
    isLiked,
    syncStatus,
    sources,
    tags,
    lastSyncAttempt,
    syncRetryCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'forum_posts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ForumPostData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('author_name')) {
      context.handle(
        _authorNameMeta,
        authorName.isAcceptableOrUnknown(data['author_name']!, _authorNameMeta),
      );
    } else if (isInserting) {
      context.missing(_authorNameMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('comment_count')) {
      context.handle(
        _commentCountMeta,
        commentCount.isAcceptableOrUnknown(
          data['comment_count']!,
          _commentCountMeta,
        ),
      );
    }
    if (data.containsKey('like_count')) {
      context.handle(
        _likeCountMeta,
        likeCount.isAcceptableOrUnknown(data['like_count']!, _likeCountMeta),
      );
    }
    if (data.containsKey('view_count')) {
      context.handle(
        _viewCountMeta,
        viewCount.isAcceptableOrUnknown(data['view_count']!, _viewCountMeta),
      );
    }
    if (data.containsKey('is_liked')) {
      context.handle(
        _isLikedMeta,
        isLiked.isAcceptableOrUnknown(data['is_liked']!, _isLikedMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sources')) {
      context.handle(
        _sourcesMeta,
        sources.isAcceptableOrUnknown(data['sources']!, _sourcesMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('last_sync_attempt')) {
      context.handle(
        _lastSyncAttemptMeta,
        lastSyncAttempt.isAcceptableOrUnknown(
          data['last_sync_attempt']!,
          _lastSyncAttemptMeta,
        ),
      );
    }
    if (data.containsKey('sync_retry_count')) {
      context.handle(
        _syncRetryCountMeta,
        syncRetryCount.isAcceptableOrUnknown(
          data['sync_retry_count']!,
          _syncRetryCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {serverId},
  ];
  @override
  ForumPostData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ForumPostData(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      )!,
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      authorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_name'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      commentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}comment_count'],
      )!,
      likeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}like_count'],
      )!,
      viewCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}view_count'],
      ),
      isLiked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_liked'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      sources: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sources'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      lastSyncAttempt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_attempt'],
      ),
      syncRetryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_retry_count'],
      )!,
    );
  }

  @override
  $ForumPostsTable createAlias(String alias) {
    return $ForumPostsTable(attachedDatabase, alias);
  }
}

class ForumPostData extends DataClass implements Insertable<ForumPostData> {
  final String localId;
  final String serverId;
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int commentCount;
  final int likeCount;
  final int? viewCount;
  final bool isLiked;
  final String syncStatus;
  final String? sources;
  final String? tags;
  final DateTime? lastSyncAttempt;
  final int syncRetryCount;
  const ForumPostData({
    required this.localId,
    required this.serverId,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.commentCount,
    required this.likeCount,
    this.viewCount,
    required this.isLiked,
    required this.syncStatus,
    this.sources,
    this.tags,
    this.lastSyncAttempt,
    required this.syncRetryCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    map['server_id'] = Variable<String>(serverId);
    map['author_id'] = Variable<String>(authorId);
    map['author_name'] = Variable<String>(authorName);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['comment_count'] = Variable<int>(commentCount);
    map['like_count'] = Variable<int>(likeCount);
    if (!nullToAbsent || viewCount != null) {
      map['view_count'] = Variable<int>(viewCount);
    }
    map['is_liked'] = Variable<bool>(isLiked);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || sources != null) {
      map['sources'] = Variable<String>(sources);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || lastSyncAttempt != null) {
      map['last_sync_attempt'] = Variable<DateTime>(lastSyncAttempt);
    }
    map['sync_retry_count'] = Variable<int>(syncRetryCount);
    return map;
  }

  ForumPostsCompanion toCompanion(bool nullToAbsent) {
    return ForumPostsCompanion(
      localId: Value(localId),
      serverId: Value(serverId),
      authorId: Value(authorId),
      authorName: Value(authorName),
      title: Value(title),
      content: Value(content),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      commentCount: Value(commentCount),
      likeCount: Value(likeCount),
      viewCount: viewCount == null && nullToAbsent
          ? const Value.absent()
          : Value(viewCount),
      isLiked: Value(isLiked),
      syncStatus: Value(syncStatus),
      sources: sources == null && nullToAbsent
          ? const Value.absent()
          : Value(sources),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      lastSyncAttempt: lastSyncAttempt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAttempt),
      syncRetryCount: Value(syncRetryCount),
    );
  }

  factory ForumPostData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ForumPostData(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<String>(json['serverId']),
      authorId: serializer.fromJson<String>(json['authorId']),
      authorName: serializer.fromJson<String>(json['authorName']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      commentCount: serializer.fromJson<int>(json['commentCount']),
      likeCount: serializer.fromJson<int>(json['likeCount']),
      viewCount: serializer.fromJson<int?>(json['viewCount']),
      isLiked: serializer.fromJson<bool>(json['isLiked']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      sources: serializer.fromJson<String?>(json['sources']),
      tags: serializer.fromJson<String?>(json['tags']),
      lastSyncAttempt: serializer.fromJson<DateTime?>(json['lastSyncAttempt']),
      syncRetryCount: serializer.fromJson<int>(json['syncRetryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<String>(serverId),
      'authorId': serializer.toJson<String>(authorId),
      'authorName': serializer.toJson<String>(authorName),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'commentCount': serializer.toJson<int>(commentCount),
      'likeCount': serializer.toJson<int>(likeCount),
      'viewCount': serializer.toJson<int?>(viewCount),
      'isLiked': serializer.toJson<bool>(isLiked),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'sources': serializer.toJson<String?>(sources),
      'tags': serializer.toJson<String?>(tags),
      'lastSyncAttempt': serializer.toJson<DateTime?>(lastSyncAttempt),
      'syncRetryCount': serializer.toJson<int>(syncRetryCount),
    };
  }

  ForumPostData copyWith({
    String? localId,
    String? serverId,
    String? authorId,
    String? authorName,
    String? title,
    String? content,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    int? commentCount,
    int? likeCount,
    Value<int?> viewCount = const Value.absent(),
    bool? isLiked,
    String? syncStatus,
    Value<String?> sources = const Value.absent(),
    Value<String?> tags = const Value.absent(),
    Value<DateTime?> lastSyncAttempt = const Value.absent(),
    int? syncRetryCount,
  }) => ForumPostData(
    localId: localId ?? this.localId,
    serverId: serverId ?? this.serverId,
    authorId: authorId ?? this.authorId,
    authorName: authorName ?? this.authorName,
    title: title ?? this.title,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    commentCount: commentCount ?? this.commentCount,
    likeCount: likeCount ?? this.likeCount,
    viewCount: viewCount.present ? viewCount.value : this.viewCount,
    isLiked: isLiked ?? this.isLiked,
    syncStatus: syncStatus ?? this.syncStatus,
    sources: sources.present ? sources.value : this.sources,
    tags: tags.present ? tags.value : this.tags,
    lastSyncAttempt: lastSyncAttempt.present
        ? lastSyncAttempt.value
        : this.lastSyncAttempt,
    syncRetryCount: syncRetryCount ?? this.syncRetryCount,
  );
  ForumPostData copyWithCompanion(ForumPostsCompanion data) {
    return ForumPostData(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      authorName: data.authorName.present
          ? data.authorName.value
          : this.authorName,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      commentCount: data.commentCount.present
          ? data.commentCount.value
          : this.commentCount,
      likeCount: data.likeCount.present ? data.likeCount.value : this.likeCount,
      viewCount: data.viewCount.present ? data.viewCount.value : this.viewCount,
      isLiked: data.isLiked.present ? data.isLiked.value : this.isLiked,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      sources: data.sources.present ? data.sources.value : this.sources,
      tags: data.tags.present ? data.tags.value : this.tags,
      lastSyncAttempt: data.lastSyncAttempt.present
          ? data.lastSyncAttempt.value
          : this.lastSyncAttempt,
      syncRetryCount: data.syncRetryCount.present
          ? data.syncRetryCount.value
          : this.syncRetryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ForumPostData(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('authorId: $authorId, ')
          ..write('authorName: $authorName, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('commentCount: $commentCount, ')
          ..write('likeCount: $likeCount, ')
          ..write('viewCount: $viewCount, ')
          ..write('isLiked: $isLiked, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('sources: $sources, ')
          ..write('tags: $tags, ')
          ..write('lastSyncAttempt: $lastSyncAttempt, ')
          ..write('syncRetryCount: $syncRetryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    authorId,
    authorName,
    title,
    content,
    createdAt,
    updatedAt,
    commentCount,
    likeCount,
    viewCount,
    isLiked,
    syncStatus,
    sources,
    tags,
    lastSyncAttempt,
    syncRetryCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ForumPostData &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.authorId == this.authorId &&
          other.authorName == this.authorName &&
          other.title == this.title &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.commentCount == this.commentCount &&
          other.likeCount == this.likeCount &&
          other.viewCount == this.viewCount &&
          other.isLiked == this.isLiked &&
          other.syncStatus == this.syncStatus &&
          other.sources == this.sources &&
          other.tags == this.tags &&
          other.lastSyncAttempt == this.lastSyncAttempt &&
          other.syncRetryCount == this.syncRetryCount);
}

class ForumPostsCompanion extends UpdateCompanion<ForumPostData> {
  final Value<String> localId;
  final Value<String> serverId;
  final Value<String> authorId;
  final Value<String> authorName;
  final Value<String> title;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> commentCount;
  final Value<int> likeCount;
  final Value<int?> viewCount;
  final Value<bool> isLiked;
  final Value<String> syncStatus;
  final Value<String?> sources;
  final Value<String?> tags;
  final Value<DateTime?> lastSyncAttempt;
  final Value<int> syncRetryCount;
  final Value<int> rowid;
  const ForumPostsCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.authorId = const Value.absent(),
    this.authorName = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.commentCount = const Value.absent(),
    this.likeCount = const Value.absent(),
    this.viewCount = const Value.absent(),
    this.isLiked = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.sources = const Value.absent(),
    this.tags = const Value.absent(),
    this.lastSyncAttempt = const Value.absent(),
    this.syncRetryCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ForumPostsCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required String authorId,
    required String authorName,
    required String title,
    required String content,
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.commentCount = const Value.absent(),
    this.likeCount = const Value.absent(),
    this.viewCount = const Value.absent(),
    this.isLiked = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.sources = const Value.absent(),
    this.tags = const Value.absent(),
    this.lastSyncAttempt = const Value.absent(),
    this.syncRetryCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       authorId = Value(authorId),
       authorName = Value(authorName),
       title = Value(title),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<ForumPostData> custom({
    Expression<String>? localId,
    Expression<String>? serverId,
    Expression<String>? authorId,
    Expression<String>? authorName,
    Expression<String>? title,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? commentCount,
    Expression<int>? likeCount,
    Expression<int>? viewCount,
    Expression<bool>? isLiked,
    Expression<String>? syncStatus,
    Expression<String>? sources,
    Expression<String>? tags,
    Expression<DateTime>? lastSyncAttempt,
    Expression<int>? syncRetryCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (authorId != null) 'author_id': authorId,
      if (authorName != null) 'author_name': authorName,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (commentCount != null) 'comment_count': commentCount,
      if (likeCount != null) 'like_count': likeCount,
      if (viewCount != null) 'view_count': viewCount,
      if (isLiked != null) 'is_liked': isLiked,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (sources != null) 'sources': sources,
      if (tags != null) 'tags': tags,
      if (lastSyncAttempt != null) 'last_sync_attempt': lastSyncAttempt,
      if (syncRetryCount != null) 'sync_retry_count': syncRetryCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ForumPostsCompanion copyWith({
    Value<String>? localId,
    Value<String>? serverId,
    Value<String>? authorId,
    Value<String>? authorName,
    Value<String>? title,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? commentCount,
    Value<int>? likeCount,
    Value<int?>? viewCount,
    Value<bool>? isLiked,
    Value<String>? syncStatus,
    Value<String?>? sources,
    Value<String?>? tags,
    Value<DateTime?>? lastSyncAttempt,
    Value<int>? syncRetryCount,
    Value<int>? rowid,
  }) {
    return ForumPostsCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      viewCount: viewCount ?? this.viewCount,
      isLiked: isLiked ?? this.isLiked,
      syncStatus: syncStatus ?? this.syncStatus,
      sources: sources ?? this.sources,
      tags: tags ?? this.tags,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      syncRetryCount: syncRetryCount ?? this.syncRetryCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (authorName.present) {
      map['author_name'] = Variable<String>(authorName.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (commentCount.present) {
      map['comment_count'] = Variable<int>(commentCount.value);
    }
    if (likeCount.present) {
      map['like_count'] = Variable<int>(likeCount.value);
    }
    if (viewCount.present) {
      map['view_count'] = Variable<int>(viewCount.value);
    }
    if (isLiked.present) {
      map['is_liked'] = Variable<bool>(isLiked.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (sources.present) {
      map['sources'] = Variable<String>(sources.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (lastSyncAttempt.present) {
      map['last_sync_attempt'] = Variable<DateTime>(lastSyncAttempt.value);
    }
    if (syncRetryCount.present) {
      map['sync_retry_count'] = Variable<int>(syncRetryCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ForumPostsCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('authorId: $authorId, ')
          ..write('authorName: $authorName, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('commentCount: $commentCount, ')
          ..write('likeCount: $likeCount, ')
          ..write('viewCount: $viewCount, ')
          ..write('isLiked: $isLiked, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('sources: $sources, ')
          ..write('tags: $tags, ')
          ..write('lastSyncAttempt: $lastSyncAttempt, ')
          ..write('syncRetryCount: $syncRetryCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ForumCommentsTable extends ForumComments
    with TableInfo<$ForumCommentsTable, ForumCommentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ForumCommentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _postIdMeta = const VerificationMeta('postId');
  @override
  late final GeneratedColumn<String> postId = GeneratedColumn<String>(
    'post_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorNameMeta = const VerificationMeta(
    'authorName',
  );
  @override
  late final GeneratedColumn<String> authorName = GeneratedColumn<String>(
    'author_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _likeCountMeta = const VerificationMeta(
    'likeCount',
  );
  @override
  late final GeneratedColumn<int> likeCount = GeneratedColumn<int>(
    'like_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isLikedMeta = const VerificationMeta(
    'isLiked',
  );
  @override
  late final GeneratedColumn<bool> isLiked = GeneratedColumn<bool>(
    'is_liked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_liked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _lastSyncAttemptMeta = const VerificationMeta(
    'lastSyncAttempt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAttempt =
      GeneratedColumn<DateTime>(
        'last_sync_attempt',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _syncRetryCountMeta = const VerificationMeta(
    'syncRetryCount',
  );
  @override
  late final GeneratedColumn<int> syncRetryCount = GeneratedColumn<int>(
    'sync_retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    postId,
    authorId,
    authorName,
    content,
    likeCount,
    isLiked,
    createdAt,
    updatedAt,
    syncStatus,
    lastSyncAttempt,
    syncRetryCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'forum_comments';
  @override
  VerificationContext validateIntegrity(
    Insertable<ForumCommentData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('post_id')) {
      context.handle(
        _postIdMeta,
        postId.isAcceptableOrUnknown(data['post_id']!, _postIdMeta),
      );
    } else if (isInserting) {
      context.missing(_postIdMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('author_name')) {
      context.handle(
        _authorNameMeta,
        authorName.isAcceptableOrUnknown(data['author_name']!, _authorNameMeta),
      );
    } else if (isInserting) {
      context.missing(_authorNameMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('like_count')) {
      context.handle(
        _likeCountMeta,
        likeCount.isAcceptableOrUnknown(data['like_count']!, _likeCountMeta),
      );
    }
    if (data.containsKey('is_liked')) {
      context.handle(
        _isLikedMeta,
        isLiked.isAcceptableOrUnknown(data['is_liked']!, _isLikedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_sync_attempt')) {
      context.handle(
        _lastSyncAttemptMeta,
        lastSyncAttempt.isAcceptableOrUnknown(
          data['last_sync_attempt']!,
          _lastSyncAttemptMeta,
        ),
      );
    }
    if (data.containsKey('sync_retry_count')) {
      context.handle(
        _syncRetryCountMeta,
        syncRetryCount.isAcceptableOrUnknown(
          data['sync_retry_count']!,
          _syncRetryCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {serverId},
  ];
  @override
  ForumCommentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ForumCommentData(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      )!,
      postId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_id'],
      )!,
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      authorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_name'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      likeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}like_count'],
      )!,
      isLiked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_liked'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncAttempt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_attempt'],
      ),
      syncRetryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_retry_count'],
      )!,
    );
  }

  @override
  $ForumCommentsTable createAlias(String alias) {
    return $ForumCommentsTable(attachedDatabase, alias);
  }
}

class ForumCommentData extends DataClass
    implements Insertable<ForumCommentData> {
  final String localId;
  final String serverId;
  final String postId;
  final String authorId;
  final String authorName;
  final String content;
  final int likeCount;
  final bool isLiked;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String syncStatus;
  final DateTime? lastSyncAttempt;
  final int syncRetryCount;
  const ForumCommentData({
    required this.localId,
    required this.serverId,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.likeCount,
    required this.isLiked,
    required this.createdAt,
    this.updatedAt,
    required this.syncStatus,
    this.lastSyncAttempt,
    required this.syncRetryCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    map['server_id'] = Variable<String>(serverId);
    map['post_id'] = Variable<String>(postId);
    map['author_id'] = Variable<String>(authorId);
    map['author_name'] = Variable<String>(authorName);
    map['content'] = Variable<String>(content);
    map['like_count'] = Variable<int>(likeCount);
    map['is_liked'] = Variable<bool>(isLiked);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncAttempt != null) {
      map['last_sync_attempt'] = Variable<DateTime>(lastSyncAttempt);
    }
    map['sync_retry_count'] = Variable<int>(syncRetryCount);
    return map;
  }

  ForumCommentsCompanion toCompanion(bool nullToAbsent) {
    return ForumCommentsCompanion(
      localId: Value(localId),
      serverId: Value(serverId),
      postId: Value(postId),
      authorId: Value(authorId),
      authorName: Value(authorName),
      content: Value(content),
      likeCount: Value(likeCount),
      isLiked: Value(isLiked),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      syncStatus: Value(syncStatus),
      lastSyncAttempt: lastSyncAttempt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAttempt),
      syncRetryCount: Value(syncRetryCount),
    );
  }

  factory ForumCommentData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ForumCommentData(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<String>(json['serverId']),
      postId: serializer.fromJson<String>(json['postId']),
      authorId: serializer.fromJson<String>(json['authorId']),
      authorName: serializer.fromJson<String>(json['authorName']),
      content: serializer.fromJson<String>(json['content']),
      likeCount: serializer.fromJson<int>(json['likeCount']),
      isLiked: serializer.fromJson<bool>(json['isLiked']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncAttempt: serializer.fromJson<DateTime?>(json['lastSyncAttempt']),
      syncRetryCount: serializer.fromJson<int>(json['syncRetryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<String>(serverId),
      'postId': serializer.toJson<String>(postId),
      'authorId': serializer.toJson<String>(authorId),
      'authorName': serializer.toJson<String>(authorName),
      'content': serializer.toJson<String>(content),
      'likeCount': serializer.toJson<int>(likeCount),
      'isLiked': serializer.toJson<bool>(isLiked),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncAttempt': serializer.toJson<DateTime?>(lastSyncAttempt),
      'syncRetryCount': serializer.toJson<int>(syncRetryCount),
    };
  }

  ForumCommentData copyWith({
    String? localId,
    String? serverId,
    String? postId,
    String? authorId,
    String? authorName,
    String? content,
    int? likeCount,
    bool? isLiked,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    String? syncStatus,
    Value<DateTime?> lastSyncAttempt = const Value.absent(),
    int? syncRetryCount,
  }) => ForumCommentData(
    localId: localId ?? this.localId,
    serverId: serverId ?? this.serverId,
    postId: postId ?? this.postId,
    authorId: authorId ?? this.authorId,
    authorName: authorName ?? this.authorName,
    content: content ?? this.content,
    likeCount: likeCount ?? this.likeCount,
    isLiked: isLiked ?? this.isLiked,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncAttempt: lastSyncAttempt.present
        ? lastSyncAttempt.value
        : this.lastSyncAttempt,
    syncRetryCount: syncRetryCount ?? this.syncRetryCount,
  );
  ForumCommentData copyWithCompanion(ForumCommentsCompanion data) {
    return ForumCommentData(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      postId: data.postId.present ? data.postId.value : this.postId,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      authorName: data.authorName.present
          ? data.authorName.value
          : this.authorName,
      content: data.content.present ? data.content.value : this.content,
      likeCount: data.likeCount.present ? data.likeCount.value : this.likeCount,
      isLiked: data.isLiked.present ? data.isLiked.value : this.isLiked,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncAttempt: data.lastSyncAttempt.present
          ? data.lastSyncAttempt.value
          : this.lastSyncAttempt,
      syncRetryCount: data.syncRetryCount.present
          ? data.syncRetryCount.value
          : this.syncRetryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ForumCommentData(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('postId: $postId, ')
          ..write('authorId: $authorId, ')
          ..write('authorName: $authorName, ')
          ..write('content: $content, ')
          ..write('likeCount: $likeCount, ')
          ..write('isLiked: $isLiked, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncAttempt: $lastSyncAttempt, ')
          ..write('syncRetryCount: $syncRetryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    postId,
    authorId,
    authorName,
    content,
    likeCount,
    isLiked,
    createdAt,
    updatedAt,
    syncStatus,
    lastSyncAttempt,
    syncRetryCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ForumCommentData &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.postId == this.postId &&
          other.authorId == this.authorId &&
          other.authorName == this.authorName &&
          other.content == this.content &&
          other.likeCount == this.likeCount &&
          other.isLiked == this.isLiked &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncAttempt == this.lastSyncAttempt &&
          other.syncRetryCount == this.syncRetryCount);
}

class ForumCommentsCompanion extends UpdateCompanion<ForumCommentData> {
  final Value<String> localId;
  final Value<String> serverId;
  final Value<String> postId;
  final Value<String> authorId;
  final Value<String> authorName;
  final Value<String> content;
  final Value<int> likeCount;
  final Value<bool> isLiked;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncAttempt;
  final Value<int> syncRetryCount;
  final Value<int> rowid;
  const ForumCommentsCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.postId = const Value.absent(),
    this.authorId = const Value.absent(),
    this.authorName = const Value.absent(),
    this.content = const Value.absent(),
    this.likeCount = const Value.absent(),
    this.isLiked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncAttempt = const Value.absent(),
    this.syncRetryCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ForumCommentsCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required String postId,
    required String authorId,
    required String authorName,
    required String content,
    this.likeCount = const Value.absent(),
    this.isLiked = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncAttempt = const Value.absent(),
    this.syncRetryCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       postId = Value(postId),
       authorId = Value(authorId),
       authorName = Value(authorName),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<ForumCommentData> custom({
    Expression<String>? localId,
    Expression<String>? serverId,
    Expression<String>? postId,
    Expression<String>? authorId,
    Expression<String>? authorName,
    Expression<String>? content,
    Expression<int>? likeCount,
    Expression<bool>? isLiked,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncAttempt,
    Expression<int>? syncRetryCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (postId != null) 'post_id': postId,
      if (authorId != null) 'author_id': authorId,
      if (authorName != null) 'author_name': authorName,
      if (content != null) 'content': content,
      if (likeCount != null) 'like_count': likeCount,
      if (isLiked != null) 'is_liked': isLiked,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncAttempt != null) 'last_sync_attempt': lastSyncAttempt,
      if (syncRetryCount != null) 'sync_retry_count': syncRetryCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ForumCommentsCompanion copyWith({
    Value<String>? localId,
    Value<String>? serverId,
    Value<String>? postId,
    Value<String>? authorId,
    Value<String>? authorName,
    Value<String>? content,
    Value<int>? likeCount,
    Value<bool>? isLiked,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? syncStatus,
    Value<DateTime?>? lastSyncAttempt,
    Value<int>? syncRetryCount,
    Value<int>? rowid,
  }) {
    return ForumCommentsCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      syncRetryCount: syncRetryCount ?? this.syncRetryCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (postId.present) {
      map['post_id'] = Variable<String>(postId.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (authorName.present) {
      map['author_name'] = Variable<String>(authorName.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (likeCount.present) {
      map['like_count'] = Variable<int>(likeCount.value);
    }
    if (isLiked.present) {
      map['is_liked'] = Variable<bool>(isLiked.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncAttempt.present) {
      map['last_sync_attempt'] = Variable<DateTime>(lastSyncAttempt.value);
    }
    if (syncRetryCount.present) {
      map['sync_retry_count'] = Variable<int>(syncRetryCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ForumCommentsCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('postId: $postId, ')
          ..write('authorId: $authorId, ')
          ..write('authorName: $authorName, ')
          ..write('content: $content, ')
          ..write('likeCount: $likeCount, ')
          ..write('isLiked: $isLiked, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncAttempt: $lastSyncAttempt, ')
          ..write('syncRetryCount: $syncRetryCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAttemptMeta = const VerificationMeta(
    'lastAttempt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttempt = GeneratedColumn<DateTime>(
    'last_attempt',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    action,
    createdAt,
    lastAttempt,
    retryCount,
    status,
    nextRetryAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_attempt')) {
      context.handle(
        _lastAttemptMeta,
        lastAttempt.isAcceptableOrUnknown(
          data['last_attempt']!,
          _lastAttemptMeta,
        ),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastAttempt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt'],
      ),
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String entityType;
  final String entityId;
  final String action;
  final DateTime createdAt;
  final DateTime? lastAttempt;
  final int retryCount;
  final String status;
  final DateTime? nextRetryAt;
  final String? lastError;
  const SyncQueueData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.createdAt,
    this.lastAttempt,
    required this.retryCount,
    required this.status,
    this.nextRetryAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastAttempt != null) {
      map['last_attempt'] = Variable<DateTime>(lastAttempt);
    }
    map['retry_count'] = Variable<int>(retryCount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      createdAt: Value(createdAt),
      lastAttempt: lastAttempt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttempt),
      retryCount: Value(retryCount),
      status: Value(status),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastAttempt: serializer.fromJson<DateTime?>(json['lastAttempt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      status: serializer.fromJson<String>(json['status']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastAttempt': serializer.toJson<DateTime?>(lastAttempt),
      'retryCount': serializer.toJson<int>(retryCount),
      'status': serializer.toJson<String>(status),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? entityType,
    String? entityId,
    String? action,
    DateTime? createdAt,
    Value<DateTime?> lastAttempt = const Value.absent(),
    int? retryCount,
    String? status,
    Value<DateTime?> nextRetryAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => SyncQueueData(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    action: action ?? this.action,
    createdAt: createdAt ?? this.createdAt,
    lastAttempt: lastAttempt.present ? lastAttempt.value : this.lastAttempt,
    retryCount: retryCount ?? this.retryCount,
    status: status ?? this.status,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAttempt: data.lastAttempt.present
          ? data.lastAttempt.value
          : this.lastAttempt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      status: data.status.present ? data.status.value : this.status,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttempt: $lastAttempt, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    action,
    createdAt,
    lastAttempt,
    retryCount,
    status,
    nextRetryAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.createdAt == this.createdAt &&
          other.lastAttempt == this.lastAttempt &&
          other.retryCount == this.retryCount &&
          other.status == this.status &&
          other.nextRetryAt == this.nextRetryAt &&
          other.lastError == this.lastError);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastAttempt;
  final Value<int> retryCount;
  final Value<String> status;
  final Value<DateTime?> nextRetryAt;
  final Value<String?> lastError;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttempt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required String action,
    required DateTime createdAt,
    this.lastAttempt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       action = Value(action),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastAttempt,
    Expression<int>? retryCount,
    Expression<String>? status,
    Expression<DateTime>? nextRetryAt,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAttempt != null) 'last_attempt': lastAttempt,
      if (retryCount != null) 'retry_count': retryCount,
      if (status != null) 'status': status,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (lastError != null) 'last_error': lastError,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? action,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastAttempt,
    Value<int>? retryCount,
    Value<String>? status,
    Value<DateTime?>? nextRetryAt,
    Value<String?>? lastError,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      createdAt: createdAt ?? this.createdAt,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastAttempt.present) {
      map['last_attempt'] = Variable<DateTime>(lastAttempt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttempt: $lastAttempt, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

abstract class _$ForumDatabase extends GeneratedDatabase {
  _$ForumDatabase(QueryExecutor e) : super(e);
  $ForumDatabaseManager get managers => $ForumDatabaseManager(this);
  late final $ForumPostsTable forumPosts = $ForumPostsTable(this);
  late final $ForumCommentsTable forumComments = $ForumCommentsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    forumPosts,
    forumComments,
    syncQueue,
  ];
}

typedef $$ForumPostsTableCreateCompanionBuilder =
    ForumPostsCompanion Function({
      required String localId,
      Value<String> serverId,
      required String authorId,
      required String authorName,
      required String title,
      required String content,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<int> commentCount,
      Value<int> likeCount,
      Value<int?> viewCount,
      Value<bool> isLiked,
      Value<String> syncStatus,
      Value<String?> sources,
      Value<String?> tags,
      Value<DateTime?> lastSyncAttempt,
      Value<int> syncRetryCount,
      Value<int> rowid,
    });
typedef $$ForumPostsTableUpdateCompanionBuilder =
    ForumPostsCompanion Function({
      Value<String> localId,
      Value<String> serverId,
      Value<String> authorId,
      Value<String> authorName,
      Value<String> title,
      Value<String> content,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> commentCount,
      Value<int> likeCount,
      Value<int?> viewCount,
      Value<bool> isLiked,
      Value<String> syncStatus,
      Value<String?> sources,
      Value<String?> tags,
      Value<DateTime?> lastSyncAttempt,
      Value<int> syncRetryCount,
      Value<int> rowid,
    });

class $$ForumPostsTableFilterComposer
    extends Composer<_$ForumDatabase, $ForumPostsTable> {
  $$ForumPostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get commentCount => $composableBuilder(
    column: $table.commentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get viewCount => $composableBuilder(
    column: $table.viewCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLiked => $composableBuilder(
    column: $table.isLiked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sources => $composableBuilder(
    column: $table.sources,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAttempt => $composableBuilder(
    column: $table.lastSyncAttempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncRetryCount => $composableBuilder(
    column: $table.syncRetryCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ForumPostsTableOrderingComposer
    extends Composer<_$ForumDatabase, $ForumPostsTable> {
  $$ForumPostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get commentCount => $composableBuilder(
    column: $table.commentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get viewCount => $composableBuilder(
    column: $table.viewCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLiked => $composableBuilder(
    column: $table.isLiked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sources => $composableBuilder(
    column: $table.sources,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAttempt => $composableBuilder(
    column: $table.lastSyncAttempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncRetryCount => $composableBuilder(
    column: $table.syncRetryCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ForumPostsTableAnnotationComposer
    extends Composer<_$ForumDatabase, $ForumPostsTable> {
  $$ForumPostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get commentCount => $composableBuilder(
    column: $table.commentCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get likeCount =>
      $composableBuilder(column: $table.likeCount, builder: (column) => column);

  GeneratedColumn<int> get viewCount =>
      $composableBuilder(column: $table.viewCount, builder: (column) => column);

  GeneratedColumn<bool> get isLiked =>
      $composableBuilder(column: $table.isLiked, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sources =>
      $composableBuilder(column: $table.sources, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAttempt => $composableBuilder(
    column: $table.lastSyncAttempt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncRetryCount => $composableBuilder(
    column: $table.syncRetryCount,
    builder: (column) => column,
  );
}

class $$ForumPostsTableTableManager
    extends
        RootTableManager<
          _$ForumDatabase,
          $ForumPostsTable,
          ForumPostData,
          $$ForumPostsTableFilterComposer,
          $$ForumPostsTableOrderingComposer,
          $$ForumPostsTableAnnotationComposer,
          $$ForumPostsTableCreateCompanionBuilder,
          $$ForumPostsTableUpdateCompanionBuilder,
          (
            ForumPostData,
            BaseReferences<_$ForumDatabase, $ForumPostsTable, ForumPostData>,
          ),
          ForumPostData,
          PrefetchHooks Function()
        > {
  $$ForumPostsTableTableManager(_$ForumDatabase db, $ForumPostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ForumPostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ForumPostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ForumPostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String> serverId = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<String> authorName = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> commentCount = const Value.absent(),
                Value<int> likeCount = const Value.absent(),
                Value<int?> viewCount = const Value.absent(),
                Value<bool> isLiked = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> sources = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<DateTime?> lastSyncAttempt = const Value.absent(),
                Value<int> syncRetryCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ForumPostsCompanion(
                localId: localId,
                serverId: serverId,
                authorId: authorId,
                authorName: authorName,
                title: title,
                content: content,
                createdAt: createdAt,
                updatedAt: updatedAt,
                commentCount: commentCount,
                likeCount: likeCount,
                viewCount: viewCount,
                isLiked: isLiked,
                syncStatus: syncStatus,
                sources: sources,
                tags: tags,
                lastSyncAttempt: lastSyncAttempt,
                syncRetryCount: syncRetryCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<String> serverId = const Value.absent(),
                required String authorId,
                required String authorName,
                required String title,
                required String content,
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> commentCount = const Value.absent(),
                Value<int> likeCount = const Value.absent(),
                Value<int?> viewCount = const Value.absent(),
                Value<bool> isLiked = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> sources = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<DateTime?> lastSyncAttempt = const Value.absent(),
                Value<int> syncRetryCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ForumPostsCompanion.insert(
                localId: localId,
                serverId: serverId,
                authorId: authorId,
                authorName: authorName,
                title: title,
                content: content,
                createdAt: createdAt,
                updatedAt: updatedAt,
                commentCount: commentCount,
                likeCount: likeCount,
                viewCount: viewCount,
                isLiked: isLiked,
                syncStatus: syncStatus,
                sources: sources,
                tags: tags,
                lastSyncAttempt: lastSyncAttempt,
                syncRetryCount: syncRetryCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ForumPostsTableProcessedTableManager =
    ProcessedTableManager<
      _$ForumDatabase,
      $ForumPostsTable,
      ForumPostData,
      $$ForumPostsTableFilterComposer,
      $$ForumPostsTableOrderingComposer,
      $$ForumPostsTableAnnotationComposer,
      $$ForumPostsTableCreateCompanionBuilder,
      $$ForumPostsTableUpdateCompanionBuilder,
      (
        ForumPostData,
        BaseReferences<_$ForumDatabase, $ForumPostsTable, ForumPostData>,
      ),
      ForumPostData,
      PrefetchHooks Function()
    >;
typedef $$ForumCommentsTableCreateCompanionBuilder =
    ForumCommentsCompanion Function({
      required String localId,
      Value<String> serverId,
      required String postId,
      required String authorId,
      required String authorName,
      required String content,
      Value<int> likeCount,
      Value<bool> isLiked,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<String> syncStatus,
      Value<DateTime?> lastSyncAttempt,
      Value<int> syncRetryCount,
      Value<int> rowid,
    });
typedef $$ForumCommentsTableUpdateCompanionBuilder =
    ForumCommentsCompanion Function({
      Value<String> localId,
      Value<String> serverId,
      Value<String> postId,
      Value<String> authorId,
      Value<String> authorName,
      Value<String> content,
      Value<int> likeCount,
      Value<bool> isLiked,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> syncStatus,
      Value<DateTime?> lastSyncAttempt,
      Value<int> syncRetryCount,
      Value<int> rowid,
    });

class $$ForumCommentsTableFilterComposer
    extends Composer<_$ForumDatabase, $ForumCommentsTable> {
  $$ForumCommentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postId => $composableBuilder(
    column: $table.postId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLiked => $composableBuilder(
    column: $table.isLiked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAttempt => $composableBuilder(
    column: $table.lastSyncAttempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncRetryCount => $composableBuilder(
    column: $table.syncRetryCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ForumCommentsTableOrderingComposer
    extends Composer<_$ForumDatabase, $ForumCommentsTable> {
  $$ForumCommentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postId => $composableBuilder(
    column: $table.postId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLiked => $composableBuilder(
    column: $table.isLiked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAttempt => $composableBuilder(
    column: $table.lastSyncAttempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncRetryCount => $composableBuilder(
    column: $table.syncRetryCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ForumCommentsTableAnnotationComposer
    extends Composer<_$ForumDatabase, $ForumCommentsTable> {
  $$ForumCommentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get postId =>
      $composableBuilder(column: $table.postId, builder: (column) => column);

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get likeCount =>
      $composableBuilder(column: $table.likeCount, builder: (column) => column);

  GeneratedColumn<bool> get isLiked =>
      $composableBuilder(column: $table.isLiked, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncAttempt => $composableBuilder(
    column: $table.lastSyncAttempt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncRetryCount => $composableBuilder(
    column: $table.syncRetryCount,
    builder: (column) => column,
  );
}

class $$ForumCommentsTableTableManager
    extends
        RootTableManager<
          _$ForumDatabase,
          $ForumCommentsTable,
          ForumCommentData,
          $$ForumCommentsTableFilterComposer,
          $$ForumCommentsTableOrderingComposer,
          $$ForumCommentsTableAnnotationComposer,
          $$ForumCommentsTableCreateCompanionBuilder,
          $$ForumCommentsTableUpdateCompanionBuilder,
          (
            ForumCommentData,
            BaseReferences<
              _$ForumDatabase,
              $ForumCommentsTable,
              ForumCommentData
            >,
          ),
          ForumCommentData,
          PrefetchHooks Function()
        > {
  $$ForumCommentsTableTableManager(
    _$ForumDatabase db,
    $ForumCommentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ForumCommentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ForumCommentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ForumCommentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String> serverId = const Value.absent(),
                Value<String> postId = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<String> authorName = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> likeCount = const Value.absent(),
                Value<bool> isLiked = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncAttempt = const Value.absent(),
                Value<int> syncRetryCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ForumCommentsCompanion(
                localId: localId,
                serverId: serverId,
                postId: postId,
                authorId: authorId,
                authorName: authorName,
                content: content,
                likeCount: likeCount,
                isLiked: isLiked,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                lastSyncAttempt: lastSyncAttempt,
                syncRetryCount: syncRetryCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<String> serverId = const Value.absent(),
                required String postId,
                required String authorId,
                required String authorName,
                required String content,
                Value<int> likeCount = const Value.absent(),
                Value<bool> isLiked = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncAttempt = const Value.absent(),
                Value<int> syncRetryCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ForumCommentsCompanion.insert(
                localId: localId,
                serverId: serverId,
                postId: postId,
                authorId: authorId,
                authorName: authorName,
                content: content,
                likeCount: likeCount,
                isLiked: isLiked,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                lastSyncAttempt: lastSyncAttempt,
                syncRetryCount: syncRetryCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ForumCommentsTableProcessedTableManager =
    ProcessedTableManager<
      _$ForumDatabase,
      $ForumCommentsTable,
      ForumCommentData,
      $$ForumCommentsTableFilterComposer,
      $$ForumCommentsTableOrderingComposer,
      $$ForumCommentsTableAnnotationComposer,
      $$ForumCommentsTableCreateCompanionBuilder,
      $$ForumCommentsTableUpdateCompanionBuilder,
      (
        ForumCommentData,
        BaseReferences<_$ForumDatabase, $ForumCommentsTable, ForumCommentData>,
      ),
      ForumCommentData,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String entityType,
      required String entityId,
      required String action,
      required DateTime createdAt,
      Value<DateTime?> lastAttempt,
      Value<int> retryCount,
      Value<String> status,
      Value<DateTime?> nextRetryAt,
      Value<String?> lastError,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> action,
      Value<DateTime> createdAt,
      Value<DateTime?> lastAttempt,
      Value<int> retryCount,
      Value<String> status,
      Value<DateTime?> nextRetryAt,
      Value<String?> lastError,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$ForumDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttempt => $composableBuilder(
    column: $table.lastAttempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$ForumDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttempt => $composableBuilder(
    column: $table.lastAttempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$ForumDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttempt => $composableBuilder(
    column: $table.lastAttempt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$ForumDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$ForumDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$ForumDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastAttempt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                action: action,
                createdAt: createdAt,
                lastAttempt: lastAttempt,
                retryCount: retryCount,
                status: status,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required String entityId,
                required String action,
                required DateTime createdAt,
                Value<DateTime?> lastAttempt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                action: action,
                createdAt: createdAt,
                lastAttempt: lastAttempt,
                retryCount: retryCount,
                status: status,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$ForumDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$ForumDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;

class $ForumDatabaseManager {
  final _$ForumDatabase _db;
  $ForumDatabaseManager(this._db);
  $$ForumPostsTableTableManager get forumPosts =>
      $$ForumPostsTableTableManager(_db, _db.forumPosts);
  $$ForumCommentsTableTableManager get forumComments =>
      $$ForumCommentsTableTableManager(_db, _db.forumComments);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
