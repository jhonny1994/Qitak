import 'dart:io';

import 'package:qitak_app/features/release/data/release_decision_record_codec.dart';
import 'package:qitak_app/features/release/domain/release_readiness_models.dart';

class ReleaseDecisionRecordRepository {
  ReleaseDecisionRecordRepository(this.codec);

  final ReleaseDecisionRecordCodec codec;

  Future<File> persist({
    required ReleaseDecisionRecord record,
    String directory = 'reports/release',
  }) async {
    final dir = Directory(directory);
    await dir.create(recursive: true);
    final file = File('${dir.path}/decision_${record.runId}.json');
    await file.writeAsString(codec.encode(record));
    return file;
  }
}
