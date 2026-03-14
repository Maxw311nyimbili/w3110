import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class AudioRecordingService {
  final _record = AudioRecorder();

  Future<bool> hasPermission() async {
    return await _record.hasPermission();
  }

  Stream<Amplitude> onAmplitudeChanged() {
    return _record.onAmplitudeChanged(const Duration(milliseconds: 100));
  }

  Future<void> startRecording() async {
    try {
      if (await _record.hasPermission()) {
        String? path;
        
        if (!kIsWeb) {
          final dir = await getTemporaryDirectory();
          path = p.join(
            dir.path,
            'recording_${DateTime.now().millisecondsSinceEpoch}.m4a',
          );
        }

        await _record.start(const RecordConfig(), path: path ?? '');
      }
    } catch (e) {
      print('Error starting recording: $e');
      rethrow;
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _record.stop();
      return path;
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }

  Future<void> cancelRecording() async {
    try {
      await _record.stop();
      // On web, we don't have direct file access to delete, browser handles blobs
    } catch (e) {
      print('Error cancelling recording: $e');
    }
  }

  void dispose() {
    _record.dispose();
  }
}
