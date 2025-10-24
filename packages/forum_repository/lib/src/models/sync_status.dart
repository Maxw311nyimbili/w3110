// packages/forum_repository/lib/src/models/sync_status.dart

/// Sync status enumeration
enum SyncStatus {
  synced('synced'),
  pending('pending'),
  syncing('syncing'),
  error('error');

  const SyncStatus(this.value);
  final String value;

  static SyncStatus fromString(String value) {
    switch (value) {
      case 'synced':
        return SyncStatus.synced;
      case 'pending':
        return SyncStatus.pending;
      case 'syncing':
        return SyncStatus.syncing;
      case 'error':
        return SyncStatus.error;
      default:
        return SyncStatus.synced;
    }
  }
}