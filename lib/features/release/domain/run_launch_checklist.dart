import 'package:qitak_app/features/release/domain/launch_checklist_service.dart';
import 'package:qitak_app/features/release/domain/launch_operations_models.dart';

class RunLaunchChecklist {
  RunLaunchChecklist(this._service);

  final LaunchChecklistService _service;

  LaunchChecklistRun call(List<ChecklistPrerequisite> prerequisites) {
    final start = DateTime.now().toUtc();
    final decision = _service.evaluate(prerequisites);
    final end = DateTime.now().toUtc();
    return LaunchChecklistRun(
      id: 'chk-${start.millisecondsSinceEpoch}',
      startedAt: start,
      endedAt: end,
      decision: decision,
      prerequisites: prerequisites,
    );
  }
}
